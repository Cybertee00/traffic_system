import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'pages/parallel_parking_backend.dart';
import 'pages/alleyDocking_backend.dart';
import 'pages/hillStart_backend.dart';
import 'pages/car_details_backend.dart';
import 'pages/theme_backend.dart';
import 'pages/audio_backend.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Page2Backend()),
        ChangeNotifierProvider(create: (_) => Page3Backend()),
        ChangeNotifierProvider(create: (_) => HillStartBackend()),
        ChangeNotifierProvider(create: (_) => CarDetailsBackend()),
        ChangeNotifierProvider(create: (_) => ThemeBackend()),
        ChangeNotifierProvider(create: (_) => AudioBackend()),
        // Add more providers as needed for other checklists
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeBackend>(
      builder: (context, themeBackend, child) {
        return MaterialApp(
          title: 'SMART Licence APP',
          theme: themeBackend.theme,
          home: const LoginPage(), // start on the login page
        );
      },
    );
  }
}
