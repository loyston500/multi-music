import 'dart:convert';
import 'package:toml/toml.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'impls/player.dart';
import 'dialogs/player_settings.dart';
import 'dialogs/json_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Music',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        iconTheme: const IconThemeData(color: Colors.pink),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
        iconTheme: const IconThemeData(color: Colors.pink),
      ),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Multi Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var players = List.generate(3, (index) => Player());

  @override
  Widget build(BuildContext context) {
    var playerWidgets = <Widget>[];
    for (var player in players) {
      playerWidgets.add(AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
              border: Border.all(width: 8, color: Colors.grey.shade800),
              color: Color(player.color ?? 0),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: player.playing
                      ? Color(player.color ?? 0)
                      : const Color(0x00000000),
                  blurRadius: 10,
                ),
              ]),
          child: TextButton(
            child: Text(
              player.name ?? "None",
              style: TextStyle(
                  fontSize: 20, color: Colors.grey.shade800.withOpacity(0.9)),
            ),
            onPressed: () async {
              if (player.playing) {
                setState(() {
                  player.stop();
                });
              } else {
                player.play();
                setState(() {});
                player.playerStateStream.listen((playerState) {
                  if (playerState.processingState ==
                      ProcessingState.completed) {
                    player.stop();
                    setState(() {});
                    player.seek(Duration.zero);
                  }
                });
              }
            },
            onLongPress: () async {
              await playerSettingsDialog(
                  context, player, _formKey, players, setState);
              setState(() {});
            },
          )));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(value: 1, child: Text("Build JSON")),
                  const PopupMenuItem(value: 2, child: Text("Build TOML")),
                  const PopupMenuItem(value: 3, child: Text("Load JSON/TOML")),
                ];
              },
              onSelected: (value) async {
                if (value == 1) {
                  String encoded =
                      const JsonEncoder.withIndent("  ").convert(players);
                  await JsonDisplayDialog(context, encoded);
                } else if (value == 2) {
                  String encoded = TomlDocument.fromMap({
                    "players": [
                      for (var player in players)
                        player.toJson()
                          ..removeWhere((key, value) => value == null)
                    ]
                  }).toString();
                  await JsonDisplayDialog(context, encoded);
                }
              },
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: false,
              children: playerWidgets,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      for (var player in players) {
                        player.play();
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.play_arrow,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      for (var player in players) {
                        player.stop();
                      }
                    });
                  },
                  icon: const Icon(Icons.stop)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (players.length <= 10) {
                        players.add(Player());
                      } else {}
                    });
                  },
                  icon: const Icon(Icons.add)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (players.isNotEmpty) {
                        players.removeLast().dispose();
                      }
                    });
                  },
                  icon: const Icon(Icons.remove)),
            ],
          )
        ]));
  }
}
