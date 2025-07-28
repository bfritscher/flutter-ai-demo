enum GamePlayer { x, o, none }

enum GameState { playing, xWin, oWin, draw }

class TicTacToeGame {
  List<List<GamePlayer>> _board = [];
  GamePlayer _currentPlayer = GamePlayer.x;
  GameState _gameState = GameState.playing;

  TicTacToeGame() {
    _initializeBoard();
  }

  void _initializeBoard() {
    _board = List.generate(3, (_) => List.filled(3, GamePlayer.none));
  }

  List<List<GamePlayer>> get board => _board;
  GamePlayer get currentPlayer => _currentPlayer;
  GameState get gameState => _gameState;

  bool makeMove(int row, int col) {
    if (row < 0 || row >= 3 || col < 0 || col >= 3) return false;
    if (_board[row][col] != GamePlayer.none) return false;
    if (_gameState != GameState.playing) return false;

    _board[row][col] = _currentPlayer;
    _checkGameState();

    if (_gameState == GameState.playing) {
      _currentPlayer = _currentPlayer == GamePlayer.x
          ? GamePlayer.o
          : GamePlayer.x;
    }

    return true;
  }

  void _checkGameState() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_board[i][0] != GamePlayer.none &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        _gameState = _board[i][0] == GamePlayer.x
            ? GameState.xWin
            : GameState.oWin;
        return;
      }
    }

    // Check columns
    for (int j = 0; j < 3; j++) {
      if (_board[0][j] != GamePlayer.none &&
          _board[0][j] == _board[1][j] &&
          _board[1][j] == _board[2][j]) {
        _gameState = _board[0][j] == GamePlayer.x
            ? GameState.xWin
            : GameState.oWin;
        return;
      }
    }

    // Check diagonals
    if (_board[0][0] != GamePlayer.none &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      _gameState = _board[0][0] == GamePlayer.x
          ? GameState.xWin
          : GameState.oWin;
      return;
    }

    if (_board[0][2] != GamePlayer.none &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      _gameState = _board[0][2] == GamePlayer.x
          ? GameState.xWin
          : GameState.oWin;
      return;
    }

    // Check for draw
    bool boardFull = true;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == GamePlayer.none) {
          boardFull = false;
          break;
        }
      }
      if (!boardFull) break;
    }

    if (boardFull) {
      _gameState = GameState.draw;
    }
  }

  void resetGame() {
    _initializeBoard();
    _currentPlayer = GamePlayer.x;
    _gameState = GameState.playing;
  }

  List<List<String>> getBoardAsStrings() {
    return _board
        .map(
          (row) => row.map((cell) {
            switch (cell) {
              case GamePlayer.x:
                return 'X';
              case GamePlayer.o:
                return 'O';
              case GamePlayer.none:
                return '-';
            }
          }).toList(),
        )
        .toList();
  }

  String getGameStateMessage() {
    switch (_gameState) {
      case GameState.xWin:
        return 'You Win! 🎉';
      case GameState.oWin:
        return 'AI Wins! 🤖';
      case GameState.draw:
        return 'It\'s a Draw! 🤝';
      case GameState.playing:
        return _currentPlayer == GamePlayer.x ? 'Your Turn' : 'AI\'s Turn';
    }
  }
}
