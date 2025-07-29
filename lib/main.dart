import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/project_estimate.dart';
import 'screens/estimate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProjectEstimate(),
      child: MaterialApp(
        title: 'Fiber Cost Estimator',
        // --- NEW: Updated Theme ---
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9F9FB), // A very light grey
          primaryColor: Colors.black,
          fontFamily:
              'sans-serif', // Use a clean, system default sans-serif font
          // Define the color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(
              0xFFEFE8FC,
            ), // A light lavender from your image
            background: const Color(0xFFF9F9FB),
            primary: Colors.black,
          ),

          // Define the style for all ElevatedButtons
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Define the style for all TextFormFields
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
          ),

          // Define default text styles
          textTheme: TextTheme(
            titleLarge: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ),
        home: const EstimateScreen(),
      ),
    );
  }
}
