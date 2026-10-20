import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GoogleTasksApp());
}

class GoogleTasksApp extends StatelessWidget {
  const GoogleTasksApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Tasks Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF131318),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8AB4F8),
          surface: Color(0xFF1E1F25),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
