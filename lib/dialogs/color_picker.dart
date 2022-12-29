import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../impls/player.dart';

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
