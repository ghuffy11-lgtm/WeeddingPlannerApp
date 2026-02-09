import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_dashboard.dart';

enum DashboardLoadStatus { initial, loading, loaded, error }
enum EarningsLoadStatus { initial, loading, loaded, error }

class VendorDashboardState extends Equatable {
  // Dashboard
  final DashboardLoadStatus dashboardStatus;
  final VendorDashboard? dashboard;
  final String? dashboardError;

  // Earnings
  final EarningsLoadStatus earningsStatus;
  final VendorEarnings? earnings;
  final String? earningsError;

  const VendorDashboardState({
    this.dashboardStatus = DashboardLoadStatus.initial,
    this.dashboard,
    this.dashboardError,
    this.earningsStatus = EarningsLoadStatus.initial,
    this.earnings,
    this.earningsError,
  });

  VendorDashboardState copyWith({
    DashboardLoadStatus? dashboardStatus,
    VendorDashboard? dashboard,
    String? dashboardError,
    EarningsLoadStatus? earningsStatus,
    VendorEarnings? earnings,
    String? earningsError,
  }) {
    return VendorDashboardState(
      dashboardStatus: dashboardStatus ?? this.dashboardStatus,
      dashboard: dashboard ?? this.dashboard,
      dashboardError: dashboardError,
      earningsStatus: earningsStatus ?? this.earningsStatus,
      earnings: earnings ?? this.earnings,
      earningsError: earningsError,
    );
  }

  @override
  List<Object?> get props => [
        dashboardStatus,
        dashboard,
        dashboardError,
        earningsStatus,
        earnings,
        earningsError,
      ];
}
