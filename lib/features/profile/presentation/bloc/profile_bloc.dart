import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/address.dart';
import '../../domain/usecases/profile_usecases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required GetAddressesUseCase getAddressesUseCase,
    required AddAddressUseCase addAddressUseCase,
    required RemoveAddressUseCase removeAddressUseCase,
    required SetDefaultAddressUseCase setDefaultAddressUseCase,
    required UpdatePreferencesUseCase updatePreferencesUseCase,
  })  : _getProfile = getProfileUseCase,
        _updateProfile = updateProfileUseCase,
        _changePassword = changePasswordUseCase,
        _getAddresses = getAddressesUseCase,
        _addAddress = addAddressUseCase,
        _removeAddress = removeAddressUseCase,
        _setDefault = setDefaultAddressUseCase,
        _updatePrefs = updatePreferencesUseCase,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileUpdateRequested>(_onUpdate);
    on<ProfilePasswordChangeRequested>(_onPasswordChange);
    on<ProfileAddressesLoadRequested>(_onLoadAddresses);
    on<ProfileAddressAddRequested>(_onAddAddress);
    on<ProfileAddressRemoveRequested>(_onRemoveAddress);
    on<ProfileAddressDefaultRequested>(_onSetDefault);
    on<ProfilePreferencesUpdateRequested>(_onUpdatePrefs);
  }

  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final ChangePasswordUseCase _changePassword;
  final GetAddressesUseCase _getAddresses;
  final AddAddressUseCase _addAddress;
  final RemoveAddressUseCase _removeAddress;
  final SetDefaultAddressUseCase _setDefault;
  final UpdatePreferencesUseCase _updatePrefs;

  Future<void> _onLoad(
      ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(profileStatus: ProfileStatus.loading));
    final result = await _getProfile(NoParams());
    result.fold(
      (f) => emit(state.copyWith(
          profileStatus: ProfileStatus.failure, error: f.message)),
      (user) => emit(state.copyWith(
          profileStatus: ProfileStatus.success, profile: user)),
    );
  }

  Future<void> _onUpdate(
      ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(actionStatus: ProfileActionStatus.loading));
    final result = await _updateProfile(UpdateProfileParams(
      fullName: event.fullName,
      email: event.email,
      bio: event.bio,
      profileImageUrl: event.profileImageUrl,
    ));
    result.fold(
      (f) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.failure, error: f.message)),
      (user) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.success, profile: user)),
    );
  }

  Future<void> _onPasswordChange(
      ProfilePasswordChangeRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(actionStatus: ProfileActionStatus.loading));
    final result = await _changePassword(ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    ));
    result.fold(
      (f) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.failure, error: f.message)),
      (_) => emit(
          state.copyWith(actionStatus: ProfileActionStatus.success)),
    );
  }

  Future<void> _onLoadAddresses(
      ProfileAddressesLoadRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(addressStatus: ProfileStatus.loading));
    final result = await _getAddresses(NoParams());
    result.fold(
      (f) => emit(state.copyWith(
          addressStatus: ProfileStatus.failure, error: f.message)),
      (list) => emit(state.copyWith(
          addressStatus: ProfileStatus.success, addresses: list)),
    );
  }

  Future<void> _onAddAddress(
      ProfileAddressAddRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(actionStatus: ProfileActionStatus.loading));
    final result = await _addAddress(event.address);
    result.fold(
      (f) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.failure, error: f.message)),
      (addr) {
        final updated = [...state.addresses, addr];
        emit(state.copyWith(
            actionStatus: ProfileActionStatus.success, addresses: updated));
      },
    );
  }

  Future<void> _onRemoveAddress(
      ProfileAddressRemoveRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(actionStatus: ProfileActionStatus.loading));
    final result = await _removeAddress(event.id);
    result.fold(
      (f) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.failure, error: f.message)),
      (_) {
        final updated = state.addresses.where((a) => a.id != event.id).toList();
        emit(state.copyWith(
            actionStatus: ProfileActionStatus.success, addresses: updated));
      },
    );
  }

  Future<void> _onSetDefault(
      ProfileAddressDefaultRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(actionStatus: ProfileActionStatus.loading));
    final result = await _setDefault(event.id);
    result.fold(
      (f) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.failure, error: f.message)),
      (_) {
        final updated = state.addresses
            .map((a) => a.copyWith(isDefault: a.id == event.id))
            .toList();
        emit(state.copyWith(
            actionStatus: ProfileActionStatus.success, addresses: updated));
      },
    );
  }

  Future<void> _onUpdatePrefs(
      ProfilePreferencesUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(actionStatus: ProfileActionStatus.loading));
    final result = await _updatePrefs(event.preferences);
    result.fold(
      (f) => emit(state.copyWith(
          actionStatus: ProfileActionStatus.failure, error: f.message)),
      (_) =>
          emit(state.copyWith(actionStatus: ProfileActionStatus.success)),
    );
  }
}
