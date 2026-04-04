import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/note.dart';
import '../providers/notes_provider.dart';
import 'edit_note_screen.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  Future<void> _handleRefresh() async {
    await context.read<NotesProvider>().loadNotes();
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
    final notes = context.watch<NotesProvider>().notes;
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
          child: notes.isEmpty
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
                  itemCount: notes.length,
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 100,
                    left: 16,
                    right: 16,
                  ),
                  itemBuilder: (context, index) {
                    final note = notes[index];
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
                      confirmDismiss: (direction) async {
                        await context.read<NotesProvider>().deleteNote(note.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note deleted'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        return true;
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
              context.read<NotesProvider>().addNote(
                    Note(
                      id: DateTime.now().toString(),
                      content: content,
                      timestamp: DateTime.now(),
                    ),
                  );
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
            context.read<NotesProvider>().updateNote(note.id, updatedContent);
          },
        ),
      ),
    );
  }
}
