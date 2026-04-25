/// Central mock data repository for Gura Now application.
/// This file contains all mock data used throughout the app for development.
library;

import 'dart:math';

import '../../features/auth/data/models/user_model.dart';
import '../../features/profile/domain/entities/address.dart';
import '../../features/review/data/models/review_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/shop/domain/entities/product.dart';
import '../../features/orders/data/models/order_model.dart';
import '../../features/orders/data/models/order_item_model.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/payment/data/models/payment_proof_model.dart';
import '../../features/notifications/data/models/notification_model.dart';

/// Mock data repository providing sample data for all features.
class MockData {
  static final _random = Random();

  // Current user simulation
  static String? _currentUserId;
  static String? _currentUserRole;
  static String? _authToken;

  /// Initialize mock data with a logged-in user.
  static void login(String userId, String role, String token) {
    _currentUserId = userId;
    _currentUserRole = role;
    _authToken = token;
  }

  /// Clear login data.
  static void logout() {
    _currentUserId = null;
    _currentUserRole = null;
    _authToken = null;
  }

  /// Check if user is logged in.
  static bool get isLoggedIn => _currentUserId != null;

  /// Get current user ID.
  static String? get currentUserId => _currentUserId;

  /// Get current user role.
  static String? get currentUserRole => _currentUserRole;

  /// Get auth token.
  static String? get authToken => _authToken;

  // ============================================
  // USER MOCK DATA
  // ============================================

  static final List<UserModel> users = [
    UserModel(
      id: 'user-1',
      phoneNumber: '+250788123456',
      fullName: 'Jean Baptiste',
      email: 'jean@example.com',
      role: 'customer',
      isActive: true,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserModel(
      id: 'user-2',
      phoneNumber: '+250788234567',
      fullName: 'Marie Claire',
      email: 'marie@example.com',
      role: 'shop_owner',
      isActive: true,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    UserModel(
      id: 'user-3',
      phoneNumber: '+250788345678',
      fullName: 'Eric Mugisha',
      email: 'eric@example.com',
      role: 'driver',
      isActive: true,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserModel(
      id: 'user-4',
      phoneNumber: '+250788456789',
      fullName: 'Admin User',
      email: 'admin@example.com',
      role: 'admin',
      isActive: true,
      isVerified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  static UserModel? getUserById(String id) {
    try {
      return users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  static UserModel? getUserByPhone(String phoneNumber) {
    try {
      return users.firstWhere((user) => user.phoneNumber == phoneNumber);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // SHOP MOCK DATA
  // ============================================

  static final List<ShopModel> shops = [
    const ShopModel(
      id: 'shop-1',
      name: 'Marché Central',
      description: 'Fresh vegetables and fruits daily',
      logoUrl: 'https://picsum.photos/seed/shop1/400/300',
      deliveryScope: 'Gasabo District',
      type: 'Market',
      rating: 4.5,
      totalReviews: 120,
    ),
    const ShopModel(
      id: 'shop-2',
      name: 'Kimironko Market',
      description: 'Traditional African foods and spices',
      logoUrl: 'https://picsum.photos/seed/shop2/400/300',
      deliveryScope: 'Kigali City',
      type: 'Market',
      rating: 4.7,
      totalReviews: 85,
    ),
    const ShopModel(
      id: 'shop-3',
      name: 'Nyabugogo Market',
      description: 'Wholesale and retail marketplace',
      logoUrl: 'https://picsum.photos/seed/shop3/400/300',
      deliveryScope: 'Nyarugenge District',
      type: 'Market',
      rating: 4.2,
      totalReviews: 67,
    ),
    const ShopModel(
      id: 'shop-4',
      name: 'Green Grocer',
      description: 'Organic vegetables and fruits',
      logoUrl: 'https://picsum.photos/seed/shop4/400/300',
      deliveryScope: 'Kigali City',
      type: 'Grocery',
      rating: 4.8,
      totalReviews: 95,
    ),
  ];

  static ShopModel? getShopById(String id) {
    try {
      return shops.firstWhere((shop) => shop.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ShopModel> getShops(
      {String? category, int limit = 20, int offset = 0}) {
    var filtered = shops;
    if (category != null) {
      filtered = shops.where((shop) => shop.type == category).toList();
    }
    return filtered.skip(offset).take(limit).toList();
  }

  // ============================================
  // ORDER MOCK DATA
  // ============================================

  static final List<OrderModel> orders = [
    OrderModel(
      id: 'order-1',
      customerId: 'user-1',
      shopId: 'shop-1',
      items: const [
        OrderItemModel(
          productId: 'prod-1',
          quantity: 5,
          price: 2000,
        ),
        OrderItemModel(
          productId: 'prod-2',
          quantity: 3,
          price: 1500,
        ),
        OrderItemModel(
          productId: 'prod-3',
          quantity: 10,
          price: 1050,
        ),
      ],
      status: OrderStatus.pending,
      total: 25000,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      shippingAddress: 'KG 15 Ave, Kigali',
    ),
    OrderModel(
      id: 'order-2',
      customerId: 'user-1',
      shopId: 'shop-2',
      items: const [
        OrderItemModel(
          productId: 'prod-4',
          quantity: 2,
          price: 15000,
        ),
        OrderItemModel(
          productId: 'prod-5',
          quantity: 3,
          price: 5000,
        ),
      ],
      status: OrderStatus.confirmed,
      total: 45000,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      shippingAddress: 'KN 3 Rd, Kigali',
    ),
    OrderModel(
      id: 'order-3',
      customerId: 'user-1',
      shopId: 'shop-1',
      items: const [
        OrderItemModel(
          productId: 'prod-6',
          quantity: 1,
          price: 8500,
        ),
        OrderItemModel(
          productId: 'prod-7',
          quantity: 10,
          price: 1000,
        ),
      ],
      status: OrderStatus.delivered,
      total: 18500,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      shippingAddress: 'KG 15 Ave, Kigali',
    ),
  ];

  static OrderModel? getOrderById(String id) {
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<OrderModel> getOrders({String? status, String? userId}) {
    var filtered = orders;
    if (status != null) {
      filtered = filtered.where((order) => order.status == status).toList();
    }
    if (userId != null) {
      filtered = filtered.where((order) => order.customerId == userId).toList();
    }
    return filtered;
  }

  // ============================================
  // NOTIFICATION MOCK DATA
  // ============================================

  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif-1',
      userId: 'user-1',
      title: 'Order Confirmed',
      message: 'Your order #order-2 has been confirmed by the shop',
      type: 'order_update',
      relatedOrderId: 'order-2',
      relatedShopId: 'shop-2',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NotificationModel(
      id: 'notif-2',
      userId: 'user-1',
      title: 'Payment Received',
      message: 'Your payment proof has been verified',
      type: 'payment_update',
      relatedOrderId: 'order-3',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif-3',
      userId: 'user-1',
      title: 'Order Delivered',
      message: 'Your order #order-3 has been delivered successfully',
      type: 'order_update',
      relatedOrderId: 'order-3',
      relatedShopId: 'shop-1',
      isRead: true,
      readAt: DateTime.now().subtract(const Duration(days: 4, hours: -2)),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    NotificationModel(
      id: 'notif-4',
      userId: 'user-1',
      title: 'New Products Available',
      message: 'Check out the fresh arrivals at Marché Central',
      type: 'info',
      relatedShopId: 'shop-1',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static List<NotificationModel> getNotifications({
    String? userId,
    bool unreadOnly = false,
    int skip = 0,
    int limit = 50,
  }) {
    var filtered = notifications;
    if (userId != null) {
      filtered = filtered.where((n) => n.userId == userId).toList();
    }
    if (unreadOnly) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }
    return filtered.skip(skip).take(limit).toList();
  }

  static int getUnreadCount({String? userId}) {
    var filtered = notifications;
    if (userId != null) {
      filtered = filtered.where((n) => n.userId == userId).toList();
    }
    return filtered.where((n) => !n.isRead).length;
  }

  // ============================================
  // PAYMENT MOCK DATA
  // ============================================

  static final List<PaymentProofModel> paymentProofs = [
    PaymentProofModel(
      id: 'pay-1',
      orderId: 'order-3',
      orderNumber: 'ORD-003',
      uploadedBy: 'user-1',
      uploaderName: 'Jean Baptiste',
      imageUrls: const [
        {
          'url': 'https://picsum.photos/seed/pay1/400/600',
          'type': 'payment_proof'
        }
      ],
      status: 'approved',
      validatedBy: 'user-4',
      validatorName: 'Admin User',
      validatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    PaymentProofModel(
      id: 'pay-2',
      orderId: 'order-2',
      orderNumber: 'ORD-002',
      uploadedBy: 'user-1',
      uploaderName: 'Jean Baptiste',
      imageUrls: const [
        {
          'url': 'https://picsum.photos/seed/pay2/400/600',
          'type': 'payment_proof'
        }
      ],
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    PaymentProofModel(
      id: 'pay-3',
      orderId: 'order-1',
      orderNumber: 'ORD-001',
      uploadedBy: 'user-1',
      uploaderName: 'Jean Baptiste',
      imageUrls: const [
        {
          'url': 'https://picsum.photos/seed/pay3a/400/600',
          'type': 'payment_proof'
        },
        {
          'url': 'https://picsum.photos/seed/pay3b/400/600',
          'type': 'payment_proof'
        }
      ],
      status: 'rejected',
      validatedBy: 'user-4',
      validatorName: 'Admin User',
      validatedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      rejectionReason: 'Image not clear, please resubmit with better quality',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  static PaymentProofModel? getPaymentProofById(String id) {
    try {
      return paymentProofs.firstWhere((proof) => proof.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // PRODUCT MOCK DATA
  // ============================================

  static final List<Product> products = [
    const Product(
      id: 'prod-1',
      name: 'Tomates fraîches',
      description: 'Tomates locales fraîches cueillies ce matin.',
      price: 1500,
      shopId: 'shop-1',
      shopName: 'Marché Central',
      imageUrl: 'https://picsum.photos/seed/prod1/400/400',
      rating: 4.5,
      reviewCount: 12,
      stock: 50,
    ),
    const Product(
      id: 'prod-2',
      name: 'Pommes de terre',
      description: 'Pommes de terre de qualité supérieure.',
      price: 2000,
      shopId: 'shop-1',
      shopName: 'Marché Central',
      imageUrl: 'https://picsum.photos/seed/prod2/400/400',
      rating: 4.2,
      reviewCount: 8,
      stock: 30,
    ),
    const Product(
      id: 'prod-3',
      name: 'Avocats',
      description: 'Avocats mûrs importés.',
      price: 3000,
      shopId: 'shop-1',
      shopName: 'Marché Central',
      imageUrl: 'https://picsum.photos/seed/prod3/400/400',
      rating: 4.8,
      reviewCount: 20,
      stock: 15,
    ),
    const Product(
      id: 'prod-4',
      name: 'Épices mélangées',
      description: 'Mélange traditionnel d\'épices africaines.',
      price: 5000,
      shopId: 'shop-2',
      shopName: 'Kimironko Market',
      imageUrl: 'https://picsum.photos/seed/prod4/400/400',
      rating: 4.6,
      reviewCount: 35,
      stock: 100,
    ),
    const Product(
      id: 'prod-5',
      name: 'Haricots rouges',
      description: 'Haricots rouges secs en vrac.',
      price: 2500,
      shopId: 'shop-2',
      shopName: 'Kimironko Market',
      imageUrl: 'https://picsum.photos/seed/prod5/400/400',
      rating: 4.3,
      reviewCount: 18,
      stock: 200,
    ),
    const Product(
      id: 'prod-6',
      name: 'Bananes plantain',
      description: 'Bananes plantains vertes et mûres.',
      price: 1800,
      shopId: 'shop-3',
      shopName: 'Nyabugogo Market',
      imageUrl: 'https://picsum.photos/seed/prod6/400/400',
      rating: 4.0,
      reviewCount: 9,
      stock: 80,
    ),
    const Product(
      id: 'prod-7',
      name: 'Carottes bio',
      description: 'Carottes biologiques cultivées localement.',
      price: 2200,
      shopId: 'shop-4',
      shopName: 'Green Grocer',
      imageUrl: 'https://picsum.photos/seed/prod7/400/400',
      rating: 4.9,
      reviewCount: 42,
      stock: 60,
    ),
    const Product(
      id: 'prod-8',
      name: 'Salade verte',
      description: 'Laitue fraîche récoltée quotidiennement.',
      price: 1200,
      shopId: 'shop-4',
      shopName: 'Green Grocer',
      imageUrl: 'https://picsum.photos/seed/prod8/400/400',
      rating: 4.7,
      reviewCount: 28,
      stock: 40,
    ),
  ];

  static List<Product> getProductsByShopId(String shopId) =>
      products.where((p) => p.shopId == shopId).toList();

  static Product? getProductById(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // REVIEW MOCK DATA
  // ============================================

  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'rev-1',
      userId: 'user-1',
      userName: 'Jean Baptiste',
      rating: 5,
      comment: 'Excellent service, livraison rapide!',
      shopId: 'shop-1',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReviewModel(
      id: 'rev-2',
      userId: 'user-2',
      userName: 'Marie Claire',
      rating: 4,
      comment: 'Bonne qualité des produits.',
      shopId: 'shop-1',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ReviewModel(
      id: 'rev-3',
      userId: 'user-1',
      userName: 'Jean Baptiste',
      rating: 4,
      comment: 'Très bonne boutique.',
      shopId: 'shop-2',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ReviewModel(
      id: 'rev-4',
      userId: 'user-3',
      userName: 'Eric Mugisha',
      rating: 3,
      comment: 'Correct mais peut mieux faire.',
      productId: 'prod-1',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  static List<ReviewModel> getShopReviews(String shopId) =>
      reviews.where((r) => r.shopId == shopId).toList();

  static List<ReviewModel> getProductReviews(String productId) =>
      reviews.where((r) => r.productId == productId).toList();

  // ============================================
  // ADDRESS MOCK DATA
  // ============================================

  static List<Address> addresses = [
    const Address(
      id: 'addr-1',
      label: 'Maison',
      fullAddress: 'Avenue de l\'Indépendance, Quartier Buyenzi',
      city: 'Bujumbura',
      phone: '+257 79 123 456',
      isDefault: true,
    ),
    const Address(
      id: 'addr-2',
      label: 'Bureau',
      fullAddress: 'Rue du Commerce, Centre-ville',
      city: 'Bujumbura',
      phone: '+257 79 234 567',
      isDefault: false,
    ),
  ];

  static List<Address> getAddressesForUser(String userId) => addresses;

  // ============================================
  // DELIVERY MOCK DATA
  // ============================================

  // ============================================
  // ADMIN STATS MOCK DATA
  // ============================================

  static Map<String, dynamic> adminStats = {
    'total_users': 1250,
    'total_shops': 45,
    'total_orders': 3420,
    'total_revenue': 45600000.0,
    'active_deliveries': 23,
    'pending_verifications': 8,
  };

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Simulate network delay.
  static Future<void> simulateDelay({int milliseconds = 500}) async {
    await Future.delayed(
        Duration(milliseconds: milliseconds + _random.nextInt(500)));
  }

  /// Generate a mock auth token.
  static String generateMockToken() =>
      'mock_token_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
}
