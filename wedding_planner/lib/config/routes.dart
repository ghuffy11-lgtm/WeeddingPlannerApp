import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/welcome_page.dart';
import '../features/home/presentation/bloc/home_bloc.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/vendors/presentation/bloc/vendor_bloc.dart';
import '../features/vendors/presentation/pages/vendors_page.dart';
import '../features/vendors/presentation/pages/vendor_list_page.dart';
import '../features/vendors/presentation/pages/vendor_detail_page.dart';
import '../features/vendors/domain/entities/vendor.dart';
import '../features/booking/presentation/bloc/booking_bloc.dart';
import '../features/booking/presentation/pages/bookings_page.dart';
import '../features/booking/presentation/pages/booking_detail_page.dart';
import '../features/booking/presentation/pages/create_booking_page.dart';
import '../features/chat/presentation/bloc/chat_bloc.dart';
import '../features/chat/presentation/pages/conversations_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/guests/presentation/bloc/guest_bloc.dart';
import '../features/guests/presentation/pages/guests_page.dart';
import '../features/guests/presentation/pages/guest_detail_page.dart';
import '../features/guests/presentation/pages/add_edit_guest_page.dart';
import '../shared/widgets/layout/main_scaffold.dart';
import 'injection.dart';

/// App Route Names
class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Onboarding Routes
  static const String onboarding = '/onboarding';

  // Main App Routes
  static const String home = '/home';
  static const String tasks = '/tasks';
  static const String vendors = '/vendors';
  static const String chat = '/chat';
  static const String profile = '/profile';

  // Vendor Routes
  static const String vendorDetail = '/vendors/:id';
  static const String vendorBooking = '/vendors/:id/book';

  // Booking Routes
  static const String bookings = '/bookings';
  static const String bookingDetail = '/bookings/:id';

  // Task Routes
  static const String taskDetail = '/tasks/:id';

  // Guest Routes
  static const String guests = '/guests';
  static const String guestDetail = '/guests/:id';

  // Budget Routes
  static const String budget = '/budget';

  // Invitation Routes
  static const String invitations = '/invitations';
  static const String invitationEditor = '/invitations/editor';
  static const String rsvpDashboard = '/invitations/rsvp';

  // Seating Routes
  static const String seating = '/seating';

  // Chat Routes
  static const String chatConversation = '/chat/:id';
}

/// Global Navigator Key
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App Router Configuration
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,

  routes: [
    // Splash Screen
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    // Welcome Screen
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomePage(),
    ),

    // Auth Routes
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) =>
          const _PlaceholderPage(title: 'Forgot Password'),
    ),

    // Onboarding
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),

    // Main App Shell with Bottom Navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider(
              create: (_) => getIt<HomeBloc>(),
              child: const HomePage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.tasks,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderPage(title: 'Tasks'),
          ),
        ),
        GoRoute(
          path: AppRoutes.vendors,
          pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider(
              create: (_) => getIt<VendorBloc>(),
              child: const VendorsPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.chat,
          pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider.value(
              value: getIt<ChatBloc>(),
              child: const ConversationsPage(),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderPage(title: 'Profile'),
          ),
        ),
      ],
    ),

    // Vendor Detail (outside shell)
    GoRoute(
      path: AppRoutes.vendorDetail,
      builder: (context, state) {
        final vendorId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<VendorBloc>(),
          child: VendorDetailPage(vendorId: vendorId),
        );
      },
    ),

    // Vendor List by Category
    GoRoute(
      path: '/vendors/category/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        final categoryName = state.extra as String?;
        return BlocProvider(
          create: (_) => getIt<VendorBloc>(),
          child: VendorListPage(
            categoryId: categoryId,
            categoryName: categoryName,
          ),
        );
      },
    ),

    // Vendor Search
    GoRoute(
      path: '/vendors/search',
      builder: (context, state) {
        final searchQuery = state.extra as String?;
        return BlocProvider(
          create: (_) => getIt<VendorBloc>(),
          child: VendorListPage(searchQuery: searchQuery),
        );
      },
    ),

    // Create Booking (from vendor page)
    GoRoute(
      path: '/vendors/:id/book',
      builder: (context, state) {
        final vendor = state.extra as Vendor;
        return BlocProvider(
          create: (_) => getIt<BookingBloc>(),
          child: CreateBookingPage(vendor: vendor),
        );
      },
    ),

    // Bookings List
    GoRoute(
      path: AppRoutes.bookings,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<BookingBloc>(),
          child: const BookingsPage(),
        );
      },
    ),

    // Booking Detail
    GoRoute(
      path: '/bookings/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<BookingBloc>(),
          child: BookingDetailPage(bookingId: bookingId),
        );
      },
    ),

    // Budget
    GoRoute(
      path: AppRoutes.budget,
      builder: (context, state) => const _PlaceholderPage(title: 'Budget'),
    ),

    // Guests List
    GoRoute(
      path: AppRoutes.guests,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<GuestBloc>(),
          child: const GuestsPage(),
        );
      },
    ),

    // Guest Detail
    GoRoute(
      path: '/guests/:id',
      builder: (context, state) {
        final guestId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<GuestBloc>(),
          child: GuestDetailPage(guestId: guestId),
        );
      },
    ),

    // Add Guest
    GoRoute(
      path: '/guests/add',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<GuestBloc>(),
          child: const AddEditGuestPage(),
        );
      },
    ),

    // Edit Guest
    GoRoute(
      path: '/guests/:id/edit',
      builder: (context, state) {
        final guestId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<GuestBloc>(),
          child: AddEditGuestPage(guestId: guestId),
        );
      },
    ),

    // Invitations
    GoRoute(
      path: AppRoutes.invitations,
      builder: (context, state) =>
          const _PlaceholderPage(title: 'Invitations'),
    ),
    GoRoute(
      path: AppRoutes.invitationEditor,
      builder: (context, state) =>
          const _PlaceholderPage(title: 'Invitation Editor'),
    ),
    GoRoute(
      path: AppRoutes.rsvpDashboard,
      builder: (context, state) =>
          const _PlaceholderPage(title: 'RSVP Dashboard'),
    ),

    // Seating
    GoRoute(
      path: AppRoutes.seating,
      builder: (context, state) => const _PlaceholderPage(title: 'Seating'),
    ),

    // Chat Conversation (outside shell)
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final conversationId = state.pathParameters['id']!;
        return BlocProvider.value(
          value: getIt<ChatBloc>(),
          child: ChatPage(conversationId: conversationId),
        );
      },
    ),
  ],

  // Error Page
  errorBuilder: (context, state) => _ErrorPage(error: state.error),
);

/// Placeholder Page (temporary)
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Page\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

/// Error Page
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
