import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../entities/address.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<User, NoParams> {
  GetProfileUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, User>> call(NoParams _) =>
      _repository.getProfile();
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    this.fullName,
    this.email,
    this.bio,
    this.profileImageUrl,
  });
  final String? fullName;
  final String? email;
  final String? bio;
  final String? profileImageUrl;

  @override
  List<Object?> get props => [fullName, email, bio, profileImageUrl];
}

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams p) =>
      _repository.updateProfile(
        fullName: p.fullName,
        email: p.email,
        bio: p.bio,
        profileImageUrl: p.profileImageUrl,
      );
}

class ChangePasswordParams extends Equatable {
  const ChangePasswordParams(
      {required this.currentPassword, required this.newPassword});
  final String currentPassword;
  final String newPassword;

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  ChangePasswordUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams p) =>
      _repository.changePassword(
          currentPassword: p.currentPassword, newPassword: p.newPassword);
}

class GetAddressesUseCase implements UseCase<List<Address>, NoParams> {
  GetAddressesUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, List<Address>>> call(NoParams _) =>
      _repository.getAddresses();
}

class AddAddressUseCase implements UseCase<Address, Address> {
  AddAddressUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Address>> call(Address address) =>
      _repository.addAddress(address);
}

class RemoveAddressUseCase implements UseCase<void, String> {
  RemoveAddressUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, void>> call(String id) =>
      _repository.removeAddress(id);
}

class SetDefaultAddressUseCase implements UseCase<void, String> {
  SetDefaultAddressUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, void>> call(String id) =>
      _repository.setDefaultAddress(id);
}

class UpdatePreferencesUseCase
    implements UseCase<void, Map<String, dynamic>> {
  UpdatePreferencesUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, void>> call(Map<String, dynamic> prefs) =>
      _repository.updatePreferences(prefs);
}
