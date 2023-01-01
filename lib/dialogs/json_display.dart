import 'package:flutter/material.dart';
import 'package:multi_music/impls/utils.dart';

Future<void> jsonDisplayDialog(
    BuildContext context, String encoded, String fileName) {
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
                        onPressed: () {
                          try {
                            saveFileLocally(fileName, encoded);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "File saved as $fileName in your internal storage"),
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Error saving the file"),
                            ));
                          }
                        },
                        child: const Text("SAVE TO FILE")),
                    TextButton(onPressed: () {}, child: const Text("COPY")),
                  ],
                ),
              ],
            ),
          );
        });
      });
}
