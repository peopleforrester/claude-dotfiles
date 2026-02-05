---
name: springboot-patterns
description: |
  Spring Boot 3.x best practices. Covers layered architecture, dependency
  injection, JPA/Hibernate patterns, REST controllers, configuration
  management, and production-ready features with Spring Actuator.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - patterns
    - spring-boot
    - framework
    - java
---

# Spring Boot Patterns

Modern Spring Boot 3.x patterns and best practices.

## Project Structure

```
src/main/java/com/example/app/
├── config/                    # Configuration classes
│   ├── SecurityConfig.java
│   └── WebConfig.java
├── controller/                # REST controllers
│   └── UserController.java
├── service/                   # Business logic
│   ├── UserService.java
│   └── impl/
│       └── UserServiceImpl.java
├── repository/                # Data access
│   └── UserRepository.java
├── model/                     # JPA entities
│   ├── User.java
│   └── BaseEntity.java
├── dto/                       # Data transfer objects
│   ├── UserRequest.java
│   └── UserResponse.java
├── exception/                 # Custom exceptions
│   ├── ResourceNotFoundException.java
│   └── GlobalExceptionHandler.java
└── Application.java
```

## REST Controllers

```java
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping
    public Page<UserResponse> list(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return userService.findAll(PageRequest.of(page, size));
    }

    @GetMapping("/{id}")
    public UserResponse get(@PathVariable UUID id) {
        return userService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse create(@Valid @RequestBody UserRequest request) {
        return userService.create(request);
    }

    @PutMapping("/{id}")
    public UserResponse update(@PathVariable UUID id, @Valid @RequestBody UserRequest request) {
        return userService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        userService.delete(id);
    }
}
```

## Service Layer

```java
public interface UserService {
    Page<UserResponse> findAll(Pageable pageable);
    UserResponse findById(UUID id);
    UserResponse create(UserRequest request);
    UserResponse update(UUID id, UserRequest request);
    void delete(UUID id);
}

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    @Override
    public Page<UserResponse> findAll(Pageable pageable) {
        return userRepository.findAll(pageable).map(UserResponse::from);
    }

    @Override
    public UserResponse findById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
        return UserResponse.from(user);
    }

    @Override
    @Transactional
    public UserResponse create(UserRequest request) {
        User user = User.builder()
                .name(request.name())
                .email(request.email())
                .build();
        return UserResponse.from(userRepository.save(user));
    }

    @Override
    @Transactional
    public UserResponse update(UUID id, UserRequest request) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", id));
        user.setName(request.name());
        user.setEmail(request.email());
        return UserResponse.from(userRepository.save(user));
    }

    @Override
    @Transactional
    public void delete(UUID id) {
        if (!userRepository.existsById(id)) {
            throw new ResourceNotFoundException("User", id);
        }
        userRepository.deleteById(id);
    }
}
```

## JPA Entities

```java
@MappedSuperclass
@Getter
@EntityListeners(AuditingEntityListener.class)
public abstract class BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @CreatedDate
    @Column(updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;
}

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_user_email", columnList = "email", unique = true),
    @Index(name = "idx_user_active", columnList = "active")
})
@Getter @Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User extends BaseEntity {

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;
}
```

## DTOs with Records

```java
// Request DTO with validation
public record UserRequest(
    @NotBlank @Size(max = 100) String name,
    @NotBlank @Email String email
) {}

// Response DTO with factory method
public record UserResponse(
    UUID id,
    String name,
    String email,
    boolean active,
    Instant createdAt
) {
    public static UserResponse from(User user) {
        return new UserResponse(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.isActive(),
            user.getCreatedAt()
        );
    }
}
```

## Repository Layer

```java
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.active = true")
    Page<User> findAllActive(Pageable pageable);

    boolean existsByEmail(String email);

    @Modifying
    @Query("UPDATE User u SET u.active = false WHERE u.id = :id")
    void deactivate(@Param("id") UUID id);
}
```

## Global Exception Handling

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ProblemDetail handleNotFound(ResourceNotFoundException ex) {
        return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ProblemDetail handleValidation(MethodArgumentNotValidException ex) {
        ProblemDetail problem = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        problem.setTitle("Validation Error");
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
            .forEach(e -> errors.put(e.getField(), e.getDefaultMessage()));
        problem.setProperty("errors", errors);
        return problem;
    }
}
```

## Configuration

```yaml
# application.yml
spring:
  datasource:
    url: ${DATABASE_URL}
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
  jpa:
    open-in-view: false  # Prevent lazy loading in views
    hibernate:
      ddl-auto: validate  # Never auto-create in production
    properties:
      hibernate:
        default_batch_fetch_size: 20
        order_inserts: true
        order_updates: true
        jdbc:
          batch_size: 50

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: when-authorized
```

## Checklist

- [ ] Controllers only handle HTTP concerns, delegate to services
- [ ] Services annotated with `@Transactional(readOnly = true)` at class level
- [ ] Write methods annotated with `@Transactional`
- [ ] DTOs use Java records for immutability
- [ ] Validation annotations on request DTOs
- [ ] Global exception handler returns ProblemDetail (RFC 7807)
- [ ] `open-in-view: false` to prevent lazy loading issues
- [ ] Database indexes on frequently queried columns
- [ ] UUID primary keys for entities
- [ ] Actuator endpoints configured for monitoring
