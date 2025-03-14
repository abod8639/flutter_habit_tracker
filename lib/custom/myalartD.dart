import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Myalartd extends StatefulWidget {
  final Function()? onSave;
  final String? hintText;
  final TextEditingController controller;

  const Myalartd({
    this.onSave,
    this.hintText,
    required this.controller,
    super.key,
  });

  @override
  _MyalartdState createState() => _MyalartdState();
}

class _MyalartdState extends State<Myalartd> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      content: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
              if (event.isControlPressed) {
                // Add a new line when user presses Ctrl+Enter
                final currentText = widget.controller.text;
                final currentPosition = widget.controller.selection.base.offset;
                
                // Insert a newline at the current cursor position
                final newText = '${currentText.substring(0, currentPosition)}\n${currentText.substring(currentPosition)}';
                
                // Update the text and cursor position
                widget.controller.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(
                    offset: currentPosition + 1,
                  ),
                );
              } else {
                // Execute Add button when user presses Enter
                final text = widget.controller.text.trim();
                if (text.isNotEmpty) {
                  widget.onSave?.call();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      duration: const Duration(seconds: 2),
                      content: const Center(
                        child: Text(
                          "The field can't be empty :)",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                }
              }
            }
          }
        },
        child: TextFormField(
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondary),
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            focusColor: Theme.of(context).colorScheme.onSecondary,
            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
          ),
          autofocus: true,
          controller: widget.controller,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.controller.clear();
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error.withOpacity(0.8),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            final text = widget.controller.text.trim();
            if (text.isNotEmpty) {
              widget.onSave?.call();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  duration: const Duration(seconds: 2),
                  content: const Center(
                    child: Text(
                      "The field can't be empty :)",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }
          },
          child: Text(
            'Add',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}