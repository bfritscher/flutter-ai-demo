# Gemini Tic Tac Toe

A Flutter application that combines a Gemini-powered chat interface with a Tic Tac Toe game where players can compete against an AI adversary.

## Features

- **Gemini Chat**: A dedicated chat interface for general conversation with the Gemini API
- **Tic Tac Toe Game**: Visual game board with AI opponent
- **AI Move Generation**: Integration with Gemini API to receive AI moves in JSON format
- **AI Banter**: The AI generates taunts and banter during the game
- **Player Taunts**: Players can send custom taunts to the AI
- **Responsive Design**: Material Design 3 with responsive layouts

## Setup

### Prerequisites

- Flutter SDK (version 3.32.8 or later)
- Dart SDK (version 3.8.1 or later)
- A Firebase project with Firebase AI Logic enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd test
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase Project**
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Create a new project or use an existing one
   - Navigate to the Firebase AI Logic page
   - Click "Get started" and follow the guided workflow
   - Choose "Gemini Developer API" provider (recommended for first-time users)
   - The console will enable required APIs and create a Gemini API key

4. **Configure Firebase for your app**
   - Install the FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     ```
   - Configure your app:
     ```bash
     flutterfire configure
     ```
   - This will generate the `firebase_options.dart` file with your project configuration

5. **Run the app**
   ```bash
   flutter run
   ```

## Usage

### Home Screen
- Choose between chatting with Gemini or playing Tic Tac Toe

### Chat Screen
- Built with Flutter AI Toolkit's `LlmChatView`
- Have conversations with the Gemini AI
- Ask questions, get assistance, or just chat
- Features suggestions and chat history management

### Game Screen
- Play Tic Tac Toe against the AI (you are X, AI is O)
- Send taunts to the AI during the game
- AI will respond with its own taunts and commentary
- View game history and AI responses

## Architecture

```
lib/
├── config/
│   └── config.dart           # Configuration settings
├── models/
│   └── game_logic.dart       # Tic Tac Toe game logic
├── screens/
│   ├── home_screen.dart      # Main navigation screen
│   ├── chat_screen.dart      # Gemini chat interface
│   └── game_screen.dart      # Tic Tac Toe game UI
├── services/
│   └── gemini_service.dart   # Gemini API integration
└── main.dart                 # App entry point
```

## Dependencies

- `firebase_core: ^3.13.0` - Firebase core functionality
- `firebase_ai: ^2.0.0` - Firebase AI Logic SDK for Gemini integration
- `flutter_ai_toolkit: ^0.9.2` - Flutter AI Toolkit with LlmChatView
- `http: ^1.2.2` - HTTP client
- `markdown: ^7.2.2` - Markdown support
- `cupertino_icons: ^1.0.8` - iOS-style icons

## Game Rules

1. **Tic Tac Toe**: Standard 3x3 grid
2. **Player**: You play as 'X' and go first
3. **AI**: AI plays as 'O' and uses Gemini to make strategic moves
4. **Winning**: Get three in a row (horizontally, vertically, or diagonally)
5. **Taunting**: Send messages to the AI during the game for interactive banter

## API Integration

The app uses the Firebase AI Logic SDK for:
- **Chat functionality**: Direct conversation with Gemini using `LlmChatView`
- **Game moves**: AI analyzes the board state and makes strategic moves
- **Banter generation**: AI creates contextual taunts and responses

### Key Features of Firebase AI Logic Integration

- **No API Key in Code**: Firebase AI Logic handles authentication securely
- **Built-in Chat UI**: Uses Flutter AI Toolkit's `LlmChatView` for professional chat interface
- **Firebase Provider**: Seamless integration with Firebase services
- **Gemini 2.0 Flash**: Uses the latest Gemini model for fast responses

## Troubleshooting

### Common Issues

1. **Firebase Configuration Error**
   - Ensure you've run `flutterfire configure` correctly
   - Verify your Firebase project has Firebase AI Logic enabled
   - Check that the `firebase_options.dart` file exists

2. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Ensure Flutter SDK is up to date

3. **AI Not Responding**
   - Check internet connection
   - Verify Firebase project configuration
   - Check logs for specific error messages

4. **Gemini API Quota**
   - Firebase AI Logic with Gemini Developer API has generous free tier
   - Monitor usage in Firebase Console if needed

## Future Enhancements

- [ ] Game difficulty levels
- [ ] Multiplayer support
- [ ] Game statistics and history
- [ ] Voice input/output
- [ ] Different game modes
- [ ] Custom AI personalities

## License

This project is for educational and demonstration purposes.
