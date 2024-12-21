import 'package:flutter/material.dart';
import '../models/note.dart';

class EditNoteScreen extends StatefulWidget {
  final Note note;
  final Function(String) onSave;

  const EditNoteScreen({
    super.key,
    required this.note,
    required this.onSave,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _controller;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
    _controller.addListener(() {
      setState(() {
        _hasChanges = _controller.text != widget.note.content;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note.timestamp.toString().substring(0, 10),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: () {
                widget.onSave(_controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            autofocus: true,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Start typing...',
            ),
          ),
        ),
      ),
    );
  }
}
