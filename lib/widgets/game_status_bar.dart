import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class GameStatusBar extends StatelessWidget {
  const GameStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusCard('💣', '${gameProvider.remainingMines}', '剩余地雷'),
              _buildGameStatusIcon(gameProvider.gameState),
              _buildStatusCard('⏱️', '${gameProvider.gameTime}s', '游戏时间'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(String icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildGameStatusIcon(GameState gameState) {
    String emoji;
    String status;
    
    switch (gameState) {
      case GameState.playing:
        emoji = '😊';
        status = '游戏中';
        break;
      case GameState.won:
        emoji = '😎';
        status = '胜利！';
        break;
      case GameState.lost:
        emoji = '😵';
        status = '失败';
        break;
      case GameState.ready:
        emoji = '🙂';
        status = '准备开始';
        break;
    }
    
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(status, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
} 