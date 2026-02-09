import 'package:equatable/equatable.dart';
import '../../../vendors/domain/entities/vendor.dart';
import '../../../vendors/domain/entities/vendor_package.dart';

enum PackagesLoadStatus { initial, loading, loaded, error }
enum ProfileLoadStatus { initial, loading, loaded, error }
enum PackageActionStatus { initial, loading, success, error }

class VendorPackagesState extends Equatable {
  // Packages
  final PackagesLoadStatus packagesStatus;
  final List<VendorPackage> packages;
  final String? packagesError;

  // Profile
  final ProfileLoadStatus profileStatus;
  final Vendor? profile;
  final String? profileError;

  // Action status (create, update, delete, profile update)
  final PackageActionStatus actionStatus;
  final String? actionError;
  final String? actionSuccessMessage;

  const VendorPackagesState({
    this.packagesStatus = PackagesLoadStatus.initial,
    this.packages = const [],
    this.packagesError,
    this.profileStatus = ProfileLoadStatus.initial,
    this.profile,
    this.profileError,
    this.actionStatus = PackageActionStatus.initial,
    this.actionError,
    this.actionSuccessMessage,
  });

  VendorPackagesState copyWith({
    PackagesLoadStatus? packagesStatus,
    List<VendorPackage>? packages,
    String? packagesError,
    ProfileLoadStatus? profileStatus,
    Vendor? profile,
    String? profileError,
    PackageActionStatus? actionStatus,
    String? actionError,
    String? actionSuccessMessage,
  }) {
    return VendorPackagesState(
      packagesStatus: packagesStatus ?? this.packagesStatus,
      packages: packages ?? this.packages,
      packagesError: packagesError,
      profileStatus: profileStatus ?? this.profileStatus,
      profile: profile ?? this.profile,
      profileError: profileError,
      actionStatus: actionStatus ?? this.actionStatus,
      actionError: actionError,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        packagesStatus,
        packages,
        packagesError,
        profileStatus,
        profile,
        profileError,
        actionStatus,
        actionError,
        actionSuccessMessage,
      ];
}
