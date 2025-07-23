import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import '../models/game_models.dart';

class GameProvider extends ChangeNotifier {
  late List<List<Cell>> _board;
  late GameConfig _config;
  late GameState _gameState;
  late int _flagCount;
  late int _revealedCount;
  late DateTime _startTime;
  late int _gameTime;
  Timer? _timer;
  Function(GameState)? onGameEnd;

  // Getters
  List<List<Cell>> get board => _board;
  GameConfig get config => _config;
  GameState get gameState => _gameState;
  int get flagCount => _flagCount;
  int get gameTime => _gameTime;
  int get remainingMines => _config.mineCount - _flagCount;

  GameProvider({GameConfig? initialConfig}) {
    _config = initialConfig ?? GameConfig.medium;
    _initializeGame();
  }

  void _initializeGame() {
    _gameState = GameState.ready;
    _flagCount = 0;
    _revealedCount = 0;
    _gameTime = 0;
    _startTime = DateTime.now();
    
    // 初始化棋盘
    _board = List.generate(
      _config.boardSize,
      (i) => List.generate(_config.boardSize, (j) => Cell()),
    );

    // 第一次点击时才放置地雷，确保第一次点击安全
    
    notifyListeners();
  }

  void _placeMines() {
    Random random = Random();
    int minesPlaced = 0;
    
    while (minesPlaced < _config.mineCount) {
      int row = random.nextInt(_config.boardSize);
      int col = random.nextInt(_config.boardSize);
      
      if (!_board[row][col].isMine) {
        _board[row][col].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _placeMinesAvoidingCell(int avoidRow, int avoidCol) {
    Random random = Random();
    int minesPlaced = 0;
    
    // 创建需要避开的位置列表（第一次点击位置及其周围8个格子）
    Set<String> avoidPositions = {};
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = avoidRow + i;
        int newCol = avoidCol + j;
        if (newRow >= 0 && newRow < _config.boardSize && 
            newCol >= 0 && newCol < _config.boardSize) {
          avoidPositions.add('$newRow,$newCol');
        }
      }
    }
    
    while (minesPlaced < _config.mineCount) {
      int row = random.nextInt(_config.boardSize);
      int col = random.nextInt(_config.boardSize);
      
      if (!_board[row][col].isMine && !avoidPositions.contains('$row,$col')) {
        _board[row][col].isMine = true;
        minesPlaced++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int i = 0; i < _config.boardSize; i++) {
      for (int j = 0; j < _config.boardSize; j++) {
        if (!_board[i][j].isMine) {
          _board[i][j].adjacentMines = _countAdjacentMines(i, j);
        }
      }
    }
  }

  int _countAdjacentMines(int row, int col) {
    int count = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        
        if (newRow >= 0 && newRow < _config.boardSize && 
            newCol >= 0 && newCol < _config.boardSize) {
          if (_board[newRow][newCol].isMine) {
            count++;
          }
        }
      }
    }
    return count;
  }

  void revealCell(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) {
      return;
    }
    
    if (_board[row][col].isRevealed || _board[row][col].isFlagged) {
      return;
    }

    if (_gameState == GameState.ready) {
      // 第一次点击时放置地雷，确保第一次点击的位置安全
      _placeMinesAvoidingCell(row, col);
      _calculateAdjacentMines();
      
      _gameState = GameState.playing;
      _startTime = DateTime.now();
      _startTimer();
    }

    _board[row][col].isRevealed = true;
    _revealedCount++;
    
    if (_board[row][col].isMine) {
      _gameState = GameState.lost;
      _revealAllMines();
      _stopTimer();
      notifyListeners();
      onGameEnd?.call(GameState.lost);
      return;
    }

    // 如果是空格子，自动揭开周围的格子
    if (_board[row][col].adjacentMines == 0) {
      _revealAdjacentCells(row, col);
    }

    // 检查胜利条件
    _checkWinCondition();
    
    notifyListeners();
  }

  void _revealAdjacentCells(int row, int col) {
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newRow = row + i;
        int newCol = col + j;
        
        if (newRow >= 0 && newRow < _config.boardSize && 
            newCol >= 0 && newCol < _config.boardSize) {
          if (!_board[newRow][newCol].isRevealed && !_board[newRow][newCol].isFlagged) {
            revealCell(newRow, newCol);
          }
        }
      }
    }
  }

  void _revealAllMines() {
    for (int i = 0; i < _config.boardSize; i++) {
      for (int j = 0; j < _config.boardSize; j++) {
        if (_board[i][j].isMine) {
          _board[i][j].isRevealed = true;
        }
      }
    }
  }

  void toggleFlag(int row, int col) {
    if (_gameState == GameState.won || _gameState == GameState.lost) {
      return;
    }
    
    if (_board[row][col].isRevealed) {
      return;
    }

    if (_gameState == GameState.ready) {
      // 第一次操作时放置地雷，确保第一次点击的位置安全
      _placeMinesAvoidingCell(row, col);
      _calculateAdjacentMines();
      
      _gameState = GameState.playing;
      _startTime = DateTime.now();
      _startTimer();
    }

    _board[row][col].isFlagged = !_board[row][col].isFlagged;
    _flagCount += _board[row][col].isFlagged ? 1 : -1;
    
    notifyListeners();
  }

  void _checkWinCondition() {
    int totalCells = _config.boardSize * _config.boardSize;
    if (_revealedCount == totalCells - _config.mineCount) {
      _gameState = GameState.won;
      _stopTimer();
      onGameEnd?.call(GameState.won);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState == GameState.playing) {
        _updateGameTime();
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _updateGameTime() {
    if (_gameState == GameState.playing) {
      _gameTime = DateTime.now().difference(_startTime).inSeconds;
    }
  }

  void startNewGame({GameConfig? newConfig}) {
    _stopTimer();
    if (newConfig != null) {
      _config = newConfig;
    }
    _initializeGame();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
} 