import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import 'vendor_packages_event.dart';
import 'vendor_packages_state.dart';

class VendorPackagesBloc
    extends Bloc<VendorPackagesEvent, VendorPackagesState> {
  final VendorAppRepository repository;

  VendorPackagesBloc({required this.repository})
      : super(const VendorPackagesState()) {
    on<LoadVendorPackages>(_onLoadPackages);
    on<CreateVendorPackage>(_onCreatePackage);
    on<UpdateVendorPackage>(_onUpdatePackage);
    on<DeleteVendorPackage>(_onDeletePackage);
    on<LoadVendorProfile>(_onLoadProfile);
    on<UpdateVendorProfile>(_onUpdateProfile);
    on<RegisterVendorProfile>(_onRegisterProfile);
    on<ClearPackageAction>(_onClearAction);
  }

  Future<void> _onLoadPackages(
    LoadVendorPackages event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(packagesStatus: PackagesLoadStatus.loading));

    final result = await repository.getMyPackages();

    result.fold(
      (failure) => emit(state.copyWith(
        packagesStatus: PackagesLoadStatus.error,
        packagesError: failure.message,
      )),
      (packages) => emit(state.copyWith(
        packagesStatus: PackagesLoadStatus.loaded,
        packages: packages,
      )),
    );
  }

  Future<void> _onCreatePackage(
    CreateVendorPackage event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(actionStatus: PackageActionStatus.loading));

    final result = await repository.createPackage(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PackageActionStatus.error,
        actionError: failure.message,
      )),
      (package) {
        final updatedPackages = [...state.packages, package];
        emit(state.copyWith(
          actionStatus: PackageActionStatus.success,
          actionSuccessMessage: 'Package created',
          packages: updatedPackages,
        ));
      },
    );
  }

  Future<void> _onUpdatePackage(
    UpdateVendorPackage event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(actionStatus: PackageActionStatus.loading));

    final result = await repository.updatePackage(
      event.packageId,
      event.request,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PackageActionStatus.error,
        actionError: failure.message,
      )),
      (package) {
        final updatedPackages = state.packages.map((p) {
          if (p.id == event.packageId) {
            return package;
          }
          return p;
        }).toList();

        emit(state.copyWith(
          actionStatus: PackageActionStatus.success,
          actionSuccessMessage: 'Package updated',
          packages: updatedPackages,
        ));
      },
    );
  }

  Future<void> _onDeletePackage(
    DeleteVendorPackage event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(actionStatus: PackageActionStatus.loading));

    final result = await repository.deletePackage(event.packageId);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PackageActionStatus.error,
        actionError: failure.message,
      )),
      (_) {
        final updatedPackages = state.packages
            .where((p) => p.id != event.packageId)
            .toList();

        emit(state.copyWith(
          actionStatus: PackageActionStatus.success,
          actionSuccessMessage: 'Package deleted',
          packages: updatedPackages,
        ));
      },
    );
  }

  Future<void> _onLoadProfile(
    LoadVendorProfile event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(profileStatus: ProfileLoadStatus.loading));

    final result = await repository.getMyProfile();

    result.fold(
      (failure) => emit(state.copyWith(
        profileStatus: ProfileLoadStatus.error,
        profileError: failure.message,
      )),
      (profile) => emit(state.copyWith(
        profileStatus: ProfileLoadStatus.loaded,
        profile: profile,
      )),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateVendorProfile event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(actionStatus: PackageActionStatus.loading));

    final result = await repository.updateProfile(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PackageActionStatus.error,
        actionError: failure.message,
      )),
      (profile) => emit(state.copyWith(
        actionStatus: PackageActionStatus.success,
        actionSuccessMessage: 'Profile updated',
        profile: profile,
      )),
    );
  }

  Future<void> _onRegisterProfile(
    RegisterVendorProfile event,
    Emitter<VendorPackagesState> emit,
  ) async {
    emit(state.copyWith(actionStatus: PackageActionStatus.loading));

    final result = await repository.registerVendor(event.request);

    result.fold(
      (failure) => emit(state.copyWith(
        actionStatus: PackageActionStatus.error,
        actionError: failure.message,
      )),
      (profile) => emit(state.copyWith(
        actionStatus: PackageActionStatus.success,
        actionSuccessMessage: 'Vendor registered successfully',
        profile: profile,
      )),
    );
  }

  void _onClearAction(
    ClearPackageAction event,
    Emitter<VendorPackagesState> emit,
  ) {
    emit(state.copyWith(
      actionStatus: PackageActionStatus.initial,
      actionError: null,
      actionSuccessMessage: null,
    ));
  }
}
