import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await dotenv.load(fileName: '.env'); } catch (_) {}
  runApp(const FitBuddyApp());
}
class FitBuddyApp extends StatelessWidget {
  const FitBuddyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FitBuddy', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF26D07C), brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xFF101512),
      cardTheme: CardTheme(color: const Color(0xFF1A211D), elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFF1A211D),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
    ),
    home: const HomeScreen(),
  );
}
