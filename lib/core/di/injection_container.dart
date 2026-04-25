import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mock/mock_config.dart';
import '../mock/mock_auth_datasource.dart';
import '../mock/mock_notification_datasource.dart';
import '../mock/mock_order_datasource.dart';
import '../mock/mock_payment_datasource.dart';
import '../mock/mock_product_datasource.dart';
import '../mock/mock_profile_datasource.dart';
import '../mock/mock_review_datasource.dart';
import '../mock/mock_shop_datasource.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart' show SecureStorageService;

// Features
import '../../features/auth/auth.dart';
import '../../features/cart/cart.dart';
import '../../features/notifications/notifications.dart';
import '../../features/orders/orders.dart';
import '../../features/payment/payment.dart';
import '../../features/product/product.dart';
import '../../features/profile/profile.dart';
import '../../features/review/review.dart';
import '../../features/shop/shop.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await _initCore();
  _initAuth();
  _initCart();
  _initOrders();
  _initShop();
  _initProduct();
  _initProfile();
  _initReview();
  _initNotifications();
  _initPayment();
}

Future<void> _initCore() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<SecureStorageService>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<DioClient>()));
}

void _initAuth() {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSource(),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<SecureStorageService>()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetMeUseCase(sl<AuthRepository>()));

  // BLoC
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
  // Datasource
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartLocalDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));

  // BLoC
  sl.registerFactory<CartBloc>(
    () => CartBloc(
      getCartUseCase: sl(),
      addToCartUseCase: sl(),
      removeFromCartUseCase: sl(),
      updateCartQuantityUseCase: sl(),
      clearCartUseCase: sl(),
    ),
  );
}

void _initOrders() {
  // Datasource
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => MockOrderRemoteDataSource(),
  );

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<OrderRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateOrderUseCase(sl<OrderRepository>()));
  sl.registerLazySingleton(() => GetOrdersUseCase(sl<OrderRepository>()));
  sl.registerLazySingleton(() => GetOrderDetailUseCase(sl<OrderRepository>()));
  sl.registerLazySingleton(() => ConfirmOrderUseCase(sl<OrderRepository>()));
  sl.registerLazySingleton(() => ConfirmCustomerUseCase(sl<OrderRepository>()));

  // BLoC
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
  // Datasource
  sl.registerLazySingleton<ShopRemoteDataSource>(
    () => useMockData
        ? MockShopRemoteDataSource()
        : ShopRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(sl<ShopRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetShopsUseCase(sl<ShopRepository>()));
  sl.registerLazySingleton(() => GetShopDetailUseCase(sl<ShopRepository>()));
  sl.registerLazySingleton(() => GetShopProductsUseCase(sl<ShopRepository>()));

  // BLoC
  sl.registerFactory<ShopBloc>(
    () => ShopBloc(
      getShopsUseCase: sl(),
      getShopDetailUseCase: sl(),
      getShopProductsUseCase: sl(),
    ),
  );
}

void _initProduct() {
  // Datasource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => useMockData
        ? MockProductRemoteDataSource()
        : ProductRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl<ProductRepository>()));

  // BLoC
  sl.registerFactory<ProductDetailBloc>(
    () => ProductDetailBloc(getProductByIdUseCase: sl()),
  );
}

void _initProfile() {
  // Datasource
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => useMockData
        ? MockProfileRemoteDataSource()
        : ProfileRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => GetAddressesUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => AddAddressUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => RemoveAddressUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => SetDefaultAddressUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdatePreferencesUseCase(sl<ProfileRepository>()));

  // BLoC
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      changePasswordUseCase: sl(),
      getAddressesUseCase: sl(),
      addAddressUseCase: sl(),
      removeAddressUseCase: sl(),
      setDefaultAddressUseCase: sl(),
      updatePreferencesUseCase: sl(),
    ),
  );
}

void _initReview() {
  // Datasource
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => useMockData
        ? MockReviewRemoteDataSource()
        : ReviewRemoteDataSourceImpl(sl<ApiClient>()),
  );

  // Repository
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetShopReviewsUseCase(sl<ReviewRepository>()));
  sl.registerLazySingleton(() => GetProductReviewsUseCase(sl<ReviewRepository>()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl<ReviewRepository>()));
  sl.registerLazySingleton(() => GetRatingSummaryUseCase(sl<ReviewRepository>()));

  // BLoC
  sl.registerFactory<ReviewBloc>(
    () => ReviewBloc(
      getShopReviewsUseCase: sl(),
      getProductReviewsUseCase: sl(),
      submitReviewUseCase: sl(),
      getRatingSummaryUseCase: sl(),
    ),
  );
}

void _initNotifications() {
  // Datasource
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => MockNotificationRemoteDataSource(),
  );

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => GetUnreadCountUseCase(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => MarkAllNotificationsReadUseCase(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => DeleteNotificationUseCase(sl<NotificationRepository>()));

  // BLoC
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      getUnreadCountUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllReadUseCase: sl(),
      deleteNotificationUseCase: sl(),
    ),
  );
}

void _initPayment() {
  // Datasource
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => MockPaymentRemoteDataSource(),
  );

  // Repository
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(sl<PaymentRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPaymentProofsUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => GetPaymentProofUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => GetPaymentHistoryUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => GetShopBalanceUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => SubmitPaymentProofUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton(() => ValidatePaymentProofUseCase(sl<PaymentRepository>()));

  // BLoC
  sl.registerFactory<PaymentBloc>(
    () => PaymentBloc(
      getPaymentProofsUseCase: sl(),
      getPaymentProofUseCase: sl(),
      getPaymentHistoryUseCase: sl(),
      getShopBalanceUseCase: sl(),
      submitPaymentProofUseCase: sl(),
      validatePaymentProofUseCase: sl(),
    ),
  );
}
