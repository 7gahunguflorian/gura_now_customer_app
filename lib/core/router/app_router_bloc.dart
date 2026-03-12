import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/otp_verification_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/welcome_screen.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/orders/presentation/pages/checkout_screen.dart';
import '../../features/orders/presentation/pages/order_detail_screen.dart';
import '../../features/orders/presentation/pages/order_success_screen.dart';
import '../../features/orders/presentation/pages/orders_list_screen.dart';
import '../../features/placeholders.dart';
import '../../features/shop/domain/entities/shop.dart';
import '../../features/shop/presentation/pages/shop_detail_screen.dart';
import '../layouts/main_scaffold.dart';

/// Creates GoRouter that uses [AuthBloc] from context.
/// Requires [BlocProvider<AuthBloc>] above.
GoRouter createAppRouterWithBloc(BuildContext context) {
  final authBloc = context.read<AuthBloc>();
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: AuthBlocListenable(authBloc),
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final status = authState.status;
      final role = authState.user?.role;
      final isScanning =
          status == AuthStatus.initial || status == AuthStatus.loading;
      final isAuthenticated = status == AuthStatus.authenticated;

      final location = state.uri.toString();
      final isSplash = location == '/splash';
      final isAuthFlow = location == '/login' ||
          location == '/register' ||
          location == '/onboarding' ||
          location == '/welcome' ||
          location == '/forgot-password' ||
          location.startsWith('/verify-otp') ||
          location.startsWith('/reset-password');

      if (isScanning) return isSplash ? null : '/splash';
      if (!isAuthenticated) return isAuthFlow ? null : '/onboarding';
      if (isSplash || isAuthFlow) {
        if (role == 'shop_owner') return '/dashboard';
        if (role == 'driver') return '/driver-deliveries';
        return '/home';
      }
      if (location.startsWith('/dashboard') && role != 'shop_owner') {
        return '/home';
      }
      return null;
    },
    routes: [
      // Auth flow routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            verificationType: extra?['type'] as String? ?? 'register',
            phoneNumber: extra?['phoneNumber'] as String?,
            registrationData: extra?['type'] == 'register' ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResetPasswordScreen(
            phoneNumber: extra?['phoneNumber'] as String?,
            otp: extra?['otp'] as String?,
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
              path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(
              path: '/cart', builder: (context, state) => const CartScreen()),
          GoRoute(
              path: '/orders',
              builder: (context, state) => const OrdersListScreen()),
          GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen()),
          GoRoute(
              path: '/driver-deliveries',
              builder: (context, state) => const DriverDeliveriesScreen()),
          GoRoute(
            path: '/products',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Products Manager')),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/shop/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final shop = state.extra as Shop?;
          return ShopDetailScreen(shopId: id, shopExtra: shop);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderSuccessScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/order/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Listenable that notifies when [AuthBloc] state changes (for GoRouter refresh).
class AuthBlocListenable extends ChangeNotifier {
  AuthBlocListenable(this._bloc) {
    _subscription = _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
