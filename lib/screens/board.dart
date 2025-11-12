import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BoardScreen extends StatefulWidget {
  final String boardName;
  final Color boardColor;

  const BoardScreen({super.key, required this.boardName, required this.boardColor});

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController messageController = TextEditingController();

  // Function to send message
  Future<void> sendMessage() async {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    // Get current user
    User? user = auth.currentUser;
    if (user == null) return;

    // Get user info from Firestore
    DocumentSnapshot userDoc = await firestore.collection('users').doc(user.uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    String displayName = '${userData['firstName']} ${userData['lastName']}';

    // Add message to Firestore
    await firestore
        .collection('message_boards')
        .doc(widget.boardName)
        .collection('messages')
        .add({
      'message': message,
      'username': displayName,
      'userId': user.uid,
      'dateTime': DateTime.now(),
    });

    // Clear text field
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.boardName),
        backgroundColor: widget.boardColor,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Listen to messages in real-time
              stream: firestore
                  .collection('message_boards')
                  .doc(widget.boardName)
                  .collection('messages')
                  .orderBy('dateTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Show loading while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Show error if something went wrong
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Show message if no messages yet
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet. Be the first to post!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Display messages
                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: false, // Show newest at top
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData = messages[index].data() as Map<String, dynamic>;
                    
                    String username = messageData['username'] ?? 'Unknown';
                    String message = messageData['message'] ?? '';
                    Timestamp timestamp = messageData['dateTime'];
                    DateTime dateTime = timestamp.toDate();

                    // Format date and time
                    String formattedDate = '${dateTime.day}/${dateTime.month}/${dateTime.year} '
                        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username and date row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: widget.boardColor,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            // Message text
                            Text(
                              message,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input area
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha :0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input field
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Send button
                CircleAvatar(
                  backgroundColor: widget.boardColor,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}