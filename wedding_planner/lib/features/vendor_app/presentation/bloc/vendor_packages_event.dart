import 'package:equatable/equatable.dart';
import '../../domain/repositories/vendor_app_repository.dart';

abstract class VendorPackagesEvent extends Equatable {
  const VendorPackagesEvent();

  @override
  List<Object?> get props => [];
}

/// Load vendor packages
class LoadVendorPackages extends VendorPackagesEvent {
  const LoadVendorPackages();
}

/// Create a new package
class CreateVendorPackage extends VendorPackagesEvent {
  final CreatePackageRequest request;

  const CreateVendorPackage(this.request);

  @override
  List<Object?> get props => [request];
}

/// Update an existing package
class UpdateVendorPackage extends VendorPackagesEvent {
  final String packageId;
  final UpdatePackageRequest request;

  const UpdateVendorPackage({
    required this.packageId,
    required this.request,
  });

  @override
  List<Object?> get props => [packageId, request];
}

/// Delete a package
class DeleteVendorPackage extends VendorPackagesEvent {
  final String packageId;

  const DeleteVendorPackage(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

/// Load vendor profile
class LoadVendorProfile extends VendorPackagesEvent {
  const LoadVendorProfile();
}

/// Update vendor profile
class UpdateVendorProfile extends VendorPackagesEvent {
  final UpdateVendorProfileRequest request;

  const UpdateVendorProfile(this.request);

  @override
  List<Object?> get props => [request];
}

/// Clear action status
class ClearPackageAction extends VendorPackagesEvent {
  const ClearPackageAction();
}
