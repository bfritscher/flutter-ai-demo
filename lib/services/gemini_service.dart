import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final bool debugMode;

  GeminiService({this.debugMode = true}) {
    // Initialize the Gemini Developer API backend service
    // Create a GenerativeModel instance with a model that supports your use case
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-lite',
    );
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      return response.text ?? 'No response received';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<Map<String, dynamic>?> getAIMove(List<List<String>> board) async {
    try {
      final boardString = _boardToString(board);
      final availableMoves = _getAvailableMoves(board);

      // Debug output - print the board state and available moves
      if (debugMode) {
        print('=== AI MOVE DEBUG ===');
        print('Board state sent to AI:');
        print(boardString);
        print('Available moves: $availableMoves');
        print('Raw board array: $board');
      }

      final prompt =
          '''
You are an expert Tic Tac Toe AI playing as 'O'. Your opponent is 'X'.

CURRENT BOARD STATE:
$boardString

AVAILABLE MOVES: $availableMoves

🏆🏆🏆 PRIORITY DECISION PROTOCOL 🏆🏆🏆

STEP 1: CAN YOU WIN RIGHT NOW?
Look at EVERY ROW, COLUMN, and DIAGONAL for exactly TWO O's with ONE EMPTY SPACE.
If you find this pattern, you can WIN immediately!

WINNING OPPORTUNITIES:
- Row 0: [O O _] or [O _ O] or [_ O O] → PLACE O TO WIN!
- Row 1: [O O _] or [O _ O] or [_ O O] → PLACE O TO WIN!  
- Row 2: [O O _] or [O _ O] or [_ O O] → PLACE O TO WIN!

- Column 0: If positions (0,0), (1,0), (2,0) have two O's → COMPLETE THE WIN!
- Column 1: If positions (0,1), (1,1), (2,1) have two O's → COMPLETE THE WIN!
- Column 2: If positions (0,2), (1,2), (2,2) have two O's → COMPLETE THE WIN!

- Main diagonal (0,0)→(1,1)→(2,2): Two O's here? → WIN NOW!
- Anti diagonal (0,2)→(1,1)→(2,0): Two O's here? → WIN NOW!

🎯 IF YOU CAN WIN: Take the winning move IMMEDIATELY! 🎯

STEP 2: ONLY IF YOU CAN'T WIN, SCAN FOR BLOCKING THREATS
Look at EVERY ROW, COLUMN, and DIAGONAL for exactly TWO X's with ONE EMPTY SPACE.
If you find this pattern, the human will WIN on their next turn!

BLOCKING THREATS:
- Row 0: [X X _] or [X _ X] or [_ X X] → BLOCK THE EMPTY SPACE!
- Row 1: [X X _] or [X _ X] or [_ X X] → BLOCK THE EMPTY SPACE!  
- Row 2: [X X _] or [X _ X] or [_ X X] → BLOCK THE EMPTY SPACE!

- Column 0: If positions (0,0), (1,0), (2,0) have two X's → BLOCK THE EMPTY ONE!
- Column 1: If positions (0,1), (1,1), (2,1) have two X's → BLOCK THE EMPTY ONE!
- Column 2: If positions (0,2), (1,2), (2,2) have two X's → BLOCK THE EMPTY ONE!

- Main diagonal (0,0)→(1,1)→(2,2): Two X's here? → BLOCK THE EMPTY SPOT!
- Anti diagonal (0,2)→(1,1)→(2,0): Two X's here? → BLOCK THE EMPTY SPOT!

🛑 IF ANY THREAT FOUND: Choose that blocking position IMMEDIATELY! 🛑

STEP 3: ONLY IF NO WINS AND NO THREATS, choose strategically:
- Center (1,1) is strongest
- Corners (0,0), (0,2), (2,0), (2,2) are good
- Edges (0,1), (1,0), (1,2), (2,1) are last resort

RESPOND with ONLY this JSON format (no other text):
{"row": [0-2], "col": [0-2], "taunt": "your comment"}

REMEMBER: 1st WIN if possible, 2nd BLOCK if necessary, 3rd choose strategically!
Your move MUST be one of: $availableMoves
''';

      if (debugMode) {
        print('Prompt sent to AI:');
        print(prompt);
        print('=====================');
      }

      final response = await _model.generateContent([Content.text(prompt)]);
      final responseText = response.text?.trim() ?? '';

      if (debugMode) {
        print('AI Raw Response: $responseText');
      }

      // Try to extract JSON from the response
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = responseText.substring(jsonStart, jsonEnd);
        if (debugMode) {
          print('Extracted JSON: $jsonString');
        }

        final decodedResponse = json.decode(jsonString) as Map<String, dynamic>;

        // Validate the move
        final row = decodedResponse['row'] as int?;
        final col = decodedResponse['col'] as int?;

        if (row != null &&
            col != null &&
            row >= 0 &&
            row <= 2 &&
            col >= 0 &&
            col <= 2 &&
            board[row][col] == '-') {
          if (debugMode) {
            print('Valid AI move: ($row, $col)');
          }
          return decodedResponse;
        } else {
          if (debugMode) {
            print(
              'Invalid AI move: ($row, $col) - position may be occupied or out of bounds',
            );
            print(
              'Board at position [$row][$col]: ${row != null && col != null ? board[row][col] : 'N/A'}',
            );
          }

          // Fallback: return a strategic move
          final fallbackMove = _getFallbackMove(board);
          if (fallbackMove != null) {
            if (debugMode) {
              print('Using fallback move: ${fallbackMove}');
            }
            return fallbackMove;
          }
          return null;
        }
      }

      if (debugMode) {
        print('Failed to extract valid JSON from response');
      }

      // Fallback: return a strategic move
      final fallbackMove = _getFallbackMove(board);
      if (fallbackMove != null) {
        if (debugMode) {
          print(
            'Using fallback move due to JSON parsing failure: ${fallbackMove}',
          );
        }
        return fallbackMove;
      }

      return null;
    } catch (e) {
      print('Error getting AI move: $e');
      return null;
    }
  }

  Future<String> generateTauntResponse(String playerTaunt) async {
    try {
      final prompt =
          '''
The player just taunted you in a Tic Tac Toe game with: "$playerTaunt"

Respond with a short, witty, playful comeback. Keep it fun and lighthearted, not mean or offensive. 
Make it about the game of Tic Tac Toe. Maximum 2 sentences.
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.trim() ?? 'I\'ll let my moves do the talking!';
    } catch (e) {
      return 'Nice try, but I\'m focused on winning!';
    }
  }

  String _boardToString(List<List<String>> board) {
    final buffer = StringBuffer();

    // Add column headers
    buffer.writeln('    0   1   2');
    buffer.writeln('  -----------');

    for (int i = 0; i < board.length; i++) {
      // Add row index
      buffer.write('$i | ');

      // Add cell values with better spacing
      for (int j = 0; j < board[i].length; j++) {
        final cell = board[i][j] == '-' ? ' ' : board[i][j];
        buffer.write(cell);
        if (j < board[i].length - 1) {
          buffer.write(' | ');
        }
      }
      buffer.writeln();

      if (i < board.length - 1) {
        buffer.writeln('  -----------');
      }
    }
    return buffer.toString();
  }

  List<String> _getAvailableMoves(List<List<String>> board) {
    final availableMoves = <String>[];
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] == '-') {
          availableMoves.add('($row,$col)');
        }
      }
    }
    return availableMoves;
  }

  Map<String, dynamic>? _getFallbackMove(List<List<String>> board) {
    // Priority order: center, corners, edges
    final priorities = [
      [1, 1], // center
      [0, 0], [0, 2], [2, 0], [2, 2], // corners
      [0, 1], [1, 0], [1, 2], [2, 1], // edges
    ];

    for (final position in priorities) {
      final row = position[0];
      final col = position[1];
      if (board[row][col] == '-') {
        return {'row': row, 'col': col, 'taunt': 'Strategic fallback move!'};
      }
    }

    // If no priority moves available, take any available move
    for (int row = 0; row < board.length; row++) {
      for (int col = 0; col < board[row].length; col++) {
        if (board[row][col] == '-') {
          return {
            'row': row,
            'col': col,
            'taunt': 'Any move is better than no move!',
          };
        }
      }
    }

    return null; // Board is full
  }

  void dispose() {
    // Clean up if needed
  }
}
