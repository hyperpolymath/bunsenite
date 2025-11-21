# Bunsenite Project

## Project Overview

Bunsenite is a [describe project purpose here - update as project develops].

**Status**: Early development / Initial setup

## Project Structure

```
bunsenite/
├── CLAUDE.md           # This file - AI assistant context
└── .git/              # Git repository
```

## Technology Stack

[To be determined - update as technologies are added]

Potential stack:
- Language: [TBD]
- Framework: [TBD]
- Build tools: [TBD]
- Testing: [TBD]

## Development Setup

### Prerequisites

[List required tools, versions, etc.]

### Installation

```bash
# Clone the repository
git clone [repository-url]
cd bunsenite

# [Add installation steps as project develops]
```

### Running the Project

```bash
# [Add run commands as project develops]
```

## Code Conventions

### Naming Conventions

- **Files**: [Define convention - e.g., kebab-case, snake_case, PascalCase]
- **Variables**: [Define convention]
- **Functions**: [Define convention]
- **Classes**: [Define convention]

### Code Style

- [Define formatting rules]
- [Define linting rules]
- [Define comment conventions]

### Testing Conventions

- Test files: [Define pattern - e.g., `*.test.js`, `*_test.py`]
- Test location: [Define where tests live]
- Coverage requirements: [Define thresholds]

## Architecture

### Design Patterns

[Document architectural patterns as they emerge]

### Key Components

[Document main components as they are developed]

### Data Flow

[Document how data flows through the system]

## Development Workflow

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `claude/*` - AI assistant working branches

### Commit Messages

Follow conventional commits format:

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes with clear, atomic commits
3. Write/update tests
4. Update documentation
5. Create PR with description of changes
6. Address review feedback
7. Merge when approved

## Testing

### Running Tests

```bash
# [Add test commands as testing is set up]
```

### Writing Tests

[Document testing patterns and best practices]

## Building and Deployment

### Build Process

```bash
# [Add build commands]
```

### Deployment

[Document deployment process and environments]

## Common Tasks

### Adding a New Feature

1. Create feature branch: `git checkout -b feature/feature-name`
2. [Add steps specific to this project]
3. Write tests
4. Update documentation
5. Create pull request

### Debugging

[Document debugging tools and techniques specific to this project]

## Troubleshooting

### Common Issues

[Document common problems and solutions as they arise]

## Resources

### Documentation

- [Link to external docs]
- [Link to API references]
- [Link to design docs]

### Related Projects

- [List related repositories or dependencies]

## Notes for AI Assistants

### Important Context

- This is a new project in early development
- Repository structure will evolve as the project grows
- Update this file as new conventions and patterns are established

### When Making Changes

- Follow the branch strategy (use `claude/*` branches)
- Maintain consistency with established patterns
- Update tests when modifying functionality
- Update this CLAUDE.md when introducing new conventions
- Ask for clarification if project direction is unclear

### Code Quality Standards

- Write clean, readable code with clear intent
- Include comments for complex logic
- Ensure all tests pass before committing
- Follow security best practices
- Avoid introducing dependencies without discussion

### Suggested Improvements

When working on this project, consider:
- Proposing architectural patterns as codebase grows
- Identifying opportunities for refactoring
- Suggesting better error handling
- Recommending performance optimizations
- Highlighting potential security concerns

## Project-Specific Guidelines

[Add any unique guidelines or constraints specific to this project]

## Changelog

Track major changes to project structure and conventions:

- **2025-11-21**: Initial project setup, CLAUDE.md created

---

**Note**: This document should be updated as the project evolves. Keep it current to help AI assistants and new developers understand the project quickly.
