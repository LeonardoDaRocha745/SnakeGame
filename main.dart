import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Jogo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Jogo extends StatefulWidget {
  const Jogo({Key? key}) : super(key: key);

  @override
  _JogoState createState() => _JogoState();
}

class _JogoState extends State<Jogo> {
  @override
  final int pixelsLinha = 40;
  final int pixelsColuna = 20;
  final FontStyle = TextStyle(color: Colors.white, fontSize: 20);
  final geradorAleatorio = Random();
  var cobrinha = [
    [0, 1],
    [0, 0]
  ];
  var comida = [0, 2];
  var direcao = "cima";
  var jgnd = false;

  void iniciar() {
    const duracao = Duration(milliseconds: 200);
    cobrinha = [
      [(pixelsLinha / 2).floor(), (pixelsColuna / 2).floor()],
    ];

    cobrinha.add([cobrinha.first[0], cobrinha.first[1] + 1]);

    criarmaca();

    jgnd = true;
    Timer.periodic(duracao, (timer) {
      Movimentacao();
      if (verificarfim()) {
        timer.cancel();
        fim();
      }
    });
  }

  void Movimentacao() {
    setState(() {
      switch (direcao) {
        case 'cima':
          cobrinha.insert(0, [cobrinha.first[0], cobrinha.first[1] - 1]);
          break;
        case 'baixo':
          cobrinha.insert(0, [cobrinha.first[0], cobrinha.first[1] + 1]);
          break;
        case 'esquerda':
          cobrinha.insert(0, [cobrinha.first[0] - 1, cobrinha.first[1]]);
          break;
        case 'direita':
          cobrinha.insert(0, [cobrinha.first[0] + 1, cobrinha.first[1]]);
          break;
      }
      if (cobrinha.first[0] != comida[0] || cobrinha.first[1] != comida[1]) {
        cobrinha.removeLast();
      } else {
        criarmaca();
      }
    });
  }

  void criarmaca() {
    comida = [
      geradorAleatorio.nextInt(pixelsLinha),
      geradorAleatorio.nextInt(pixelsColuna)
    ];
  }

  bool verificarfim() {
    if (!jgnd ||
        cobrinha.first[1] < 0 ||
        cobrinha.first[1] >= pixelsColuna ||
        cobrinha.first[0] < 0 ||
        cobrinha.first[0] > pixelsLinha) {
      return true;
    }

    for (var i = 1; i < cobrinha.length; ++i) {
      if (cobrinha[i][0] == cobrinha.first[0] &&
          cobrinha[i][1] == cobrinha.first[1]) {
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
            title: Text('Você perdeu'),
            content: Text(
              'Pontuação: ${cobrinha.length - 2}',
              style: TextStyle(fontSize: 20),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('fechar'),
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
      backgroundColor: Color.fromRGBO(39, 60, 90, 1),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direcao != 'cima' && details.delta.dy > 0) {
                  direcao = 'baixo';
                } else if (direcao != 'baixo' && details.delta.dy < 0) {
                  direcao = 'cima';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direcao != 'esquerda' && details.delta.dx > 0) {
                  direcao = 'direita';
                } else if (direcao != 'direita' && details.delta.dx < 0) {
                  direcao = 'esquerda';
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

                      bool cobrinhacorpo = false;
                      for (var pos in cobrinha) {
                        if (pos[0] == x && pos[1] == y) {
                          cobrinhacorpo = true;
                          break;
                        }
                      }

                      if (cobrinha.first[0] == x && cobrinha.first[1] == y) {
                        color = Colors.black;
                      } else if (cobrinhacorpo) {
                        color = Colors.black;
                      } else if (comida[0] == x && comida[1] == y) {
                        color = Colors.red;
                      } else {
                        color = Color.fromRGBO(19, 83, 34, 1);
                      }

                      return Container(
                        margin: EdgeInsets.all(0),
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.rectangle),
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
                      color: jgnd ? Colors.grey[400] : Colors.grey[400],
                      child: Text(
                        jgnd ? 'Parar' : 'Começar',
                        style: FontStyle,
                      ),
                      onPressed: () {
                        if (jgnd) {
                          jgnd = false;
                        } else {
                          iniciar();
                        }
                      }),
                  Text(
                    'Score: ${cobrinha.length - 2}',
                    style: FontStyle,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
