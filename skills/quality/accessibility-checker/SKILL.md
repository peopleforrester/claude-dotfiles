---
name: accessibility-checker
description: |
  Web accessibility review following WCAG guidelines. Use when auditing
  accessibility compliance, reviewing UI components, or ensuring inclusive
  design. Covers WCAG 2.1 Level AA requirements.
license: MIT
compatibility: Claude Code 2.1+
metadata:
  author: michaelrishiforrester
  version: "1.0.0"
  tags:
    - quality
    - accessibility
    - a11y
---

# Accessibility Checker

Ensure web content is accessible to all users.

## When to Use

- Reviewing UI components for accessibility
- Auditing pages for WCAG compliance
- Building accessible forms
- Implementing keyboard navigation
- Adding screen reader support

## WCAG 2.1 Principles (POUR)

1. **Perceivable** - Content can be perceived
2. **Operable** - Interface can be operated
3. **Understandable** - Content is understandable
4. **Robust** - Works with assistive technologies

## Common Issues & Fixes

### Images Without Alt Text

```tsx
// Bad: Missing alt
<img src="hero.jpg" />

// Good: Descriptive alt
<img src="hero.jpg" alt="Team collaborating around a whiteboard" />

// Good: Decorative image (empty alt)
<img src="decorative-line.svg" alt="" role="presentation" />
```

### Poor Color Contrast

```css
/* Bad: 2.5:1 contrast ratio */
.text {
  color: #999;
  background: #fff;
}

/* Good: 4.5:1+ contrast ratio */
.text {
  color: #595959;
  background: #fff;
}
```

**Tools:**
- WebAIM Contrast Checker
- Chrome DevTools → Rendering → CSS contrast

### Missing Form Labels

```tsx
// Bad: No label
<input type="email" placeholder="Email" />

// Good: Associated label
<label htmlFor="email">Email address</label>
<input type="email" id="email" />

// Good: Visually hidden label (when design requires)
<label htmlFor="search" className="sr-only">Search</label>
<input type="search" id="search" placeholder="Search..." />
```

### Non-Keyboard Accessible

```tsx
// Bad: Only mouse event
<div onClick={handleClick}>Click me</div>

// Good: Keyboard accessible
<button onClick={handleClick}>Click me</button>

// Good: If must use div, add keyboard support
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => e.key === 'Enter' && handleClick()}
>
  Click me
</div>
```

### Missing Focus Indicators

```css
/* Bad: Removing focus outline */
button:focus {
  outline: none;
}

/* Good: Custom focus indicator */
button:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.5);
}

/* Good: Focus-visible for keyboard only */
button:focus-visible {
  outline: 2px solid #4299e1;
  outline-offset: 2px;
}
```

### Missing Skip Links

```tsx
// Good: Skip to main content
<a href="#main" className="sr-only focus:not-sr-only">
  Skip to main content
</a>

<nav>...</nav>

<main id="main" tabIndex={-1}>
  ...
</main>
```

### Poor Heading Structure

```tsx
// Bad: Skipping levels
<h1>Page Title</h1>
<h3>Section</h3>  {/* Skipped h2! */}

// Good: Proper hierarchy
<h1>Page Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>
```

### Inaccessible Modals

```tsx
// Good: Accessible modal
function Modal({ isOpen, onClose, title, children }) {
  const modalRef = useRef();

  useEffect(() => {
    if (isOpen) {
      modalRef.current?.focus();
      // Trap focus inside modal
    }
  }, [isOpen]);

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      ref={modalRef}
      tabIndex={-1}
    >
      <h2 id="modal-title">{title}</h2>
      {children}
      <button onClick={onClose}>Close</button>
    </div>
  );
}
```

## ARIA Patterns

### Buttons

```tsx
// Toggle button
<button
  aria-pressed={isActive}
  onClick={toggle}
>
  {isActive ? 'Active' : 'Inactive'}
</button>
```

### Tabs

```tsx
<div role="tablist">
  <button
    role="tab"
    aria-selected={activeTab === 0}
    aria-controls="panel-0"
    id="tab-0"
  >
    Tab 1
  </button>
</div>

<div
  role="tabpanel"
  id="panel-0"
  aria-labelledby="tab-0"
  hidden={activeTab !== 0}
>
  Content
</div>
```

### Live Regions

```tsx
// Announce dynamic content
<div aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>

// Urgent announcements
<div role="alert">
  Error: Please fix the form
</div>
```

### Loading States

```tsx
<button disabled={isLoading} aria-busy={isLoading}>
  {isLoading ? 'Saving...' : 'Save'}
</button>

// Or with live region
<div aria-live="polite">
  {isLoading && <span>Loading, please wait...</span>}
</div>
```

## Accessibility Checklist

### Perceivable

- [ ] Images have alt text
- [ ] Color contrast meets 4.5:1 (text) / 3:1 (large text)
- [ ] Information not conveyed by color alone
- [ ] Captions for videos
- [ ] Text can be resized to 200%

### Operable

- [ ] All functionality keyboard accessible
- [ ] Visible focus indicators
- [ ] Skip links present
- [ ] No keyboard traps
- [ ] Sufficient time for interactions

### Understandable

- [ ] Page language specified
- [ ] Consistent navigation
- [ ] Error messages are clear
- [ ] Labels are descriptive
- [ ] Instructions are provided

### Robust

- [ ] Valid HTML
- [ ] ARIA used correctly
- [ ] Works with screen readers
- [ ] Compatible with browser zoom

## Testing Tools

### Automated

```bash
# axe-core
npx @axe-core/cli https://example.com

# Pa11y
npx pa11y https://example.com

# Lighthouse
npx lighthouse https://example.com --only-categories=accessibility
```

### Browser Extensions

- axe DevTools
- WAVE
- Accessibility Insights

### Screen Readers

- VoiceOver (macOS): Cmd + F5
- NVDA (Windows): Free download
- JAWS (Windows): Commercial

## Screen Reader Only CSS

```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

.sr-only.focusable:focus {
  position: static;
  width: auto;
  height: auto;
  margin: 0;
  overflow: visible;
  clip: auto;
  white-space: normal;
}
```

## Quick Audit Steps

1. **Keyboard test**: Navigate entire page with Tab/Shift+Tab
2. **Zoom test**: Zoom to 200%, check layout
3. **Color test**: View in grayscale
4. **Screen reader test**: Use VoiceOver/NVDA
5. **Automated scan**: Run axe or Lighthouse
