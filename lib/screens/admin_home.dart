import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_election_page.dart'; // Import the edit page
import 'dart:math'; // For generating election code

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _candidateController = TextEditingController();
  bool _isAdding = false;

  // Function to generate a unique election code
  String _generateElectionCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Function to add a new election
  Future<void> _addElection() async {
    String electionName = _electionNameController.text.trim();
    List<String> candidates = _candidateController.text.split(',');
    String electionCode = _generateElectionCode(); // Generate unique code

    if (electionName.isEmpty || candidates.isEmpty) {
      _showMessage('Please enter election name and candidates.');
      return;
    }

    setState(() {
      _isAdding = true;
    });

    try {
      await _firestore.collection('elections').doc(electionCode).set({
        'electionName': electionName,
        'candidates': candidates,
        'isActive': true,
        'electionCode': electionCode,
        'votes': [],
      });

      _showMessage('Election added successfully! Code: $electionCode');
      _clearFields();
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  // Function to clear input fields
  void _clearFields() {
    _electionNameController.clear();
    _candidateController.clear();
  }

  // Function to display messages
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Election Form
            const Text(
              'Add New Election',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _electionNameController,
              decoration: const InputDecoration(
                labelText: 'Election Name',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _candidateController,
              decoration: const InputDecoration(
                labelText: 'Candidates (comma-separated)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isAdding ? null : _addElection,
              child: _isAdding
                  ? const CircularProgressIndicator()
                  : const Text('Add Election'),
            ),
            const SizedBox(height: 30),

            // Manage Elections Section
            const Text(
              'Manage Elections',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('elections').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching elections.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No elections found.'));
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      String docId = doc.id;
                      String electionName = doc['electionName'];
                      String electionCode = doc['electionCode'];

                      return ListTile(
                        title: Text('$electionName (Code: $electionCode)'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditElectionPage(docId: docId),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
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
