import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mad_voting_app/screens/voter_home.dart';
import 'firebase_options.dart';
import './screens/admin_signin.dart';
import './screens/voter_signin.dart';
import './screens/voter_signup.dart';
import './screens/admin_dashboard.dart';
import './screens/admin_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/adminSignIn': (context) => AdminSignInPage(),
        '/voterSignIn': (context) => VoterSignInPage(),
        '/voterSignUp': (context) => VoterSignUpPage(),
        '/adminDashboard': (context) => AdminHomePage(),
        '/voterHome': (context) => VoterHomePage(),
        // '/adminHome': (context) => AdminHomePage(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(
            child: Text('Page not found'),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/adminSignIn');
              },
              child: const Text('Admin Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/voterSignIn');
              },
              child: const Text('Voter Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/voterSignUp');
              },
              child: const Text('Voter Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
