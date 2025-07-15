import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/db_service.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🛠️ Setup database FFI untuk desktop (Windows/Linux)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // ✅ Inisialisasi database sebelum runApp
  await DBService.initDb();

  // 🔐 Cek status login
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final username = prefs.getString('username') ?? '';

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Aktifkan hanya di debug mode
      builder: (context) => MyApp(isLoggedIn: isLoggedIn, username: username),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String username;

  const MyApp({super.key, required this.isLoggedIn, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kuis Pengetahuan Umum',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true, // ✅ penting untuk device preview
      builder: DevicePreview.appBuilder, // ✅
      locale: DevicePreview.locale(context), // ✅
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: isLoggedIn ? HomePage(username: username) : const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => HomePage(username: username),
      },
    );
  }
}
