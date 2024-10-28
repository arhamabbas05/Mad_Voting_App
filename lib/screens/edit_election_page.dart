import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditElectionPage extends StatefulWidget {
  final String docId;

  const EditElectionPage({Key? key, required this.docId}) : super(key: key);

  @override
  _EditElectionPageState createState() => _EditElectionPageState();
}

class _EditElectionPageState extends State<EditElectionPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _electionNameController = TextEditingController();
  final TextEditingController _candidateController = TextEditingController();

  bool _isActive = false;
  bool _isSaving = false;
  int totalVotes = 0;
  Map<String, int> candidateVotes = {};

  @override
  void initState() {
    super.initState();
    _loadElectionData();
  }

  Future<void> _loadElectionData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('elections').doc(widget.docId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Debugging output
        print("Loaded election data: $data");

        _electionNameController.text = data['electionName'] ?? '';
        
        // Check if 'candidates' is a list before joining
        List<dynamic> candidates = data['candidates'] ?? [];
        if (candidates is List) {
          _candidateController.text = candidates.join(', ');
        } else {
          _candidateController.text = ''; // Default to empty if not a list
        }

        // Set the isActive state
        setState(() {
          _isActive = data['isActive'] ?? false; // Move to setState to reflect the change
        });

        // Fetch metrics
        totalVotes = data['totalVotes'] ?? 0;

        // Initialize candidate votes
        List<dynamic> candidateList = data['candidates'] ?? [];
        candidateVotes = {
          for (var candidate in candidateList) candidate: data['results'][candidate] ?? 0,
        };

        // Update the state after loading data
        setState(() {});
      } else {
        _showMessage('Election not found.');
      }
    } catch (e) {
      print("Error loading election data: ${e.toString()}"); // Debugging output
    }
  }

  Future<void> _saveElection() async {
    String newName = _electionNameController.text.trim();
    List<String> newCandidates = _candidateController.text.split(',').map((s) => s.trim()).toList();

    if (newName.isEmpty || newCandidates.isEmpty) {
      _showMessage('Please fill all fields.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _firestore.collection('elections').doc(widget.docId).update({
        'electionName': newName,
        'candidates': newCandidates,
        'isActive': _isActive,
      });

      _showMessage('Election updated successfully!');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Election')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _electionNameController,
              decoration: const InputDecoration(labelText: 'Election Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _candidateController,
              decoration: const InputDecoration(
                labelText: 'Candidates (comma-separated)',
              ),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Activate Election'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Election Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Total Votes: $totalVotes'),
            const SizedBox(height: 20),
            const Text(
              'Candidate Votes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Display candidate names with their respective votes
            for (var candidate in candidateVotes.keys)
              Text('$candidate: ${candidateVotes[candidate]} votes'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveElection,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
