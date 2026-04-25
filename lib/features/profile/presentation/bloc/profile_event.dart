part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({
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

class ProfilePasswordChangeRequested extends ProfileEvent {
  const ProfilePasswordChangeRequested({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ProfileAddressesLoadRequested extends ProfileEvent {
  const ProfileAddressesLoadRequested();
}

class ProfileAddressAddRequested extends ProfileEvent {
  const ProfileAddressAddRequested(this.address);
  final Address address;

  @override
  List<Object?> get props => [address];
}

class ProfileAddressRemoveRequested extends ProfileEvent {
  const ProfileAddressRemoveRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ProfileAddressDefaultRequested extends ProfileEvent {
  const ProfileAddressDefaultRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class ProfilePreferencesUpdateRequested extends ProfileEvent {
  const ProfilePreferencesUpdateRequested(this.preferences);
  final Map<String, dynamic> preferences;

  @override
  List<Object?> get props => [preferences];
}
