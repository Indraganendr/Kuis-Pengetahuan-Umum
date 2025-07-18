import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package Imports
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Local Project Imports
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/review_page.dart';
import 'services/db_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DBService.initDb();

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username') ?? '';

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MyApp(isLoggedIn: isLoggedIn, username: username),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String username;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
      title: 'Kuis Pengetahuan Umum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: isLoggedIn ? HomePage(username: username) : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => HomePage(username: username),
        '/review': (context) => const ReviewPage(),
      },
    );
  }
}