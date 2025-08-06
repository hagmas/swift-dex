# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftDex is a Swift Package Manager library for creating presentations in SwiftUI. It provides a declarative API for building slide-based presentations with animations, transitions, and custom views.

## Development Commands

### Testing
- `./scripts/test.sh` - Run the test suite using xcodebuild
- `swift test` - Alternative test command using Swift Package Manager

### Code Quality
- `make lint` - Check code formatting with swift-format
- `make format` - Auto-format code with swift-format
- `swift build` - Build the library
- `SWIFT_DEX_DEVELOPMENT=1 swift build -c release` - Build with development dependencies

### Example Project
- `make proj` - Generate Xcode project for the example app using XcodeGen
- The example project is in `Examples/SwiftDexExample.xcodeproj`

### Development Dependencies
Development dependencies (swift-docc-plugin, swift-format, XcodeGen) are only included when `SWIFT_DEX_DEVELOPMENT` environment variable is set.

## Core Architecture

### Primary Components

**Deck**: Top-level container that defines a presentation flow
- Implements `Deck` protocol with a `flow` property
- Can specify custom `DeckStyle` for presentation-wide styling
- Example: `MyDeck` in `Examples/SwiftDexExample/MyDeck.swift`

**Slide**: Individual presentation slides
- Implement `Slide` protocol with `content` and optional `background` views  
- Can define `actionContainer` for animations using `@ActionContainerBuilder`
- All slides are stateless - use Actions for dynamic behavior

**StandardLayoutSlide**: Scaffold for common slide layouts
- Provides `head`, `body`, and `auxiliary` view sections
- Uses `StandardScaffold` internally for consistent positioning
- Most example slides use this pattern

**Flow**: Defines slide sequences and transitions
- Chain slides using `.next()` method with optional `SlideTransition`
- Supports nested flows for organizing complex presentations
- Example transitions: `.push()`, `.matched()`, `.customPush()`

**Action**: Animations and dynamic behaviors within slides
- Applied sequentially when advancing through a slide
- Built-in actions: `Apply`, `ApplyByItem`, `Zoom`, `Highlight`, `FlipByItem`
- Target elements using `ElementID` system (`.elementID()` modifier)

### Key Architectural Patterns

1. **Element Targeting**: Views can be tagged with `.elementID()` for action targeting
2. **Result Builders**: Uses `@ActionContainerBuilder` and `@ViewBuilder` extensively  
3. **Protocol-Based Design**: Core functionality defined through protocols (`Deck`, `Slide`, `Flow`, `Action`)
4. **Stateless Slides**: No `@State` or `@ObservableObject` - all dynamics through Action system

### Custom Views
- **Bullets**: Bulleted list with item-by-item animations
- **Code**: Syntax-highlighted code blocks (uses Splash library)
- **Flipper**: Multi-step content views

## File Structure
- `Sources/SwiftDex/Core/` - Core protocols and implementations
- `Sources/SwiftDex/Action/` - Built-in action types  
- `Sources/SwiftDex/View/` - Custom presentation views
- `Sources/SwiftDex/Style/` - Styling system
- `Sources/SwiftDex/Preview/` - Preview helpers for development
- `Tests/SwiftDexTests/` - Test suite
- `Examples/SwiftDexExample/` - Example presentation demonstrating features

## Platform Requirements
- macOS 14.0+
- Swift 5.9+
- Depends on Splash 0.16.0 for syntax highlighting