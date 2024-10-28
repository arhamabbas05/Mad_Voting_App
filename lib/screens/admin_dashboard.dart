import 'package:flutter/material.dart';


class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('Registered Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ListTile(
            title: Text('User 1: John Doe'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Remove user logic
              },
            ),
          ),
          ListTile(
            title: Text('User 2: Jane Smith'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Remove user logic
              },
            ),
          ),
          SizedBox(height: 20),
          Text('Approve Voter Registrations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text('Approve John Doe'),
            value: true, // Approval status
            onChanged: (value) {
              // Handle approval toggle
            },
          ),
          SwitchListTile(
            title: Text('Approve Jane Smith'),
            value: false, // Approval status
            onChanged: (value) {
              // Handle approval toggle
            },
          ),
        ],
      ),
    );
  }
}
