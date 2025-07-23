import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/game_status_bar.dart';
import '../widgets/game_board.dart';
import '../widgets/game_controls.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    // 设置游戏结束回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().onGameEnd = _showGameEndDialog;
    });
  }

  void _showGameEndDialog(GameState gameState) {
    String title;
    String message;
    IconData icon;
    Color color;

    if (gameState == GameState.won) {
      title = '🎉 恭喜！';
      message = 'Congratulations! You Win!';
      icon = Icons.celebration;
      color = Colors.green;
    } else {
      title = '💥 游戏结束';
      message = 'Game Over';
      icon = Icons.sentiment_dissatisfied;
      color = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<GameProvider>().startNewGame();
              },
              child: const Text('新游戏'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('继续查看'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          '扫雷小游戏',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: const Column(
        children: [
          // 游戏状态栏
          GameStatusBar(),
          
          // 游戏棋盘
          Expanded(
            child: Center(
              child: GameBoard(),
            ),
          ),
          
          // 控制按钮
          GameControls(),
        ],
      ),
    );
  }
} 