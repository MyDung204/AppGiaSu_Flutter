import 'package:doantotnghiep/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:doantotnghiep/features/admin/presentation/admin_tutor_approval_screen.dart';
import 'package:doantotnghiep/features/admin/presentation/admin_users_screen.dart';
import 'package:doantotnghiep/features/admin/presentation/admin_reports_screen.dart';
import 'package:doantotnghiep/features/admin/presentation/widgets/admin_scaffold.dart';
import 'package:doantotnghiep/features/admin/presentation/admin_ai_audit_screen.dart';
import 'package:doantotnghiep/features/admin/presentation/admin_market_map_screen.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/tutor_dashboard_screen.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/widgets/tutor_scaffold.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/student_request_list_screen.dart';
import 'package:doantotnghiep/features/rating/presentation/tutor_reviews_screen.dart';
import 'package:doantotnghiep/features/report/presentation/create_report_screen.dart';
import 'package:doantotnghiep/features/group/presentation/create_group_screen.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/tutor_schedule_management_screen.dart';
import 'package:doantotnghiep/features/profile/presentation/ekyc_update_screen.dart';
import 'package:doantotnghiep/features/tutor_dashboard/presentation/create_class_screen.dart';
import 'package:doantotnghiep/features/notification/presentation/notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doantotnghiep/features/home/presentation/home_screen.dart';
import 'package:doantotnghiep/features/auth/presentation/login_screen.dart';
import 'package:doantotnghiep/features/auth/presentation/register_screen.dart';
import 'package:doantotnghiep/features/auth/data/auth_repository.dart';
import 'package:doantotnghiep/features/tutor/domain/models/tutor.dart';
import 'package:doantotnghiep/features/tutor/presentation/tutor_detail_screen.dart';
import 'package:doantotnghiep/features/booking/presentation/booking_screen.dart';
import 'package:doantotnghiep/features/search/presentation/search_screen.dart';
import 'package:doantotnghiep/features/profile/presentation/profile_screen.dart';
import 'package:doantotnghiep/features/wallet/presentation/wallet_screen.dart';
import 'package:doantotnghiep/features/home/presentation/widgets/scaffold_with_navbar.dart';
import 'package:doantotnghiep/features/booking/presentation/schedule_screen.dart';
import 'package:doantotnghiep/features/chat/presentation/chat_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(navigationShell: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
             path: '/schedule',
             builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
             path: '/ekyc',
             builder: (context, state) {
               final isTutor = state.uri.queryParameters['isTutor'] == 'true';
               return EkycUpdateScreen(isTutor: isTutor);
             },
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tutor-detail',
        builder: (context, state) {
           final tutor = state.extra as Tutor;
           return TutorDetailScreen(tutor: tutor);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/booking',
        builder: (context, state) {
           final tutor = state.extra as Tutor;
           return BookingScreen(tutor: tutor);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/report',
        builder: (context, state) {
           return const CreateReportScreen();
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/create-group',
        builder: (context, state) => const CreateGroupScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/create-class',
        builder: (context, state) => const CreateClassScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/chat',
        builder: (context, state) {
          final tutor = state.extra as Tutor;
           return ChatScreen(tutor: tutor);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/tutor-reviews',
        builder: (context, state) {
           final tutor = state.extra as Tutor;
           return TutorReviewsScreen(tutor: tutor);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AdminScaffold(navigationShell: child);
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
            routes: [
               GoRoute(
                path: 'users',
                builder: (context, state) => const AdminUsersScreen(),
              ),
              GoRoute(
                path: 'tutors', 
                builder: (context, state) => const AdminTutorApprovalScreen(),
              ),
              GoRoute(
                path: 'approve', 
                builder: (context, state) => const AdminTutorApprovalScreen(),
              ),
              GoRoute(
                path: 'reports',
                builder: (context, state) => const AdminReportsScreen(),
              ),
              GoRoute(
                path: 'ai-audit',
                builder: (context, state) => const AdminAiAuditScreen(),
              ),
              GoRoute(
                path: 'market-map',
                builder: (context, state) => const AdminMarketMapScreen(),
              ),
            ],
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          return TutorScaffold(navigationShell: child);
        },
        routes: [
          GoRoute(
            path: '/tutor-dashboard',
            builder: (context, state) => const TutorDashboardScreen(),
            routes: [
              GoRoute(
                 path: 'find-students',
                 builder: (context, state) => const StudentRequestListScreen(),
              ),
              GoRoute(
                 path: 'schedule',
                 builder: (context, state) => const ScheduleScreen(), // Reusing Student Schedule for now or create new
              ),
              GoRoute(
                 path: 'messages',
                 builder: (context, state) => const Scaffold(body: Center(child: Text("Messages"))), // Placeholder
              ),
               GoRoute(
                 path: 'profile',
                 builder: (context, state) => const ProfileScreen(), // Reusing Profile
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const Scaffold(body: Center(child: Text("Forgot Password"))), // Placeholder
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
    ],
    redirect: (context, state) async {
      final authState = FirebaseAuth.instance.currentUser;
      final loggingIn = state.uri.path == '/login' || state.uri.path == '/register';

      // 1. Not logged in
      if (authState == null) {
        return loggingIn ? null : '/login';
      }

      // 2. Logged in
      if (loggingIn || state.uri.path == '/') {
        // Fetch Role using Repository (Single Source of Truth)
        // We instantiate it directly here as we are outside of Riverpod's scope for now.
        // In a perfect world, we'd use a Listenable/Stream.
        final repo = AuthRepository(FirebaseAuth.instance);
        final role = await repo.getUserRole(authState.uid);
        
        if (role == 'admin') {
          return '/admin';
        } else if (role == 'tutor') {
           return '/tutor-dashboard';
        } else {
          return '/';
        }
      }

      return null; // No redirect
    },
  );
}

