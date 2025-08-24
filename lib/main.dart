import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:share2cash/HomePage.dart';
import 'package:share2cash/Local_notifications.dart';
import 'package:share2cash/Themes/ThemeProvider.dart';
import 'package:share2cash/auth.dart';
import 'package:share2cash/fireStoreServices.dart';
import 'package:share2cash/introScreen.dart';
import 'package:share2cash/packet_sdk.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotifications.init();
  await FirestoreService().initUserDoc();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PacketSdkProvider()),
        ChangeNotifierProvider(create: (context)=>ThemeProvider())
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _introSeen;

  @override
  void initState() {
    super.initState();
    _loadIntroFlag();
  }

  Future<void> _loadIntroFlag() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _introSeen = prefs.getBool('isIntroduced') ?? false;
    });
  }

  void _onIntroDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isIntroduced', true);
    setState(() {
      _introSeen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_introSeen == null) {
      // Waiting for prefs to load
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'Share2Cash',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: RootGate(introSeen: _introSeen!, onIntroDone: _onIntroDone),
      routes: {'/HomePage': (_) => const HomePage()},
    );
  }
}

class RootGate extends StatelessWidget {
  final bool introSeen;
  final VoidCallback onIntroDone;

  const RootGate({
    super.key,
    required this.introSeen,
    required this.onIntroDone,
  });

  @override
  Widget build(BuildContext context) {
    if (!introSeen) {
      return IntroScreen(onDone: onIntroDone);
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking auth status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If signed in
        if (snapshot.hasData) {
          return const HomePage();
        }
        // Not signed in → show Auth UI
        return  AuthGate();
      },
    );
  }
}
