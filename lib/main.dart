import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/auth/data/repository/firebase_auth.dart';
import 'package:malinaowaterbilling/features/auth/domain/repository/auth_repo.dart';
import 'package:malinaowaterbilling/features/auth/presentations/cubit/auth_cubit.dart';
import 'package:malinaowaterbilling/features/auth/presentations/pages/login_page.dart';
import 'package:malinaowaterbilling/features/auth/presentations/pages/register_page.dart';
import 'package:malinaowaterbilling/features/billing/data/repository/firebase_billing_repo.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/repository/billing_repository.dart';
import 'package:malinaowaterbilling/features/billing/presentation/cubit/billing_cubit.dart';
import 'package:malinaowaterbilling/features/billing/presentation/pages/billing_page.dart';
import 'package:malinaowaterbilling/features/dashboard/data/repository/firebase_dashboard_repo.dart';
import 'package:malinaowaterbilling/features/dashboard/domain/repository/dashboard_repo.dart';
import 'package:malinaowaterbilling/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:malinaowaterbilling/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:malinaowaterbilling/features/users/data/repository/firebase_users_repo.dart';
import 'package:malinaowaterbilling/features/users/domain/repository/user_repo.dart';
import 'package:malinaowaterbilling/features/users/presentation/cubit/users_cubit.dart';
import 'package:malinaowaterbilling/features/users/presentation/pages/customer_dashboard.dart';
import 'package:malinaowaterbilling/features/users/presentation/pages/customer_page.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/data/repository/firebase_water_rates.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/repository/water_rates_repo.dart';
import 'package:malinaowaterbilling/features/water_rates/presentation/cubit/water_rates_cubit.dart';
import 'package:malinaowaterbilling/features/water_rates/presentation/pages/water_rates_page.dart';
import 'package:malinaowaterbilling/features/widgets/my_snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepo authRepo = FirebaseAuthRepo();
  final WaterRatesRepo waterRatesRepo = FirebaseWaterRatesRepo();
  final BillingRepo billingRepo = FirebaseBillingRepo();
  final UserRepo userRepo = FirebaseUsersRepo();
  final DashboardRepo dashboardRepo = FirebaseDashboardRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(authRepo)..checkAuth()),
        BlocProvider(
          create: (context) =>
              WaterRatesCubit(waterRatesRepo)..getCurrentRate(),
        ),
        BlocProvider(
          create: (context) => BillingCubit(billingRepo)..getAllBills(),
        ),
        BlocProvider(create: (context) => UsersCubit(userRepo)),
        // REMOVED: Dashboard cubit from global providers
        // It will be provided conditionally only for admin users
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Malinao Water Billing',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => BlocProvider(
            create: (context) =>
                DashboardCubit(dashboardRepo)..loadDashboardData(),
            child: const DashboardPage(),
          ),
          '/customers': (context) => const CustomersPage(),
          '/billing': (context) => const BillingPage(),
          '/rates': (context) => const WaterRatesPage(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const LoginPage());
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          MySnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        }

        if (state is Authenticated) {
          MySnackBar.showSuccess(context, 'Admin login successful!');
        }

        if (state is UserAuthenticated) {
          MySnackBar.showSuccess(context, 'Login successful!');
        }
      },
      builder: (context, state) {
        // Show loading indicator
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Admin user - provide DashboardCubit
        if (state is Authenticated) {
          return BlocProvider(
            create: (context) =>
                DashboardCubit(FirebaseDashboardRepo())..loadDashboardData(),
            child: const DashboardPage(),
          );
        }

        // Regular user - no DashboardCubit needed
        if (state is UserAuthenticated) {
          return CustomerDashboard(currentUser: state.appUser);
        }

        // Not authenticated
        return const LoginPage();
      },
    );
  }
}
