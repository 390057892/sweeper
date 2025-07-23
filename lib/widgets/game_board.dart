import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gameProvider.config.boardSize,
                ),
                itemCount: gameProvider.config.boardSize * gameProvider.config.boardSize,
                itemBuilder: (context, index) {
                  int row = index ~/ gameProvider.config.boardSize;
                  int col = index % gameProvider.config.boardSize;
                  return _buildCell(context, gameProvider, row, col);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCell(BuildContext context, GameProvider gameProvider, int row, int col) {
    Cell cell = gameProvider.board[row][col];
    
    return GestureDetector(
      onTap: () => gameProvider.revealCell(row, col),
      onLongPress: () => gameProvider.toggleFlag(row, col),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 0.8),
          color: _getCellColor(cell),
        ),
        child: Center(
          child: _getCellContent(cell),
        ),
      ),
    );
  }

  Color _getCellColor(Cell cell) {
    if (!cell.isRevealed) {
      return cell.isFlagged ? Colors.yellow[200]! : Colors.grey[300]!;
    }
    
    if (cell.isMine) {
      return Colors.red[400]!;
    }
    
    return Colors.white;
  }

  Widget _getCellContent(Cell cell) {
    if (cell.isFlagged && !cell.isRevealed) {
      return const Text('🚩', style: TextStyle(fontSize: 16));
    }
    
    if (!cell.isRevealed) {
      return const SizedBox();
    }
    
    if (cell.isMine) {
      return const Text('💣', style: TextStyle(fontSize: 16));
    }
    
    if (cell.adjacentMines > 0) {
      return Text(
        '${cell.adjacentMines}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: _getNumberColor(cell.adjacentMines),
        ),
      );
    }
    
    return const SizedBox();
  }

  Color _getNumberColor(int number) {
    switch (number) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.red;
      case 4: return Colors.purple;
      case 5: return Colors.orange;
      case 6: return Colors.pink;
      case 7: return Colors.black;
      case 8: return Colors.grey;
      default: return Colors.black;
    }
  }
} 