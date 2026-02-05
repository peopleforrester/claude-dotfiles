---
name: springboot-tdd
description: |
  Test-driven development patterns for Spring Boot 3.x. Covers JUnit 5,
  MockMvc, Testcontainers, service mocking with Mockito, slice tests,
  integration tests, and test configuration management.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: peopleforrester
  version: "1.0.0"
  tags:
    - tdd
    - spring-boot
    - testing
    - java
---

# Spring Boot TDD Patterns

Test-driven development workflow for Spring Boot 3.x with JUnit 5.

## Test Pyramid

```
         /  E2E  \          <- Few, slow, high confidence
        / Integration \     <- Moderate, Testcontainers
       /  Slice Tests   \   <- Fast, focused (@WebMvcTest, @DataJpaTest)
      /   Unit Tests     \  <- Many, fastest, isolated
```

## Unit Tests (Service Layer)

```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserServiceImpl userService;

    @Test
    void findById_existingUser_returnsResponse() {
        // Arrange
        UUID id = UUID.randomUUID();
        User user = User.builder().name("Alice").email("alice@example.com").build();
        when(userRepository.findById(id)).thenReturn(Optional.of(user));

        // Act
        UserResponse result = userService.findById(id);

        // Assert
        assertThat(result.name()).isEqualTo("Alice");
        assertThat(result.email()).isEqualTo("alice@example.com");
        verify(userRepository).findById(id);
    }

    @Test
    void findById_nonExistingUser_throwsException() {
        UUID id = UUID.randomUUID();
        when(userRepository.findById(id)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.findById(id))
            .isInstanceOf(ResourceNotFoundException.class)
            .hasMessageContaining(id.toString());
    }

    @Test
    void create_validRequest_savesAndReturns() {
        UserRequest request = new UserRequest("Alice", "alice@example.com");
        User saved = User.builder().name("Alice").email("alice@example.com").build();
        when(userRepository.save(any(User.class))).thenReturn(saved);

        UserResponse result = userService.create(request);

        assertThat(result.name()).isEqualTo("Alice");
        verify(userRepository).save(argThat(u -> u.getName().equals("Alice")));
    }
}
```

## Controller Slice Tests (@WebMvcTest)

```java
@WebMvcTest(UserController.class)
@AutoConfigureMockMvc(addFilters = false)  // Disable security for unit tests
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void listUsers_returnsPageOfUsers() throws Exception {
        Page<UserResponse> page = new PageImpl<>(List.of(
            new UserResponse(UUID.randomUUID(), "Alice", "alice@example.com", true, Instant.now())
        ));
        when(userService.findAll(any(Pageable.class))).thenReturn(page);

        mockMvc.perform(get("/api/v1/users"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.content", hasSize(1)))
            .andExpect(jsonPath("$.content[0].name").value("Alice"));
    }

    @Test
    void createUser_validRequest_returns201() throws Exception {
        UserRequest request = new UserRequest("Alice", "alice@example.com");
        UserResponse response = new UserResponse(
            UUID.randomUUID(), "Alice", "alice@example.com", true, Instant.now());
        when(userService.create(any(UserRequest.class))).thenReturn(response);

        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.name").value("Alice"));
    }

    @Test
    void createUser_invalidEmail_returns400() throws Exception {
        String json = """
            {"name": "Alice", "email": "not-an-email"}
            """;

        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(json))
            .andExpect(status().isBadRequest())
            .andExpect(jsonPath("$.errors.email").exists());
    }

    @Test
    void getUser_notFound_returns404() throws Exception {
        UUID id = UUID.randomUUID();
        when(userService.findById(id)).thenThrow(new ResourceNotFoundException("User", id));

        mockMvc.perform(get("/api/v1/users/{id}", id))
            .andExpect(status().isNotFound());
    }
}
```

## Repository Slice Tests (@DataJpaTest)

```java
@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Testcontainers
class UserRepositoryTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private UserRepository userRepository;

    @Test
    void findByEmail_existingEmail_returnsUser() {
        User user = User.builder().name("Alice").email("alice@example.com").build();
        userRepository.save(user);

        Optional<User> found = userRepository.findByEmail("alice@example.com");

        assertThat(found).isPresent();
        assertThat(found.get().getName()).isEqualTo("Alice");
    }

    @Test
    void findByEmail_nonExistingEmail_returnsEmpty() {
        Optional<User> found = userRepository.findByEmail("nobody@example.com");
        assertThat(found).isEmpty();
    }

    @Test
    void findAllActive_excludesInactive() {
        userRepository.save(User.builder().name("Active").email("a@test.com").active(true).build());
        userRepository.save(User.builder().name("Inactive").email("b@test.com").active(false).build());

        Page<User> active = userRepository.findAllActive(PageRequest.of(0, 10));

        assertThat(active.getContent()).hasSize(1);
        assertThat(active.getContent().get(0).getName()).isEqualTo("Active");
    }
}
```

## Integration Tests

```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@ActiveProfiles("test")
class UserIntegrationTest {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    void fullCrudLifecycle() {
        // Create
        UserRequest request = new UserRequest("Alice", "alice@example.com");
        ResponseEntity<UserResponse> createResponse = restTemplate.postForEntity(
            "/api/v1/users", request, UserResponse.class);
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        UUID userId = createResponse.getBody().id();

        // Read
        ResponseEntity<UserResponse> getResponse = restTemplate.getForEntity(
            "/api/v1/users/{id}", UserResponse.class, userId);
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody().name()).isEqualTo("Alice");

        // Update
        restTemplate.put("/api/v1/users/{id}", new UserRequest("Bob", "alice@example.com"), userId);
        UserResponse updated = restTemplate.getForObject("/api/v1/users/{id}", UserResponse.class, userId);
        assertThat(updated.name()).isEqualTo("Bob");

        // Delete
        restTemplate.delete("/api/v1/users/{id}", userId);
        ResponseEntity<Void> deleteCheck = restTemplate.getForEntity(
            "/api/v1/users/{id}", Void.class, userId);
        assertThat(deleteCheck.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }
}
```

## Test Configuration

```yaml
# src/test/resources/application-test.yml
spring:
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
  flyway:
    enabled: false  # Use Hibernate DDL for tests

logging:
  level:
    org.hibernate.SQL: DEBUG
    org.hibernate.orm.jdbc.bind: TRACE
```

## TDD Workflow Commands

```bash
# Run all tests
./gradlew test

# Run specific test class
./gradlew test --tests "com.example.app.service.UserServiceTest"

# Run with coverage (JaCoCo)
./gradlew test jacocoTestReport

# Run only unit tests
./gradlew test --tests "*Test"

# Run only integration tests
./gradlew test --tests "*IntegrationTest"

# Continuous test runner
./gradlew test --continuous
```

## JaCoCo Coverage Config

```groovy
// build.gradle
plugins {
    id 'jacoco'
}

jacocoTestReport {
    reports {
        html.required = true
        xml.required = true
    }
}

jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                minimum = 0.80  // 80% coverage minimum
            }
        }
    }
}

check.dependsOn jacocoTestCoverageVerification
```

## Checklist

- [ ] Unit tests for all service methods with Mockito
- [ ] Controller tests with MockMvc for HTTP behavior
- [ ] Repository tests with Testcontainers (real database)
- [ ] Integration tests covering full request lifecycle
- [ ] Validation error cases tested (400 responses)
- [ ] Not-found cases tested (404 responses)
- [ ] Test profile with separate configuration
- [ ] JaCoCo coverage threshold at 80%
- [ ] Tests isolated with `@BeforeEach` cleanup
- [ ] Testcontainers for database-dependent tests
