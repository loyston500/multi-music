import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'impls/player.dart';
import 'package:just_audio/just_audio.dart';

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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var players = List.generate(3, (index) => Player());

  Future<void> playerColorPickerDialog(BuildContext context, Player player) {
    return showDialog(
        context: context,
        builder: ((context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: BlockPicker(
              pickerColor: Color(player.color ?? Colors.pink.value),
              onColorChanged: (color) {
                player.color = color.value;
              },
            )),
            actions: [
              TextButton(
                  onPressed: (() {
                    Navigator.of(context).pop();
                  }),
                  child: const Text("Done")),
            ],
          );
        }));
  }

  Future<void> playerSettingsDialog(BuildContext context, Player player) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setSettingsDialogState) {
            return AlertDialog(
              content: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: player.name ?? "None",
                        validator: (value) {
                          if (value!.isEmpty) return "Name cannot be empty";
                          if (value.length > 10) return "Max length is 10";
                          player.name = value;
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: "Name",
                          labelText: "Name",
                        ),
                      ),
                      TextFormField(
                        initialValue: "${player.position.inSeconds}",
                        validator: (value) {
                          try {
                            var intValue = int.parse(value!);
                            if (intValue > player.duration!.inSeconds) {
                              return "Greater than song duration";
                            }
                            player.setClip(
                                start: Duration(seconds: intValue),
                                end: player.duration);
                          } on FormatException {
                            return "Not a valid number";
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: "Ex: 5",
                          labelText: "Start from",
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Loop"),
                          Checkbox(
                              value: player.loop,
                              onChanged: ((value) {
                                setSettingsDialogState(() {
                                  player.loop = value!;
                                  if (value) {
                                    player.setLoopMode(LoopMode.one);
                                  } else {
                                    player.setLoopMode(LoopMode.off);
                                  }
                                });
                              })),
                        ],
                      ),
                      Slider(
                          value: player.volume * 100,
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: "${(player.volume * 100).round()}%",
                          onChanged: (value) {
                            setSettingsDialogState(
                              () {
                                player.setVolume(value / 100);
                              },
                            );
                          }),
                      Slider(
                          value: player.speed,
                          min: 0,
                          max: 2,
                          divisions: 20,
                          label: "${player.speed.toStringAsFixed(2)}x",
                          semanticFormatterCallback: (value) {
                            return "${value}";
                          },
                          onChanged: (value) {
                            setSettingsDialogState(
                              () {
                                player.setSpeed(value);
                              },
                            );
                          }),
                      TextButton(
                          onPressed: () async {
                            await playerColorPickerDialog(context, player);
                            setSettingsDialogState(() {});
                          },
                          child: Text(
                            "Pick Color",
                            style: TextStyle(
                                color:
                                    Color(player.color ?? Colors.pink.value)),
                          )),
                      TextButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.audio);
                            setSettingsDialogState(() {
                              if (result != null) {
                                player.setUrl(result.files.single.path!);
                                player.url = result.files.single.path;
                              }
                            });
                          },
                          child: const Text("Select Song")),
                      Text("File: ${player.url ?? 'Not selected'}"),
                    ],
                  ))),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            player.dispose();
                            players.remove(player);
                            Navigator.of(context).pop();
                          });
                        },
                        icon: const Icon(Icons.delete)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            var index = players.indexOf(player);
                            if (index > 0) {
                              players.remove(player);
                              players.insert(index - 1, player);
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_back)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            var index = players.indexOf(player);
                            if (index < players.length - 1) {
                              players.remove(player);
                              players.insert(index + 1, player);
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        icon: const Icon(Icons.arrow_forward)),
                    IconButton(
                        onPressed: () {
                          setState(() {
                            var new_player = Player();
                            new_player.color = player.color;
                            new_player.name = player.name;
                            players.insert(
                                players.indexOf(player) + 1, new_player);
                            Navigator.of(context).pop();
                          });
                        },
                        icon: const Icon(Icons.copy)),
                  ],
                )
              ],
            );
          }));
        });
  }

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
                  color: player.playing ? Color(player.color ?? 0) : Color(0),
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
                var song = player.play();
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
              await playerSettingsDialog(context, player);
              setState(() {});
            },
          )));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
