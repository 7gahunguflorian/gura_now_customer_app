import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart' as di;
import 'core/router/app_router_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth.dart';
import 'features/cart/cart.dart';
import 'features/notifications/notifications.dart';
import 'features/orders/orders.dart';
import 'features/payment/payment.dart';
import 'features/product/product.dart';
import 'features/profile/profile.dart';
import 'features/review/review.dart';
import 'features/shop/shop.dart';

/// Root application widget.
/// Uses BLoC for state management and GoRouter for navigation.
class GuraNowApp extends StatelessWidget {
  const GuraNowApp({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              final bloc = di.sl<AuthBloc>()..add(const AuthCheckRequested());
              return bloc;
            },
          ),
          BlocProvider(create: (_) => di.sl<CartBloc>()),
          BlocProvider(create: (_) => di.sl<NotificationBloc>()),
          BlocProvider(create: (_) => di.sl<OrderBloc>()),
          BlocProvider(create: (_) => di.sl<PaymentBloc>()),
          BlocProvider(create: (_) => di.sl<ProductDetailBloc>()),
          BlocProvider(create: (_) => di.sl<ProfileBloc>()),
          BlocProvider(create: (_) => di.sl<ReviewBloc>()),
          BlocProvider(create: (_) => di.sl<ShopBloc>()),
        ],
        child: Builder(
          builder: (context) {
            final router = createAppRouterWithBloc(context);
            return MaterialApp.router(
              title: AppConstants.appName,
              theme: AppTheme.darkTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.dark,
              routerConfig: router,
              debugShowCheckedModeBanner: false,
              locale: const Locale('fr', 'BI'),
              supportedLocales: const [
                Locale('fr', 'BI'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      );
}
