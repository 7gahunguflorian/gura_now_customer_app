import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../profile/domain/entities/address.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? bio,
    String? profileImageUrl,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<List<Address>> getAddresses();
  Future<Address> addAddress(Address address);
  Future<void> removeAddress(String id);
  Future<void> setDefaultAddress(String id);
  Future<void> updatePreferences(Map<String, dynamic> preferences);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<UserModel> getProfile() async {
    final data = await _apiClient.get(ApiEndpoints.usersProfile);
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? bio,
    String? profileImageUrl,
  }) async {
    final body = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (bio != null) 'bio': bio,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    };
    final data = await _apiClient.patch(ApiEndpoints.usersProfile, body: body);
    return UserModel.fromJson(data);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(ApiEndpoints.authChangePassword, {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  @override
  Future<List<Address>> getAddresses() async {
    final data = await _apiClient.get('/users/me/addresses');
    final list = data is List
        ? data as List<dynamic>
        : (data['addresses'] as List<dynamic>? ?? []);
    return list.map((e) => _addressFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Address> addAddress(Address address) async {
    final data = await _apiClient
        .post('/users/me/addresses', _addressToJson(address));
    return _addressFromJson(data);
  }

  @override
  Future<void> removeAddress(String id) async {
    await _apiClient.delete('/users/me/addresses/$id');
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    await _apiClient.patch('/users/me/addresses/$id/default', body: {});
  }

  @override
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    await _apiClient.patch('/users/me/preferences', body: preferences);
  }

  Address _addressFromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        label: json['label'] as String,
        fullAddress: json['full_address'] as String,
        city: json['city'] as String?,
        phone: json['phone'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        isDefault: json['is_default'] as bool? ?? false,
      );

  Map<String, dynamic> _addressToJson(Address a) => {
        'label': a.label,
        'full_address': a.fullAddress,
        if (a.city != null) 'city': a.city,
        if (a.phone != null) 'phone': a.phone,
        if (a.latitude != null) 'latitude': a.latitude,
        if (a.longitude != null) 'longitude': a.longitude,
        'is_default': a.isDefault,
      };
}
