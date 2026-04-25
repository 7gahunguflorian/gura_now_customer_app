import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/address.dart';
import '../bloc/profile_bloc.dart';

/// Screen for managing delivery addresses.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileAddressesLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, n) =>
          p.addresses != n.addresses || p.addressStatus != n.addressStatus,
      builder: (context, state) {
        final addresses = state.addresses;
        return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mes adresses'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: state.addressStatus == ProfileStatus.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : addresses.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune adresse enregistrée',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddressForm(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Ajouter une adresse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return _AddressCard(
                    address: address,
                    onEdit: () => _showAddressForm(address: address),
                    onDelete: () => _deleteAddress(address),
                    onSetDefault: () => _setDefaultAddress(address),
                  );
                },
              ),
        floatingActionButton: addresses.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _showAddressForm(),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add_rounded),
              )
            : null,
        );
      },
    );
  }

  void _showAddressForm({Address? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddressFormSheet(
        address: address,
        onSave: (newAddress) {
          context.read<ProfileBloc>().add(ProfileAddressAddRequested(newAddress));
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _deleteAddress(Address address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Supprimer l\'adresse',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Voulez-vous supprimer "${address.label}" ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileBloc>().add(ProfileAddressRemoveRequested(address.id));
              Navigator.pop(ctx);
            },
            child: Text('Supprimer', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(Address address) {
    context.read<ProfileBloc>().add(ProfileAddressDefaultRequested(address.id));
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: address.isDefault ? AppColors.primary : AppColors.borderGray,
            width: address.isDefault ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: address.isDefault
                        ? AppColors.primary
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getLabelIcon(address.label),
                        size: 14,
                        color: address.isDefault ? AppColors.textOnPrimary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: address.isDefault ? AppColors.textOnPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Par défaut',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                PopupMenuButton(
                  color: AppColors.surfaceLight,
                  icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: onEdit,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
                          const SizedBox(width: 8),
                          Text('Modifier', style: TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      PopupMenuItem(
                        onTap: onSetDefault,
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 20, color: AppColors.textPrimary),
                            const SizedBox(width: 8),
                            Text('Définir par défaut', style: TextStyle(color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      onTap: onDelete,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                          const SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address.fullAddress,
                    style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            if (address.city != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_city_outlined, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    address.city!,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
            if (address.phone != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    address.phone!,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'maison':
        return Icons.home;
      case 'bureau':
        return Icons.work;
      default:
        return Icons.place;
    }
  }
}

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet({
    this.address,
    required this.onSave,
  });
  final Address? address;
  final Function(Address) onSave;

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _addressController =
        TextEditingController(text: widget.address?.fullAddress ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.address != null
                        ? 'Modifier l\'adresse'
                        : 'Nouvelle adresse',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Label
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'adresse',
                      hintText: 'Ex: Maison, Bureau',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le nom est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Full Address
                  TextFormField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Adresse complète',
                      hintText: 'Rue, quartier, repères',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'L\'adresse est requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // City
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Ex: Bujumbura',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Téléphone de contact',
                      hintText: '+257 XX XXX XXX',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Address(
        id: widget.address?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        label: _labelController.text.trim(),
        fullAddress: _addressController.text.trim(),
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        latitude: widget.address?.latitude,
        longitude: widget.address?.longitude,
        isDefault: widget.address?.isDefault ?? false,
      );
      widget.onSave(newAddress);
    }
  }
}
