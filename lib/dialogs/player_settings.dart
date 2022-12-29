import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../impls/player.dart';
import 'color_picker.dart';

Future<void> playerSettingsDialog(BuildContext context, Player player,
    Key formKey, List<Player> players, Function setState) {
  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: ((context, setSettingsDialogState) {
          return AlertDialog(
            content: Form(
                key: formKey,
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
                          return "value";
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
                              color: Color(player.color ?? Colors.pink.value)),
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
                        // ignore: invalid_use_of_protected_member
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
                          var newPlayer = Player();
                          newPlayer.color = player.color;
                          newPlayer.name = player.name;
                          players.insert(
                              players.indexOf(player) + 1, newPlayer);
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
