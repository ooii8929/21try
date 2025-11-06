# 21 Try App - Kiro Documentation

Welcome to the Kiro documentation for the 21 Try App! This directory contains everything you need to transition from vibe coding to spec-driven development.

## 📚 Documentation Index

### 🚀 Getting Started

**[TRANSITION_GUIDE.md](TRANSITION_GUIDE.md)** - Start here!
- Understand what changed
- Learn the new workflow
- See example commands
- Get tips for success

**[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick lookup
- Common commands
- Key patterns
- Design system
- Workflow cheatsheet

**[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Big picture
- What is 21 Try?
- Current state
- Architecture overview
- Future roadmap

### 📖 Steering Documentation

The `steering/` directory contains your project's knowledge base that guides AI-assisted development.

**[steering/README.md](steering/README.md)** - Documentation guide
- How to use steering docs
- When each doc is active
- Common tasks
- Maintenance guidelines

#### Always Active (Core Documentation)

**[steering/product.md](steering/product.md)** - Product vision
- Core value proposition
- Target users
- Key user flows
- Design principles

**[steering/tech.md](steering/tech.md)** - Technology stack
- Framework & dependencies
- Architecture patterns
- Platform considerations
- Build & deployment

**[steering/structure.md](steering/structure.md)** - Project architecture
- Directory structure
- Layer responsibilities
- Navigation patterns
- Data flow
- State management

**[steering/standards.md](steering/standards.md)** - Coding conventions
- Naming conventions
- Code organization
- Widget patterns
- Async patterns
- UI/UX standards

#### Context-Aware (Activated When Relevant)

**[steering/data-models.md](steering/data-models.md)** - Data specifications
- Activated when: Working with `**/*models*.dart`
- Goal & Record models
- Relationships
- UUID strategy
- Code generation

**[steering/ui-patterns.md](steering/ui-patterns.md)** - UI guidelines
- Activated when: Working with `screens/` or `widgets/`
- Screen layouts
- Common components
- Form patterns
- Video player setup

**[steering/testing.md](steering/testing.md)** - Testing guidelines
- Activated when: Working with `**/*test*.dart`
- Testing philosophy
- Test patterns
- Mocking strategies
- Running tests

## 🎯 Quick Start

### 1. Read the Transition Guide
```
Open: .kiro/TRANSITION_GUIDE.md
```
Understand how to move from vibe coding to spec-driven development.

### 2. Create Your First Spec
```
Ask Kiro: "Create a spec for [feature-name]"
```
Experience the requirements → design → tasks workflow.

### 3. Execute a Task
```
Ask Kiro: "Execute task 1 from [spec-name]"
```
See how Kiro implements following your established patterns.

### 4. Keep the Quick Reference Handy
```
Open: .kiro/QUICK_REFERENCE.md
```
Fast lookup for commands, patterns, and conventions.

## 📋 What's Included

### ✅ Product Documentation
- Vision and user flows
- Design principles
- Success metrics

### ✅ Technical Documentation
- Technology stack
- Architecture patterns
- Project structure
- Data models

### ✅ Development Standards
- Naming conventions
- Code organization
- UI/UX patterns
- Testing guidelines

### ✅ Workflow Guides
- Spec-driven development
- Task execution
- Documentation updates

## 🔄 Development Workflows

### Spec-Driven (For Features)
```
Idea → Requirements → Design → Tasks → Implementation
```
1. Create spec: "Create a spec for [feature]"
2. Review requirements
3. Review design
4. Review tasks
5. Execute tasks one at a time

### Direct Development (For Quick Changes)
```
Idea → Implementation
```
- Bug fixes
- Minor tweaks
- Simple updates

## 💡 Key Concepts

### Steering Documentation
Project knowledge that guides AI development:
- Always active: Core docs (product, tech, structure, standards)
- Context-aware: Activated when working with specific files
- Evolving: Update as patterns change

### Spec-Driven Development
Systematic approach to building features:
- **Requirements**: User stories with acceptance criteria (EARS format)
- **Design**: Technical architecture and implementation approach
- **Tasks**: Actionable steps for implementation

### Route-Aware State Management
Automatic data refresh pattern:
- Screens use `RouteAware` mixin
- Subscribe to `routeObserver`
- Reload data in `didPopNext()`

## 🎨 Design System

### Colors
```dart
AppColors.background       // Dark green
AppColors.cardBackground   // Medium green
AppColors.primary          // Bright green (accent)
AppColors.textPrimary      // White
AppColors.textSecondary    // Light green
```

### Typography
- Font: Manrope (400, 500, 700)
- Sizes: 14px, 16px, 18px
- Line heights: 1.28, 1.5

### Spacing
- Standard: 4, 8, 12, 16, 20, 24px

## 🏗️ Architecture

### Layers
```
Screens (UI)
    ↓
Services (Business Logic)
    ↓
Database (Isar)
```

### Data Flow
```
User Action → Screen → Service → Database
                ↓
            setState()
                ↓
            UI Update
```

### State Management
- Local state with `setState`
- Database as source of truth
- Route-aware refresh

## 📱 App Structure

```
lib/
├── main.dart           # Entry point
├── models/             # Data models
├── services/           # Business logic
├── screens/            # Full-page UI
├── widgets/            # Reusable components
└── utils/              # Constants & helpers
```

## 🧪 Testing

### Test Types
- **Unit**: Services and models
- **Widget**: UI components
- **Integration**: Complete flows

### Running Tests
```bash
flutter test                    # All tests
flutter test --coverage         # With coverage
flutter test path/to/test.dart  # Specific test
```

## 🚀 Common Commands

### Spec Management
```
"Create a spec for [feature]"
"Execute task 1 from [spec]"
"Update requirements for [spec]"
```

### Documentation
```
"What's in the steering docs?"
"Show me the UI patterns"
"Update the coding standards"
```

### Development
```
"Add a new screen for [feature]"
"Create a widget for [component]"
"Fix the bug in [file]"
```

## 📖 Learning Path

### Day 1: Orientation
1. Read TRANSITION_GUIDE.md
2. Browse PROJECT_OVERVIEW.md
3. Skim QUICK_REFERENCE.md

### Day 2: First Spec
1. Create a simple spec
2. Review requirements
3. Review design
4. Review tasks

### Day 3: Implementation
1. Execute first task
2. Review implementation
3. Execute second task
4. Complete the spec

### Ongoing: Mastery
- Update steering docs as you learn
- Refine your spec process
- Build more complex features

## 🆘 Getting Help

### Ask Kiro
```
"How do I [task]?"
"What's the pattern for [feature]?"
"Show me an example of [component]"
```

### Check Documentation
- Quick answers: QUICK_REFERENCE.md
- Deep dive: steering/ directory
- Big picture: PROJECT_OVERVIEW.md

### Common Questions

**"Do I need specs for everything?"**
No - use specs for features, direct development for quick changes.

**"Can I update the steering docs?"**
Yes - they should evolve with your project.

**"What if I want to change the spec workflow?"**
The workflow is flexible - customize to your needs.

## 🎯 Success Metrics

### You'll Know It's Working When:
- ✅ AI follows your established patterns
- ✅ Code is consistent across features
- ✅ New features are well-documented
- ✅ Implementation is predictable
- ✅ Onboarding is faster

## 🔄 Maintenance

### Keep Documentation Updated
- New patterns → Update steering docs
- New conventions → Update standards
- New features → Create specs
- Lessons learned → Update guides

### Regular Reviews
- Monthly: Review steering docs
- Per feature: Update relevant docs
- Per sprint: Refine spec process

## 📞 Support Resources

### Documentation
- `.kiro/` - This directory
- `README.md` - Project README
- `pubspec.yaml` - Dependencies

### External
- [Flutter Docs](https://flutter.dev/docs)
- [Isar Docs](https://isar.dev)
- [Dart Language](https://dart.dev)

## 🎉 You're Ready!

You now have:
- ✅ Comprehensive project documentation
- ✅ Established coding standards
- ✅ Spec-driven development workflow
- ✅ AI-assisted development guides

Start with the TRANSITION_GUIDE.md and create your first spec!

---

**Documentation Version**: 1.0.0
**Last Updated**: November 6, 2025
**Status**: ✅ Complete and Ready to Use
