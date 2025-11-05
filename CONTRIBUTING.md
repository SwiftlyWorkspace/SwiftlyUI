# Contributing to SwiftlyUI

Thank you for your interest in contributing to SwiftlyUI! We welcome contributions from the community.

## 🚀 Quick Start

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Add tests for new functionality
5. Run the test suite: `swift test`
6. Submit a pull request

## 📋 Development Setup

### Prerequisites

- **macOS** (for full development experience)
- **Xcode 14.0+**
- **Swift 5.7+**

### Getting Started

```bash
# Clone your fork
git clone https://github.com/yourusername/SwiftlyUI.git
cd SwiftlyUI

# Build the library
swift build

# Run tests
swift test

# Build and run the demo app
cd SwiftlyUI-DemoApp
swift build
```

## 🧪 Testing

We maintain high test coverage for all components. When contributing:

- Add unit tests for new functionality
- Update existing tests when modifying behavior
- Ensure all tests pass: `swift test`
- Test on multiple platforms when possible

### Test Structure

```swift
// Example test structure
import XCTest
@testable import SwiftlyUI

final class ComponentNameTests: XCTestCase {
    func testBasicFunctionality() {
        // Test basic component behavior
    }

    func testEdgeCases() {
        // Test edge cases and error conditions
    }
}
```

## 📝 Code Style

We follow Swift's official style guidelines:

- Use 4 spaces for indentation
- Follow Swift naming conventions
- Add documentation comments for public APIs
- Keep line length under 120 characters
- Use meaningful variable and function names

### Documentation

All public APIs should include documentation:

```swift
/// A brief description of what this does.
///
/// A more detailed description if needed, including:
/// - Important usage notes
/// - Parameter descriptions
/// - Return value information
///
/// ## Example
/// ```swift
/// let example = Component()
/// example.configure()
/// ```
///
/// - Parameters:
///   - parameter1: Description of parameter1
///   - parameter2: Description of parameter2
/// - Returns: Description of return value
public func exampleFunction(parameter1: String, parameter2: Int) -> Bool {
    // Implementation
}
```

## 🎨 Adding New Components

When adding new components:

1. **Create the component file** in `Sources/SwiftlyUI/Components/`
2. **Add comprehensive tests** in `Tests/SwiftlyUITests/`
3. **Update the public API** in `SwiftlyUI.swift`
4. **Add demo usage** in the demo app
5. **Update documentation** including README.md

### Component Template

```swift
import SwiftUI

/// Brief description of the component.
///
/// Detailed description including features and usage examples.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ComponentName: View {
    // MARK: - Properties

    // MARK: - Initializers

    /// Creates a new component.
    /// - Parameters:
    ///   - parameter: Description of parameter
    public init(parameter: String) {
        // Initialize
    }

    // MARK: - Body

    public var body: some View {
        // Implementation
    }

    // MARK: - Private Methods
}

// MARK: - Preview

#Preview {
    ComponentName(parameter: "Example")
}
```

## 🐛 Bug Reports

When reporting bugs:

1. **Search existing issues** first
2. **Use the bug report template**
3. **Include reproduction steps**
4. **Specify platform and OS version**
5. **Provide minimal reproduction code**

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Environment:**
- Platform: [iOS/macOS/tvOS/watchOS]
- OS Version: [e.g., iOS 16.0]
- SwiftlyUI Version: [e.g., 1.0.0]
- Xcode Version: [e.g., 14.0]

**Additional context**
Any other context about the problem.
```

## ✨ Feature Requests

For new features:

1. **Check existing issues** and discussions
2. **Open a feature request** with detailed description
3. **Discuss the approach** before implementing
4. **Consider backwards compatibility**

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of what the problem is.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
A clear description of any alternative solutions.

**Additional context**
Any other context or screenshots about the feature request.
```

## 📦 Release Process

We follow semantic versioning (SemVer):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

## 🏷️ Pull Request Guidelines

### Before Submitting

- [ ] Code builds without warnings
- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)

### Pull Request Template

```markdown
**Description**
Brief description of changes.

**Type of Change**
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

**Testing**
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Cross-platform compatibility verified

**Screenshots** (if applicable)

**Checklist:**
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

## 💬 Community Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Follow the code of conduct

## 🆘 Getting Help

- **Issues**: For bugs and feature requests
- **Discussions**: For general questions and ideas
- **Documentation**: Check the README and API docs first

## 📄 License

By contributing to SwiftlyUI, you agree that your contributions will be licensed under the MIT License.