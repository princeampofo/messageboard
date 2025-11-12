import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'board.dart';
import 'profile.dart';
import 'settings.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // List of message boards
  final List<Map<String, dynamic>> messageBoards = [
    {
      'name': 'General Discussion',
      'icon': Icons.chat,
      'color': Colors.blue,
    },
    {
      'name': 'Technology',
      'icon': Icons.computer,
      'color': Colors.green,
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_soccer,
      'color': Colors.orange,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': Colors.purple,
    },
    {
      'name': 'Travel',
      'icon': Icons.flight,
      'color': Colors.teal,
    },
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boards'),
        backgroundColor: Colors.blue,
      ),
      
      // Side navigation drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.message,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Message Board',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    auth.currentUser?.email ?? 'Guest User',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Home option
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Boards'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),

            // Profile option
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),

            // Settings option
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),

      // Message boards list
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          final board = messageBoards[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              
              // Board icon
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: board['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  board['icon'],
                  color: board['color'],
                  size: 30,
                ),
              ),
              
              // Board name
              title: Text(
                board['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Arrow icon
              trailing: Icon(Icons.arrow_forward_ios),
              
              // On tap, open chat screen
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  BoardScreen(
                      boardName: board['name'],
                      boardColor: board['color'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}