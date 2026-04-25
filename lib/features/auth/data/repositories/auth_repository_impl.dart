import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  @override
  Future<Either<Failure, User>> login(String phoneNumber, String password) async {
    try {
      final response = await _remoteDataSource.login(phoneNumber, password);

      // Persist session
      await _secureStorage.saveToken(response.accessToken);
      await _secureStorage.saveUser(response.user);

      return Right(response.user.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String phoneNumber,
    required String password,
    required String role,
    String? email,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        role: role,
      );

      // Persist session (Auto login)
      await _secureStorage.saveToken(response.accessToken);
      await _secureStorage.saveUser(response.user);

      return Right(response.user.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _secureStorage.clear(); // Clear local first for responsiveness
      await _remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getMe() async {
    try {
      final userModel = await _remoteDataSource.getMe();
      await _secureStorage.saveUser(userModel); // Update local cache
      return Right(userModel.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
