import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'vote_for_page.dart'; // Import the Vote For Page

class VoterHomePage extends StatefulWidget {
  @override
  _VoterHomePageState createState() => _VoterHomePageState();
}

class _VoterHomePageState extends State<VoterHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _electionCodeController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _submitElectionCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String electionCode = _electionCodeController.text.trim();
      User? user = _auth.currentUser;

      if (user == null) {
        _showError("User not signed in!");
        return;
      }

      // Check if the user has already voted in this election
      DocumentSnapshot voterDoc = 
          await _firestore.collection('voters').doc(user.uid).get();

      if (voterDoc.exists &&
          (voterDoc['votedElections'] ?? []).contains(electionCode)) {
        _showError("You have already voted in this election!");
        return;
      }

      // Get the election details
      DocumentSnapshot electionDoc =
          await _firestore.collection('elections').doc(electionCode).get();

      if (!electionDoc.exists || !(electionDoc['isActive'] ?? false)) {
        _showError("Invalid or inactive election code!");
        return;
      }

      // Extract election details and candidates
      List<String> candidates = List<String>.from(electionDoc['candidates']);
      String electionName = electionDoc['electionName'];

      // Navigate to the VoteForPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoteForPage(
            electionCode: electionCode,
            electionName: electionName,
            candidates: candidates,
          ),
        ),
      );
    } catch (e) {
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voter Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _electionCodeController,
              decoration: const InputDecoration(labelText: 'Enter Election Code'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitElectionCode,
              child: const Text('Submit Code'),
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
