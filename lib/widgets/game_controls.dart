import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class GameControls extends StatelessWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              context.read<GameProvider>().startNewGame();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('新游戏'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showDifficultyDialog(context),
            icon: const Icon(Icons.settings),
            label: const Text('难度'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('选择难度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: GameConfig.all.map((config) {
              return ListTile(
                title: Text(config.name),
                onTap: () {
                  Navigator.pop(dialogContext);
                  context.read<GameProvider>().startNewGame(newConfig: config);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
} 