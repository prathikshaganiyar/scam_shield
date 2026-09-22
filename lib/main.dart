import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/lookup_screen.dart';
import 'screens/verify_letter_screen.dart';

bool firebaseReady = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseReady = true;
  } catch (e) {
    debugPrint(
      'Firebase did not initialize: $e',
    );

    debugPrint(
      'The "Check UPI/Phone" tab will show a setup message until this is fixed.',
    );

    firebaseReady = false;
  }

  runApp(
    const ScamShieldApp(),
  );
}

class ScamShieldApp extends StatelessWidget {
  const ScamShieldApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scam Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E5AA8),
        useMaterial3: true,
      ),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({
    super.key,
  });

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    DashboardScreen(),
    LookupScreen(),
    VerifyLetterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.message_outlined,
            ),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.dashboard_outlined,
            ),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.verified_user_outlined,
            ),
            label: 'Check',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.document_scanner_outlined,
            ),
            label: 'Verify',
          ),
        ],
      ),
    );
  }
}