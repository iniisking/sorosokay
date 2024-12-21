import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/note.dart';
import 'edit_note_screen.dart';

class ContentScreen extends StatefulWidget {
  final List<Note> notes;

  const ContentScreen({
    super.key,
    required this.notes,
  });

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  Future<void> _handleRefresh() async {
    // Add any refresh logic here if needed
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  String _getFormattedTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 1) {
      return timeago.format(timestamp);
    } else {
      return timeago.format(timestamp, allowFromNow: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: LiquidPullToRefresh(
          onRefresh: _handleRefresh,
          color: const Color.fromARGB(255, 0, 55, 255),
          height: 100,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          animSpeedFactor: 2,
          showChildOpacityTransition: false,
          child: widget.notes.isEmpty
              ? const Center(
                  child: Text(
                    'No notes yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: widget.notes.length,
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 100,
                    left: 16,
                    right: 16,
                  ),
                  itemBuilder: (context, index) {
                    final note = widget.notes[index];
                    return Dismissible(
                      key: Key(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          widget.notes.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Note deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            note.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getFormattedTime(note.timestamp),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          onTap: () => _editNote(note),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: _createNewNote,
          backgroundColor: const Color.fromARGB(255, 0, 55, 255),
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add,
            size: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _createNewNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          note: Note(
            id: DateTime.now().toString(),
            content: '',
            timestamp: DateTime.now(),
          ),
          onSave: (content) {
            if (content.isNotEmpty) {
              setState(() {
                widget.notes.insert(
                  0,
                  Note(
                    id: DateTime.now().toString(),
                    content: content,
                    timestamp: DateTime.now(),
                  ),
                );
              });
            }
          },
        ),
      ),
    );
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          note: note,
          onSave: (updatedContent) {
            setState(() {
              note.content = updatedContent;
            });
          },
        ),
      ),
    );
  }
}
