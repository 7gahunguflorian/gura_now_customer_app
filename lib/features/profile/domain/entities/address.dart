import 'package:equatable/equatable.dart';

class Address extends Equatable {
  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    this.city,
    this.phone,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullAddress;
  final String? city;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? phone,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) =>
      Address(
        id: id ?? this.id,
        label: label ?? this.label,
        fullAddress: fullAddress ?? this.fullAddress,
        city: city ?? this.city,
        phone: phone ?? this.phone,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isDefault: isDefault ?? this.isDefault,
      );

  @override
  List<Object?> get props =>
      [id, label, fullAddress, city, phone, latitude, longitude, isDefault];
}
