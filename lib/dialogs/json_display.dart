import 'package:flutter/material.dart';

Future<void> JsonDisplayDialog(BuildContext context, String encoded) {
  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setJsonDisplayDialogState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(encoded),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () {}, child: const Text("SAVE TO FILE")),
                    TextButton(onPressed: () {}, child: const Text("COPY")),
                  ],
                ),
              ],
            ),
          );
        });
      });
}
