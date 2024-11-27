import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: SnakeGame(),
      debugShowCheckedModeBanner: false, // Disable the debug banner
    ));

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int rows = 20; // Grid rows
  final int columns = 20; // Grid columns
  List<int> snake = [45, 46, 47]; // Initial snake position
  int food = 55; // Initial food position
  String direction = 'right'; // Initial direction
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        moveSnake();
        checkGameOver();
      });
    });
  }

  void moveSnake() {
    int nextPosition;
    switch (direction) {
      case 'right':
        nextPosition = snake.last + 1;
        break;
      case 'left':
        nextPosition = snake.last - 1;
        break;
      case 'up':
        nextPosition = snake.last - columns;
        break;
      case 'down':
        nextPosition = snake.last + columns;
        break;
      default:
        nextPosition = snake.last;
    }

    // Check for food
    if (nextPosition == food) {
      snake.add(nextPosition); // Grow snake
      generateNewFood();
    } else {
      snake.add(nextPosition);
      snake.removeAt(0); // Move forward
    }
  }

  void generateNewFood() {
    Random random = Random();
    food = random.nextInt(rows * columns);
    while (snake.contains(food)) {
      food = random.nextInt(rows * columns); // Avoid food on snake
    }
  }

  void checkGameOver() {
    if (snake.length != snake.toSet().length || // Check self-collision
        snake.last < 0 || // Check grid boundary
        snake.last >= rows * columns ||
        (direction == 'left' && snake.last % columns == columns - 1) ||
        (direction == 'right' && snake.last % columns == 0)) {
      gameTimer?.cancel();
      showGameOverDialog();
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over'),
        content: Text('Your score: ${snake.length - 3}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      snake = [45, 46, 47];
      direction = 'right';
      food = 55;
      startGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Snake Game made by Jawwad'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0 && direction != 'left') {
            direction = 'right';
          } else if (details.delta.dx < 0 && direction != 'right') {
            direction = 'left';
          }
        },
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 0 && direction != 'up') {
            direction = 'down';
          } else if (details.delta.dy < 0 && direction != 'down') {
            direction = 'up';
          }
        },
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
          ),
          itemCount: rows * columns,
          itemBuilder: (context, index) {
            if (snake.contains(index)) {
              return Container(color: Colors.green); // Snake
            } else if (index == food) {
              return Container(color: Colors.red); // Food
            } else {
              return Container(color: Colors.grey[900]); // Empty cell
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
}
