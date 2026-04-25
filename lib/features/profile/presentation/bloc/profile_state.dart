part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, success, failure }
enum ProfileActionStatus { idle, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.profileStatus = ProfileStatus.initial,
    this.addressStatus = ProfileStatus.initial,
    this.actionStatus = ProfileActionStatus.idle,
    this.profile,
    this.addresses = const [],
    this.error,
  });

  final ProfileStatus profileStatus;
  final ProfileStatus addressStatus;
  final ProfileActionStatus actionStatus;
  final User? profile;
  final List<Address> addresses;
  final String? error;

  @override
  List<Object?> get props => [
        profileStatus,
        addressStatus,
        actionStatus,
        profile,
        addresses,
        error,
      ];

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    ProfileStatus? addressStatus,
    ProfileActionStatus? actionStatus,
    User? profile,
    List<Address>? addresses,
    String? error,
  }) =>
      ProfileState(
        profileStatus: profileStatus ?? this.profileStatus,
        addressStatus: addressStatus ?? this.addressStatus,
        actionStatus: actionStatus ?? this.actionStatus,
        profile: profile ?? this.profile,
        addresses: addresses ?? this.addresses,
        error: error ?? this.error,
      );
}
