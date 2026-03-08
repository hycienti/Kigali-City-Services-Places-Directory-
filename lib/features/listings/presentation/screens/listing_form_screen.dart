import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/listing.dart';
import '../providers/listing_providers.dart';

class ListingFormScreen extends ConsumerStatefulWidget {
  const ListingFormScreen({
    super.key,
    this.listingId,
  });

  /// For edit mode, pass the listing id. For create, leave null.
  final String? listingId;

  @override
  ConsumerState<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends ConsumerState<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  ListingCategory _category = ListingCategory.other;
  bool _isLoading = false;
  bool _initializedFromListing = false;

  bool get isEdit => widget.listingId != null && widget.listingId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _contactController = TextEditingController();
    _descriptionController = TextEditingController();
    _latController = TextEditingController();
    _lngController = TextEditingController();
  }

  void _initFromListing(Listing l) {
    if (_initializedFromListing) return;
    _initializedFromListing = true;
    _nameController.text = l.name;
    _addressController.text = l.address;
    _contactController.text = l.contactNumber;
    _descriptionController.text = l.description;
    _latController.text = l.latitude.toString();
    _lngController.text = l.longitude.toString();
    _category = l.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final lat = double.tryParse(_latController.text.trim());
      final lng = double.tryParse(_lngController.text.trim());
      if (lat == null || lng == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter valid latitude and longitude')),
        );
        return;
      }

      Listing? listingToUpdate;
      if (isEdit && widget.listingId != null) {
        listingToUpdate = await ref.read(listingDetailProvider(widget.listingId!).future);
      }
      if (isEdit && listingToUpdate != null) {
        final updated = listingToUpdate.copyWith(
          name: _nameController.text.trim(),
          category: _category,
          address: _addressController.text.trim(),
          contactNumber: _contactController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: lat,
          longitude: lng,
        );
        await ref.read(listingCrudProvider.notifier).updateListing(updated);
      } else {
        final listing = Listing(
          id: '',
          name: _nameController.text.trim(),
          category: _category,
          address: _addressController.text.trim(),
          contactNumber: _contactController.text.trim(),
          description: _descriptionController.text.trim(),
          latitude: lat,
          longitude: lng,
          createdBy: currentUser.uid,
          timestamp: DateTime.now(),
        );
        await ref.read(listingCrudProvider.notifier).createListing(listing);
      }
      if (!mounted) return;
      ref.read(listingCrudProvider.notifier).reset();
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEdit ? 'Listing updated' : 'Listing created')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = isEdit && widget.listingId != null
        ? ref.watch(listingDetailProvider(widget.listingId!))
        : const AsyncValue.data(null);

    if (isEdit) {
      return listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit listing'),
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
              ),
              body: const Center(child: Text('Listing not found')),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_initializedFromListing) {
              _initFromListing(listing);
              _initializedFromListing = true;
            }
          });
          return _buildForm(context);
        },
        loading: () => Scaffold(
          appBar: AppBar(
            title: const Text('Edit listing'),
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit listing'),
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
          ),
          body: Center(child: Text('Error: $e')),
        ),
      );
    }
    return _buildForm(context);
  }

  Widget _buildForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit listing' : 'Add listing'),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ListingCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ListingCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEdit ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
