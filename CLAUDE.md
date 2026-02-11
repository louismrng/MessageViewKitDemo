# CLAUDE.md

# IMPORTANT!
Do not run xcodebuild from claude code. I will always run the build manually to verify changes! This will save time and tokens

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

```
MessageViewKitDemo/
├── MessageViewKitDemoApp.swift      (@main entry point)
├── MainTabView.swift                (Root TabView with tabs)
├── MockDataProvider.swift           (Simulates real-time messaging)
├── ChatListTab.swift                (Messages tab with search)
├── ConversationView.swift           (Thread conversation screen)
├── ChatList/
│   ├── Protocols/                   (Thread, ChatListStyleProvider)
│   └── SwiftUI/                     (ChatListView, etc.)
├── Conversation/
│   ├── Protocols/                   (Message, ConversationStyleProvider)
│   └── SwiftUI/                     (ConversationContentView, etc.)
└── ...
```

## Architecture Overview

This is an iOS demo app showcasing two reusable UI components for chat applications. It uses pure SwiftUI App lifecycle with `@main` entry point.

### Two UI Components

**ChatList** - Chat list/inbox UI
- Protocols: `Thread`, `ChatListStyleProvider`
- Type-erased wrapper: `AnyThread` for SwiftUI compatibility
- Main view: `ChatListView`
- ViewModel: `ChatListViewModel`
- Key types: `Snippet`, `MessageStatus`, `FilterMode`
- Callbacks: `onThreadSelected`, `onArchiveThread`, `onDeleteThread`, `onMuteThread`, `onPinThread`

**Conversation** - Message conversation UI
- Protocols: `Message`, `ConversationStyleProvider`, `Conversation`
- Type-erased wrapper: `AnyMessage` for SwiftUI compatibility
- Main view: `ConversationContentView`
- ViewModel: `ConversationViewModel`
- Key types: `DeliveryStatus`, `Conversation`
- Image support: `ImageBubble` for photo messages
- Date grouping: `DateHeader` for message timestamps
- Callbacks: `onSendMessage`, `onTypingStateChanged`

### Navigation Architecture

- `MainTabView` owns the `TabView` with traditional `.tabItem` modifiers
- `ChatListTab` owns its own `NavigationStack` and `NavigationPath`
- Thread selection triggers `.navigationDestination` to push `ConversationView`
- Tab bar hides automatically when navigating into a conversation

### Data Flow

1. `MockDataProvider` is an `ObservableObject` that holds `@Published` threads and messages
2. `MainTabView` creates `MockDataProvider` and passes to `ChatListTab`
3. Thread selection appends thread ID to navigation path, triggering `.navigationDestination`
4. ViewModels use callbacks (`onSendMessage`, `onThreadSelected`) rather than delegates for actions

### Protocol Adapter Pattern

The components use protocol-based adapters for integration with any backend:
- Implement `Thread` to adapt your thread/roster model
- Implement `Message` to adapt your XMPP/SIP message model
- Type-erased `AnyThread`/`AnyMessage` wrappers provide `Identifiable`/`Equatable` for SwiftUI
- Mock implementations: `MockThread`, `MockMessage`

### Style System

Both components use injectable style protocols:
- `ConversationStyleProvider` / `ChatListStyleProvider` define colors, fonts, layout
- Default implementations: `ConversationDefaultStyle.shared` / `ChatListDefaultStyle.shared`
- SwiftUI environment: `.conversationStyle()` / `.chatListStyle()` modifiers

## Demo App Features

`MockDataProvider` simulates realistic messaging behavior:
- **Incoming messages**: Simulated at 8-15 second intervals
- **Typing indicators**: Shows remote user typing before messages arrive
- **Delivery status progression**: Messages transition through sending → delivered → read states

## Feature Status

- Image messages (implemented via `ImageBubble`)
- Reactions (implemented via `ReactionPicker`, `ReactionBadge`, `ReactionDetailsSheet`)
- Remaining: Link previews, quoted replies
