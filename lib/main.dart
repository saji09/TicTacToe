import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TicTacToe(),
    );
  }
}

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<List<String>> board = List.generate(3, (_) => List.filled(3, ''));
  String currentPlayer = 'X';
  String? winner;
  TextEditingController playerXController = TextEditingController();
  TextEditingController playerOController = TextEditingController();

  void makeMove(int row, int col) {
    if (board[row][col] == '' && winner == null) {
      setState(() {
        board[row][col] = currentPlayer;
        winner = findWinner();
        if (winner == null) {
          currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
        }
      });
      checkWinner();
    }
  }

  void checkWinner() async {
    if (winner != null) {
      // Send the winner to the Laravel API
      String apiUrl = 'http://127.0.0.1:8000/api/save-winner';
      Map<String, String> body = {'winner': winner!};

      try {
        final response = await http.post(Uri.parse(apiUrl), body: body);

        if (response.statusCode == 200) {
          print('Winner saved successfully');
        } else {
          print('Failed to save winner. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error occurred while saving winner: $e');
      }
    }
  }

  String? findWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != '') {
        return board[i][0];
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != '') {
        return board[0][i];
      }
    }

    // Check diagonals
    if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != '') {
      return board[0][0];
    }

    if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != '') {
      return board[0][2];
    }

    // Check if the board is full (draw)
    if (!board.any((row) => row.any((cell) => cell == ''))) {
      return 'draw';
    }

    // No winner yet
    return null;
  }

  void resetGame() {
    setState(() {
      board = List.generate(3, (_) => List.filled(3, ''));
      currentPlayer = 'X';
      winner = null;
      playerXController.clear();
      playerOController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (winner != null)
              Text(
                'Winner: $winner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Player X:'),
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: TextField(
                    controller: playerXController,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Player O:'),
                SizedBox(width: 10),
                Container(
                  width: 100,
                  child: TextField(
                    controller: playerOController,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            for (int i = 0; i < 3; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 3; j++)
                    GestureDetector(
                      onTap: () => makeMove(i, j),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(),
                        ),
                        child: Center(
                          child: Text(
                            board[i][j],
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetGame,
              child: Text('Reset Game'),
            ),
          ],
        ),
      ),
    );
  }
}
