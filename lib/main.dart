import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mood Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.cardBackground,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.navText,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.navText,
          ),
          iconTheme: IconThemeData(
            color: AppColors.navText,
          ),
          toolbarHeight: 80,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(12),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.navText,
          unselectedItemColor: AppColors.navText.withOpacity(0.7),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navText,
          ),
          unselectedLabelStyle: TextStyle(
            color: AppColors.navText.withOpacity(0.7),
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: AppColors.text,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: AppColors.text,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
