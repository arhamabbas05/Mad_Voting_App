import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoteForPage extends StatefulWidget {
  final String electionCode;
  final String electionName;
  final List<String> candidates;

  const VoteForPage({
    Key? key,
    required this.electionCode,
    required this.electionName,
    required this.candidates,
  }) : super(key: key);

  @override
  _VoteForPageState createState() => _VoteForPageState();
}

class _VoteForPageState extends State<VoteForPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _castVote(String candidate) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _showError("User not signed in!");
        return;
      }

      // Update the election results
      await _firestore.collection('elections').doc(widget.electionCode).update({
        'results.$candidate':
            FieldValue.increment(1), // Increment candidate votes
        'totalVotes': FieldValue.increment(1), // Increment total votes
      });

      // Mark the user as having voted in this election
      await _firestore.collection('voters').doc(user.uid).set({
        'votedElections': FieldValue.arrayUnion([widget.electionCode]),
      }, SetOptions(merge: true));

      _showDialog("Vote Cast",
          "Your vote for ${candidate} has been successfully submitted!");
      Navigator.pushNamed(context, '/voterHome');
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
      appBar: AppBar(
        title: Text('Vote for ${widget.electionName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            const Text(
              'Select a candidate to vote for:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.candidates.length,
                itemBuilder: (context, index) {
                  String candidate = widget.candidates[index];
                  return ListTile(
                    title: Text(candidate),
                    trailing: ElevatedButton(
                      onPressed: () => _castVote(candidate),
                      child: const Text('Vote'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
