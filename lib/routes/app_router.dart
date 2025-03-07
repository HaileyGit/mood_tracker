import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/daily_record_screen.dart';
import '../screens/habit_list_screen.dart';

final router = GoRouter(
  initialLocation: '/auth',
  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isAuthRoute = state.fullPath == '/auth';

    if (!isLoggedIn && !isAuthRoute) {
      return '/auth';
    }
    if (isLoggedIn && isAuthRoute) {
      return '/home';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/record',
      builder: (context, state) => const DailyRecordScreen(),
    ),
    GoRoute(
      path: '/habits',
      builder: (context, state) => const HabitListScreen(),
    ),
  ],
);
