enum GameState { ready, playing, won, lost }

class Cell {
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  Cell({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}

class GameConfig {
  final int boardSize;
  final int mineCount;
  final String name;

  const GameConfig({
    required this.boardSize,
    required this.mineCount,
    required this.name,
  });

  static const easy = GameConfig(boardSize: 8, mineCount: 10, name: '简单 (8x8, 10雷)');
  static const medium = GameConfig(boardSize: 10, mineCount: 15, name: '中等 (10x10, 15雷)');
  static const hard = GameConfig(boardSize: 12, mineCount: 25, name: '困难 (12x12, 25雷)');
  
  static const List<GameConfig> all = [easy, medium, hard];
} 