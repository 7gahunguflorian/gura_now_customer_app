/// Mock implementation of Profile Remote Data Source.
library;

import '../../features/auth/data/models/user_model.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/domain/entities/address.dart';
import 'mock_data.dart';

class MockProfileRemoteDataSource implements ProfileRemoteDataSource {
  @override
  Future<UserModel> getProfile() async {
    await MockData.simulateDelay();
    final user = MockData.getUserById('user-1');
    if (user == null) throw Exception('Profile not found');
    return user;
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? bio,
    String? profileImageUrl,
  }) async {
    await MockData.simulateDelay();
    final user = MockData.getUserById('user-1');
    if (user == null) throw Exception('Profile not found');
    final updated = user.copyWith(
      fullName: fullName,
      email: email,
      bio: bio,
      profileImageUrl: profileImageUrl,
    );
    final idx = MockData.users.indexWhere((u) => u.id == 'user-1');
    if (idx >= 0) MockData.users[idx] = updated;
    return updated;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await MockData.simulateDelay();
  }

  @override
  Future<List<Address>> getAddresses() async {
    await MockData.simulateDelay();
    return MockData.getAddressesForUser('user-1');
  }

  @override
  Future<Address> addAddress(Address address) async {
    await MockData.simulateDelay();
    final newAddr = address.copyWith(
        id: 'addr-${DateTime.now().millisecondsSinceEpoch}');
    MockData.addresses.add(newAddr);
    return newAddr;
  }

  @override
  Future<void> removeAddress(String id) async {
    await MockData.simulateDelay();
    MockData.addresses.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    await MockData.simulateDelay();
    MockData.addresses = MockData.addresses
        .map((a) => a.copyWith(isDefault: a.id == id))
        .toList();
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await MockData.simulateDelay();
  }
}
