import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        title: Text('Messages',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          CircleAvatar(backgroundImage: AssetImage('assets/user.png')),
        ],
      ),
      body: Column(
        children: [
          _messageFilters(),
          Expanded(
            child: ListView(
              children: [
                _messageTile('User 1', 'Did you see the message?', 2, false),
                _messageTile('User 2', 'Send the photos quick', 3, false),
                _messageTile('User 4', 'When are we meeting?', 0, true),
                _messageTile('Shifa', 'You: All good!', 0, false),
                _messageTile('User 3', 'You: see you soon', 0, false),
                _messageTile('User 5', 'F*** off!', 0, false),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.purple[300],
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.message, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: Icon(Icons.video_call, color: Colors.white),
                onPressed: () {}),
            IconButton(
                icon: Icon(Icons.call, color: Colors.white), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _messageFilters() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _filterButton('All', true),
          _filterButton('Unread', false),
          _filterButton('Approach', false),
        ],
      ),
    );
  }

  Widget _filterButton(String label, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
    );
  }

  Widget _messageTile(
      String username, String lastMessage, int unreadCount, bool isBold) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage('https://via.placeholder.com/150')), // Replace with actual user image
      title: Text(username,
          style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(lastMessage, style: TextStyle(fontSize: 14)),
      trailing: unreadCount > 0
          ? CircleAvatar(
              backgroundColor: Colors.purple[300],
              radius: 12,
              child: Text('$unreadCount',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            )
          : null,
    );
  }
}
