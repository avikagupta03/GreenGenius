import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_page.dart';
import 'screens/settings_screen.dart';
import 'package:appforenvironment/login.dart';

// Background message handler
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("✅ Background Message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase safely
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Set up Firebase Messaging Background Handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const GreenGeniusApp());
}

class GreenGeniusApp extends StatelessWidget {
  const GreenGeniusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GreenGenius',
      theme: ThemeData(
        primaryColor: const Color(0xFF55883B),
        scaffoldBackgroundColor: const Color(0xFFC1E899),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF9A6735)),
          bodyMedium: TextStyle(color: Color(0xFF9A6735)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF55883B),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      initialRoute: '/loading', // ✅ Start with LoadingScreen
      routes: {
        '/loading': (context) =>  LoadingScreen(), // ✅ First screen (Loading)
        '/login': (context) => LoginScreen(), // ✅ Navigate here after loading
        '/home': (context) => HomeScreen(),
        '/notifications': (context) => NotificationsPage(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
