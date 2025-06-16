import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/firebase_auth_service.dart';
import '../core/models/user.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/signup_page.dart';
import '../features/onboarding/pages/welcome_page.dart';
import '../features/onboarding/pages/medical_info_page_simple.dart';
import '../features/dashboard/pages/main_navigation_page.dart';
import '../features/dashboard/pages/dashboard_page_simple.dart';
import '../features/learning/pages/content_library_page.dart';
import '../features/learning/pages/content_detail_page.dart';
import '../features/learning/pages/video_player_page.dart';
import '../features/quiz/pages/quiz_list_page.dart';
import '../features/quiz/pages/quiz_page.dart';
import '../features/quiz/pages/quiz_result_page.dart';
import '../features/progress/pages/progress_page.dart';
import '../features/profile/pages/profile_page.dart';
import '../features/profile/pages/edit_profile_page.dart';
import '../features/admin/pages/admin_dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,
    routes: [
      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),
      
      // Onboarding routes
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/medical-info',
        name: 'medical-info',
        builder: (context, state) => const MedicalInfoPageSimple(),
      ),
      
      // Main navigation shell
      ShellRoute(
        builder: (context, state, child) => MainNavigationPage(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardPageSimple(),
          ),
          
          // Learning routes
          GoRoute(
            path: '/learn',
            name: 'learn',
            builder: (context, state) => const ContentLibraryPage(),
            routes: [
              GoRoute(
                path: 'content/:id',
                name: 'content-detail',
                builder: (context, state) {
                  final contentId = state.pathParameters['id']!;
                  return ContentDetailPage(contentId: contentId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/video/:id',
            name: 'video-player',
            builder: (context, state) {
              final contentId = state.pathParameters['id']!;
              return VideoPlayerPage(contentId: contentId);
            },
          ),
          
          // Quiz routes
          GoRoute(
            path: '/quiz',
            name: 'quiz',
            builder: (context, state) => const QuizListPage(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'quiz-detail',
                builder: (context, state) {
                  final quizId = state.pathParameters['id']!;
                  return QuizPage(quizId: quizId);
                },
              ),
              GoRoute(
                path: ':id/result',
                name: 'quiz-result',
                builder: (context, state) {
                  final quizId = state.pathParameters['id']!;
                  final attemptId = state.uri.queryParameters['attemptId'];
                  return QuizResultPage(
                    quizId: quizId,
                    attemptId: attemptId,
                  );
                },
              ),
            ],
          ),
          
          // Progress routes
          GoRoute(
            path: '/progress',
            name: 'progress',
            builder: (context, state) => const ProgressPage(),
          ),
          
          // Profile routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfilePage(),
              ),
            ],
          ),
        ],
      ),
      
      // Admin routes
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardPage(),
        redirect: (context, state) {
          final authService = FirebaseAuthService();
          if (!authService.isAuthenticated || !authService.isAdmin) {
            return '/login';
          }
          return null;
        },
      ),
      
      // Patient dashboard accessible by admins
      GoRoute(
        path: '/patient-dashboard',
        name: 'patient-dashboard',
        builder: (context, state) => const MainNavigationPage(
          child: DashboardPageSimple(),
        ),
        redirect: (context, state) {
          final authService = FirebaseAuthService();
          if (!authService.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authService = FirebaseAuthService();
    final isAuthenticated = authService.isAuthenticated;
    final currentUser = authService.currentUser;
    
    final isOnAuthPages = state.uri.path == '/login' || 
                         state.uri.path == '/signup';
    final isOnOnboardingPages = state.uri.path == '/welcome' || 
                               state.uri.path == '/medical-info';
    final isOnAdminPages = state.uri.path.startsWith('/admin');
    
    // If not authenticated and not on auth pages, redirect to login
    if (!isAuthenticated && !isOnAuthPages) {
      return '/login';
    }
    
    // If authenticated but user hasn't completed onboarding
    if (isAuthenticated && currentUser != null) {
      final hasCompletedOnboarding = currentUser.medicalProfile != null;
      final isAdmin = currentUser.role == UserRole.admin;
      
      // Admin users skip onboarding and go straight to admin dashboard
      if (isAdmin && !isOnAdminPages && !isOnAuthPages) {
        return '/admin';
      }
      
      // Patient users need to complete onboarding
      if (!isAdmin && !hasCompletedOnboarding && !isOnOnboardingPages) {
        return '/welcome';
      }
      
      // If user completed onboarding but is still on auth/onboarding pages
      if (!isAdmin && hasCompletedOnboarding && (isOnAuthPages || isOnOnboardingPages)) {
        return '/';
      }
      
      // If admin is on auth/onboarding pages, redirect to admin
      if (isAdmin && (isOnAuthPages || isOnOnboardingPages)) {
        return '/admin';
      }
      
      // If patient tries to access admin pages, redirect to home
      if (!isAdmin && isOnAdminPages) {
        return '/';
      }
    }
    
    return null;
  }
}