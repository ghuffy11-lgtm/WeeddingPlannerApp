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
import '../features/vendors/domain/entities/vendor_package.dart';
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
import '../features/budget/presentation/bloc/budget_bloc.dart';
import '../features/budget/presentation/pages/budget_page.dart';
import '../features/budget/presentation/pages/add_edit_expense_page.dart';
import '../features/budget/presentation/pages/expense_detail_page.dart';
import '../features/budget/domain/entities/budget.dart';
import '../features/tasks/presentation/bloc/task_bloc.dart';
import '../features/tasks/presentation/pages/tasks_page.dart';
import '../features/tasks/presentation/pages/task_detail_page.dart';
import '../features/tasks/presentation/pages/add_edit_task_page.dart';
import '../features/vendor_app/presentation/bloc/vendor_dashboard_bloc.dart';
import '../features/vendor_app/presentation/bloc/vendor_bookings_bloc.dart';
import '../features/vendor_app/presentation/bloc/vendor_packages_bloc.dart';
import '../features/vendor_app/presentation/pages/vendor_home_page.dart';
import '../features/vendor_app/presentation/pages/booking_requests_page.dart';
import '../features/vendor_app/presentation/pages/vendor_bookings_page.dart';
import '../features/vendor_app/presentation/pages/vendor_booking_detail_page.dart';
import '../features/vendor_app/presentation/pages/earnings_page.dart';
import '../features/vendor_app/presentation/pages/availability_page.dart';
import '../features/vendor_app/presentation/pages/packages_page.dart';
import '../features/vendor_app/presentation/pages/add_edit_package_page.dart';
import '../features/vendor_app/presentation/pages/vendor_profile_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../shared/widgets/layout/main_scaffold.dart';
import '../shared/widgets/layout/vendor_scaffold.dart';
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

  // Vendor App Routes
  static const String vendorHome = '/vendor';
  static const String vendorBookingRequests = '/vendor/requests';
  static const String vendorBookings = '/vendor/bookings';
  static const String vendorBookingDetail = '/vendor/bookings/:id';
  static const String vendorEarnings = '/vendor/earnings';
  static const String vendorAvailability = '/vendor/availability';
  static const String vendorPackages = '/vendor/packages';
  static const String vendorAddPackage = '/vendor/packages/add';
  static const String vendorEditPackage = '/vendor/packages/:id/edit';
  static const String vendorProfile = '/vendor/profile';
}

/// Global Navigator Key
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _vendorShellNavigatorKey = GlobalKey<NavigatorState>();

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
          pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider(
              create: (_) => getIt<TaskBloc>(),
              child: const TasksPage(),
            ),
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
          pageBuilder: (context, state) => NoTransitionPage(
            child: BlocProvider(
              create: (_) => getIt<HomeBloc>(),
              child: const ProfilePage(),
            ),
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

    // Budget Overview
    GoRoute(
      path: AppRoutes.budget,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<BudgetBloc>(),
          child: const BudgetPage(),
        );
      },
    ),

    // Add Expense
    GoRoute(
      path: '/budget/add',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<BudgetBloc>(),
          child: const AddEditExpensePage(),
        );
      },
    ),

    // Expense Detail
    GoRoute(
      path: '/budget/expense/:id',
      builder: (context, state) {
        final expenseId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<BudgetBloc>(),
          child: ExpenseDetailPage(expenseId: expenseId),
        );
      },
    ),

    // Edit Expense
    GoRoute(
      path: '/budget/expense/:id/edit',
      builder: (context, state) {
        final expenseId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<BudgetBloc>(),
          child: AddEditExpensePage(expenseId: expenseId),
        );
      },
    ),

    // Category Detail
    GoRoute(
      path: '/budget/category/:categoryName',
      builder: (context, state) {
        final category = state.extra as CategoryBudget?;
        return BlocProvider(
          create: (_) => getIt<BudgetBloc>(),
          child: _PlaceholderPage(
            title: category?.category.displayName ?? 'Category',
          ),
        );
      },
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

    // Task Detail
    GoRoute(
      path: '/tasks/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<TaskBloc>(),
          child: TaskDetailPage(taskId: taskId),
        );
      },
    ),

    // Add Task
    GoRoute(
      path: '/tasks/add',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<TaskBloc>(),
          child: const AddEditTaskPage(),
        );
      },
    ),

    // Edit Task
    GoRoute(
      path: '/tasks/edit/:id',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => getIt<TaskBloc>(),
          child: AddEditTaskPage(task: null), // Task loaded from bloc
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

    // Vendor App Shell with Bottom Navigation
    ShellRoute(
      navigatorKey: _vendorShellNavigatorKey,
      builder: (context, state, child) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<VendorDashboardBloc>()),
          BlocProvider(create: (_) => getIt<VendorBookingsBloc>()),
          BlocProvider(create: (_) => getIt<VendorPackagesBloc>()),
        ],
        child: VendorScaffold(child: child),
      ),
      routes: [
        GoRoute(
          path: AppRoutes.vendorHome,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VendorHomePage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.vendorBookings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VendorBookingsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.vendorAvailability,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AvailabilityPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.vendorProfile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VendorProfilePage(),
          ),
        ),
      ],
    ),

    // Vendor pages outside shell (with navigation)
    GoRoute(
      path: AppRoutes.vendorBookingRequests,
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<VendorDashboardBloc>()),
            BlocProvider(create: (_) => getIt<VendorBookingsBloc>()),
          ],
          child: const BookingRequestsPage(),
        );
      },
    ),
    GoRoute(
      path: '/vendor/bookings/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<VendorDashboardBloc>()),
            BlocProvider(create: (_) => getIt<VendorBookingsBloc>()),
          ],
          child: VendorBookingDetailPage(bookingId: bookingId),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.vendorEarnings,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<VendorDashboardBloc>(),
          child: const EarningsPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.vendorPackages,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<VendorPackagesBloc>(),
          child: const PackagesPage(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.vendorAddPackage,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<VendorPackagesBloc>(),
          child: const AddEditPackagePage(),
        );
      },
    ),
    GoRoute(
      path: '/vendor/packages/:id/edit',
      builder: (context, state) {
        final package = state.extra as VendorPackage?;
        return BlocProvider(
          create: (_) => getIt<VendorPackagesBloc>(),
          child: AddEditPackagePage(package: package),
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
