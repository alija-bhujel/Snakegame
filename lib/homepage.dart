import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snakegame/blankpixel.dart';
import 'package:snakegame/foodpixel.dart';
import 'package:snakegame/high_scoretile.dart';
import 'package:snakegame/snakepixel.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

enum snake_direction { UP, DOWN, LEFT, RIGHT }

class _HomepageState extends State<Homepage> {
  //grid dimensions

  int rowsize = 10;
  int totalNoSquares = 100;

  //game settings
  bool gamehasStarted = false;
  final _nameController = TextEditingController();

  //user_score
  int currentScore = 0;

  //snake positions
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  //snake_direction
  var currentDirection = snake_direction.RIGHT;

  //food positions
  int foodPos = 55;

  // highscore list
  List<String> highscore_DocIds = [];
  late final Future? letsGetDocIds;

  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscore")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs.forEach((element) {
              highscore_DocIds.add(element.reference.id);
            }));
  }

  //start the game
  void startgame() {
    gamehasStarted = true;
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {
        moveSnake();

        //if game is over
        if (gameOver()) {
          timer.cancel();
          //display a message to the user
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('GameOver'),
                  content: Column(
                    children: [
                      Text('Your score is:' + currentScore.toString()),
                      TextField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(hintText: 'Enter your name'),
                      )
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      onPressed: () {
                        submitScore();
                        Navigator.pop(context);
                        newgame();
                      },
                      child: Text('Submit'),
                      color: Colors.yellow[400],
                    )
                  ],
                );
              });
        }
      });
    });
  }

  void newgame() {
    setState(() {
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos = 55;
      currentDirection = snake_direction.RIGHT;
      gamehasStarted = false;
      currentScore = 0;
    });
  }

  void submitScore() {
    //get access to the collection
    var database = FirebaseFirestore.instance;
    //add to the firebase
    database.collection('highscore').add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  void eatFood() {
    currentScore++;
    //make sure that food is at random position at every time
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(totalNoSquares);
    }
  }

  void moveSnake() {
    switch (currentDirection) {
      case snake_direction.RIGHT:
        {
          // add the head
          //if snake it as a rightwall need to adjust and pass many times on same row
          if (snakePos.last % rowsize == 9) {
            snakePos.add(snakePos.last + 1 - rowsize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
        }
        break;
      case snake_direction.LEFT:
        {
          if (snakePos.last % rowsize == 0) {
            snakePos.add(snakePos.last - 1 + rowsize);
          } else {
            snakePos.add(snakePos.last - 1);
          }
        }
        break;
      case snake_direction.DOWN:
        {
          // add the head
          if (snakePos.last + rowsize > totalNoSquares) {
            snakePos.add(snakePos.last + rowsize - totalNoSquares);
          } else {
            snakePos.add(snakePos.last + rowsize);
          }
        }
        break;
      case snake_direction.UP:
        {
          // add the head
          if (snakePos.last < rowsize) {
            snakePos.add(snakePos.last - rowsize + totalNoSquares);
          } else {
            snakePos.add(snakePos.last - rowsize);
          }
        }
        break;
      default:
    }
    //snake is eating food
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      //remove the tail
      snakePos.removeAt(0);
    }
  }

  bool gameOver() {
    //the game is over when snake runs into itself
    // this occurs when there is a duplicate position in  snakePos list

    //this list is the body of the snake (no head)
    List<int> bodySnake = snakePos.sublist(0, snakePos.length - 1);
    if (bodySnake.contains(snakePos.last)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    //get the screenwidth
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        width: screenWidth > 400 ? 400 : screenWidth,
        child: Column(
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //current score
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'CurrentScore',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        currentScore.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 36),
                      ),
                    ],
                  ),
                ),

                //high scores
                Text(
                  "High scores",
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: FutureBuilder(
                      future: letsGetDocIds,
                      builder: (context, snapshot) {
                        return ListView.builder(
                          itemCount: highscore_DocIds.length,
                          itemBuilder: ((context, index) {
                            return HighScoreTile(
                                documentId: highscore_DocIds[index]);
                          }),
                        );
                      }),
                )
              ],
            )),

            // game grid
            Expanded(
                flex: 3,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy > 0 &&
                        currentDirection != snake_direction.UP) {
                      currentDirection = snake_direction.DOWN;
                    } else if (details.delta.dy < 0 &&
                        currentDirection != snake_direction.DOWN) {
                      currentDirection = snake_direction.UP;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (details.delta.dx > 0 &&
                        currentDirection != snake_direction.LEFT) {
                      currentDirection = snake_direction.RIGHT;
                    } else if (details.delta.dx < 0 &&
                        currentDirection != snake_direction.RIGHT) {
                      currentDirection = snake_direction.LEFT;
                    }
                  },
                  child: GridView.builder(
                      itemCount: totalNoSquares,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: rowsize),
                      itemBuilder: (context, index) {
                        if (snakePos.contains(index)) {
                          return const SnakePixel();
                        } else if (foodPos == index) {
                          return const FoodPixel();
                        } else {
                          return const BlankPixel();
                        }
                        ;
                      }),
                )),

            //play button
            Expanded(
                child: Container(
              child: Center(
                  child: MaterialButton(
                child: Text('PLAY'),
                onPressed: gamehasStarted ? () {} : startgame,
                color: gamehasStarted ? Colors.grey : Colors.yellow[600],
              )),
            ))
          ],
        ),
      ),
    );
  }
}
