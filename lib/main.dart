import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() => runApp(const NotesApp());

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cisco Live Notes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const WelcomeScreen(),
      );
}
