import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'voice_screen.dart';
import 'content_screen.dart';
import 'settings_screen.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<void> _onNoteCreated(String content) async {
    final note = Note(
      id: DateTime.now().toString(),
      content: content,
      timestamp: DateTime.now(),
    );
    await context.read<NotesProvider>().addNote(note);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      VoiceScreen(onNoteCreated: _onNoteCreated),
      const ContentScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        elevation: 0,

        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/voice.png')),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/document.png')),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
