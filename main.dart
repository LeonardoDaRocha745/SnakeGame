import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: jogoCobrinha(),
    );
  }
}

class jogoCobrinha extends StatefulWidget {
  @override
  _jogoCobrinhaState createState() => _jogoCobrinhaState();
}

class _jogoCobrinhaState extends State<jogoCobrinha> {
  final int pixelsLinha = 20;
  final int pixelsColuna = 40;
  final fontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final randomGen = Random();

  var cobra = [
    [0, 1],
    [0, 0]
  ];
  var comida = [0, 2];
  var controle = 'cima';
  var jgnd = false;

  void inicio() {
    const duracao = Duration(milliseconds: 300);

    cobra = [
      // Snake head
      [(pixelsLinha / 2).floor(), (pixelsColuna / 2).floor()]
    ];

    cobra.add([cobra.first[0], cobra.first[1] + 1]); // Snake body

    gerarComida();

    jgnd = true;
    Timer.periodic(duracao, (Timer timer) {
      movimentacao();
      if (checkfim()) {
        timer.cancel();
        fim();
      }
    });
  }

  void movimentacao() {
    setState(() {
      switch (controle) {
        case 'cima':
          cobra.insert(0, [cobra.first[0], cobra.first[1] - 1]);
          break;

        case 'baixo':
          cobra.insert(0, [cobra.first[0], cobra.first[1] + 1]);
          break;

        case 'esquerda':
          cobra.insert(0, [cobra.first[0] - 1, cobra.first[1]]);
          break;

        case 'direita':
          cobra.insert(0, [cobra.first[0] + 1, cobra.first[1]]);
          break;
      }

      if (cobra.first[0] != comida[0] || cobra.first[1] != comida[1]) {
        cobra.removeLast();
      } else {
        gerarComida();
      }
    });
  }

  void gerarComida() {
    comida = [randomGen.nextInt(pixelsLinha), randomGen.nextInt(pixelsColuna)];
  }

  bool checkfim() {
    if (!jgnd ||
        cobra.first[1] < 0 ||
        cobra.first[1] >= pixelsColuna ||
        cobra.first[0] < 0 ||
        cobra.first[0] > pixelsLinha) {
      return true;
    }

    for (var i = 1; i < cobra.length; ++i) {
      if (cobra[i][0] == cobra.first[0] && cobra[i][1] == cobra.first[1]) {
        return true;
      }
    }

    return false;
  }

  void fim() {
    jgnd = false;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Fim de jogo'),
            content: Text(
              'Pontuação: ${cobra.length - 2}',
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(48, 58, 98, 255),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (controle != 'cima' && details.delta.dy > 0) {
                  controle = 'baixo';
                } else if (controle != 'baixo' && details.delta.dy < 0) {
                  controle = 'cima';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (controle != 'esquerda' && details.delta.dx > 0) {
                  controle = 'direita';
                } else if (controle != 'direita' && details.delta.dx < 0) {
                  controle = 'esquerda';
                }
              },
              child: AspectRatio(
                aspectRatio: pixelsLinha / (pixelsColuna + 5),
                child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: pixelsLinha,
                    ),
                    itemCount: pixelsLinha * pixelsColuna,
                    itemBuilder: (BuildContext context, int index) {
                      var color;
                      var x = index % pixelsLinha;
                      var y = (index / pixelsLinha).floor();

                      bool corpo = false;
                      for (var pos in cobra) {
                        if (pos[0] == x && pos[1] == y) {
                          corpo = true;
                          break;
                        }
                      }

                      if (cobra.first[0] == x && cobra.first[1] == y) {
                        color = Colors.white;
                      } else if (corpo) {
                        color = Colors.white;
                      } else if (comida[0] == x && comida[1] == y) {
                        color = Colors.red;
                      } else {
                        color = Colors.grey[800];
                      }

                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      );
                    }),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                      color: jgnd ? Colors.red : Color.fromRGBO(48, 58, 98, 1),
                      child: Text(
                        jgnd ? 'Fim' : 'Começar',
                        style: fontStyle,
                      ),
                      onPressed: () {
                        if (jgnd) {
                          jgnd = false;
                        } else {
                          inicio();
                        }
                      }),
                  Text(
                    'Pontuação: ${cobra.length - 2}',
                    style: fontStyle,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
