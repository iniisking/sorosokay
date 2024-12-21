import 'package:flutter/material.dart';
import 'voice_screen.dart';
import 'content_screen.dart';
import 'settings_screen.dart';
import '../models/note.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Note> _notes = [];

  void _onNoteCreated(String content) {
    setState(() {
      _notes.insert(
        0,
        Note(
          id: DateTime.now().toString(),
          content: content,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      VoiceScreen(onNoteCreated: _onNoteCreated),
      ContentScreen(notes: _notes),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/voice.png'),
            ),
            label: 'Voice',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/images/document.png'),
            ),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color.fromARGB(255, 0, 55, 255),
        unselectedItemColor: Colors.grey,
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
