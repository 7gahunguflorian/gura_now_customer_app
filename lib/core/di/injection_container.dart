import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart' show SecureStorageService;

// Import features
import '../../features/auth/auth.dart';
import '../../features/cart/cart.dart';
import '../../features/orders/orders.dart';
import '../../features/shop/shop.dart';
import '../../features/notifications/notifications.dart';
import '../../features/payment/payment.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ═══════════════════════════════════════════════════════════════
  // CORE DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════
  await _initCore();

  // ═══════════════════════════════════════════════════════════════
  // FEATURES
  // ═══════════════════════════════════════════════════════════════
  _initAuth();
  _initCart();
  _initOrders();
  _initShop();
  _initDriver();
  _initAdmin();
  _initNotifications();
  _initPayment();
}

Future<void> _initCore() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Storage
  sl.registerLazySingleton<SecureStorageService>(
    SecureStorageService.new,
  );

  // Network - DioClient (existing implementation)
  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<SecureStorageService>()),
  );

  // Network - ApiClient (Dio-based Clean Architecture wrapper)
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl<DioClient>()),
  );
}

void _initAuth() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetMeUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl(),
      sl<SecureStorageService>(),
    ),
  );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory - one per tree, created at app root)
  // ─────────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getMeUseCase: sl(),
      storage: sl<SecureStorageService>(),
    ),
  );
}

void _initCart() {
  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  sl.registerFactory<CartBloc>(
    () => CartBloc(sl()),
  );
}

void _initOrders() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderDetailUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmOrderUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmCustomerUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  sl.registerFactory<OrderBloc>(
    () => OrderBloc(
      getOrdersUseCase: sl(),
      getOrderDetailUseCase: sl(),
      createOrderUseCase: sl(),
      confirmOrderUseCase: sl(),
      confirmCustomerUseCase: sl(),
    ),
  );
}

void _initShop() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetShopsUseCase(sl()));
  sl.registerLazySingleton(() => GetShopDetailUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ShopRemoteDataSource>(
    () => ShopRemoteDataSourceImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  sl.registerFactory<ShopBloc>(
    () => ShopBloc(
      getShopsUseCase: sl(),
      getShopDetailUseCase: sl(),
    ),
  );
}

void _initDriver() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerLazySingleton(() => GetAvailableDeliveriesUseCase(sl()));
  // sl.registerLazySingleton(() => AcceptDeliveryUseCase(sl()));
  // sl.registerLazySingleton(() => GetDriverStatsUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerLazySingleton<DeliveryRepository>(
  //   () => DeliveryRepositoryImpl(sl()),
  // );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerLazySingleton<DeliveryRemoteDataSource>(
  //   () => DeliveryRemoteDataSourceImpl(sl()),
  // );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerFactory<DriverBloc>(
  // () => DriverBloc(sl()),
  // );
}

void _initAdmin() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerLazySingleton(() => GetStatsUseCase(sl()));
  // sl.registerLazySingleton(() => GetUsersUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerLazySingleton<AdminRepository>(
  //   () => AdminRepositoryImpl(sl()),
  // );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerLazySingleton<AdminRemoteDataSource>(
  //   () => AdminRemoteDataSource(sl()),
  // );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  // sl.registerFactory<AdminBloc>(
  //   () => AdminBloc(sl()),
  // );
}

void _initNotifications() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(sl()),
  );
}

void _initPayment() {
  // ─────────────────────────────────────────────────────────────────
  // Use Cases (Singleton)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetPaymentProofsUseCase(sl()));
  sl.registerLazySingleton(() => GetShopBalanceUseCase(sl()));

  // ─────────────────────────────────────────────────────────────────
  // Repository (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // Data Sources (Singleton, registered with interface type)
  // ─────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(sl()),
  );

  // ─────────────────────────────────────────────────────────────────
  // BLoC (Factory)
  // ─────────────────────────────────────────────────────────────────
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(sl()),
  );
}
