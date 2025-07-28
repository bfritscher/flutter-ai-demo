import 'package:flutter/material.dart';
import '../models/game_logic.dart';
import '../services/gemini_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TicTacToeGame _game = TicTacToeGame();
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _tauntController = TextEditingController();

  bool _isAIThinking = false;
  String _aiTaunt = '';
  String _aiResponse = '';
  final List<String> _gameHistory = [];

  @override
  void dispose() {
    _tauntController.dispose();
    _geminiService.dispose();
    super.dispose();
  }

  void _onCellTapped(int row, int col) async {
    if (_game.gameState != GameState.playing ||
        _game.currentPlayer != GamePlayer.x) {
      return;
    }

    if (_game.makeMove(row, col)) {
      setState(() {
        _gameHistory.add('You played at ($row, $col)');
      });

      if (_game.gameState == GameState.playing) {
        await _makeAIMove();
      }

      setState(() {});
    }
  }

  Future<void> _makeAIMove() async {
    setState(() {
      _isAIThinking = true;
      _aiTaunt = '';
    });

    try {
      final aiMove = await _geminiService.getAIMove(_game.getBoardAsStrings());

      if (aiMove != null &&
          aiMove.containsKey('row') &&
          aiMove.containsKey('col')) {
        final row = aiMove['row'] as int;
        final col = aiMove['col'] as int;

        if (_game.makeMove(row, col)) {
          setState(() {
            _gameHistory.add('AI played at ($row, $col)');
            _aiTaunt = aiMove['taunt'] as String? ?? '';
          });
        }
      } else {
        // Fallback to random move if AI response is invalid
        _makeRandomAIMove();
      }
    } catch (e) {
      // Fallback to random move on error
      _makeRandomAIMove();
    }

    setState(() {
      _isAIThinking = false;
    });
  }

  void _makeRandomAIMove() {
    final emptyCells = <List<int>>[];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_game.board[i][j] == GamePlayer.none) {
          emptyCells.add([i, j]);
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final randomMove =
          emptyCells[DateTime.now().millisecond % emptyCells.length];
      _game.makeMove(randomMove[0], randomMove[1]);
      setState(() {
        _gameHistory.add('AI played at (${randomMove[0]}, ${randomMove[1]})');
        _aiTaunt = 'Let me think... there!';
      });
    }
  }

  Future<void> _sendTaunt() async {
    final taunt = _tauntController.text.trim();
    if (taunt.isEmpty) return;

    _tauntController.clear();

    setState(() {
      _gameHistory.add('You: "$taunt"');
    });

    try {
      final response = await _geminiService.generateTauntResponse(taunt);
      setState(() {
        _aiResponse = response;
        _gameHistory.add('AI: "$response"');
      });
    } catch (e) {
      setState(() {
        _aiResponse = 'I\'ll let my moves do the talking!';
        _gameHistory.add('AI: "I\'ll let my moves do the talking!"');
      });
    }
  }

  void _resetGame() {
    setState(() {
      _game.resetGame();
      _aiTaunt = '';
      _aiResponse = '';
      _gameHistory.clear();
      _isAIThinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe vs AI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _game.getGameStateMessage(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _game.gameState == GameState.xWin
                                ? Colors.green
                                : _game.gameState == GameState.oWin
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    if (_isAIThinking) ...[
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('AI is thinking...'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Game Board
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: List.generate(3, (row) {
                        return Expanded(
                          child: Row(
                            children: List.generate(3, (col) {
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => _onCellTapped(row, col),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: _buildCellContent(row, col),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI Taunt Display
            if (_aiTaunt.isNotEmpty)
              Card(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _aiTaunt,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // AI Response Display
            if (_aiResponse.isNotEmpty)
              Card(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _aiResponse,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Taunt Input
            if (_game.gameState == GameState.playing)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Taunt the AI:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tauntController,
                              decoration: const InputDecoration(
                                hintText: 'Type your taunt...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (_) => _sendTaunt(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _sendTaunt,
                            icon: const Icon(Icons.send),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Game History
            if (_gameHistory.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Game History:',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...(_gameHistory.reversed.take(5).map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            entry,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }).toList()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellContent(int row, int col) {
    final player = _game.board[row][col];

    switch (player) {
      case GamePlayer.x:
        return Icon(Icons.close, size: 48, color: Colors.blue);
      case GamePlayer.o:
        return Icon(Icons.radio_button_unchecked, size: 48, color: Colors.red);
      case GamePlayer.none:
        return Container();
    }
  }
}
