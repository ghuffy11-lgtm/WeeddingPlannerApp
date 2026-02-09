import 'package:equatable/equatable.dart';

abstract class VendorDashboardEvent extends Equatable {
  const VendorDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load vendor dashboard
class LoadVendorDashboard extends VendorDashboardEvent {
  const LoadVendorDashboard();
}

/// Refresh vendor dashboard
class RefreshVendorDashboard extends VendorDashboardEvent {
  const RefreshVendorDashboard();
}

/// Load vendor earnings
class LoadVendorEarnings extends VendorDashboardEvent {
  const LoadVendorEarnings();
}

/// Clear dashboard error
class ClearDashboardError extends VendorDashboardEvent {
  const ClearDashboardError();
}
