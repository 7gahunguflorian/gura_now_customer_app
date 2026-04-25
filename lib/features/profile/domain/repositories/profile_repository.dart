import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/address.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> getProfile();
  Future<Either<Failure, User>> updateProfile({
    String? fullName,
    String? email,
    String? bio,
    String? profileImageUrl,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, List<Address>>> getAddresses();
  Future<Either<Failure, Address>> addAddress(Address address);
  Future<Either<Failure, void>> removeAddress(String id);
  Future<Either<Failure, void>> setDefaultAddress(String id);
  Future<Either<Failure, void>> updatePreferences(
      Map<String, dynamic> preferences);
}
