import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/vendor_app_repository.dart';
import 'vendor_dashboard_event.dart';
import 'vendor_dashboard_state.dart';

class VendorDashboardBloc
    extends Bloc<VendorDashboardEvent, VendorDashboardState> {
  final VendorAppRepository repository;

  VendorDashboardBloc({required this.repository})
      : super(const VendorDashboardState()) {
    on<LoadVendorDashboard>(_onLoadDashboard);
    on<RefreshVendorDashboard>(_onRefreshDashboard);
    on<LoadVendorEarnings>(_onLoadEarnings);
    on<ClearDashboardError>(_onClearError);
  }

  Future<void> _onLoadDashboard(
    LoadVendorDashboard event,
    Emitter<VendorDashboardState> emit,
  ) async {
    emit(state.copyWith(dashboardStatus: DashboardLoadStatus.loading));

    final result = await repository.getDashboard();

    result.fold(
      (failure) => emit(state.copyWith(
        dashboardStatus: DashboardLoadStatus.error,
        dashboardError: failure.message,
      )),
      (dashboard) => emit(state.copyWith(
        dashboardStatus: DashboardLoadStatus.loaded,
        dashboard: dashboard,
      )),
    );
  }

  Future<void> _onRefreshDashboard(
    RefreshVendorDashboard event,
    Emitter<VendorDashboardState> emit,
  ) async {
    final result = await repository.getDashboard();

    result.fold(
      (failure) => emit(state.copyWith(
        dashboardError: failure.message,
      )),
      (dashboard) => emit(state.copyWith(
        dashboardStatus: DashboardLoadStatus.loaded,
        dashboard: dashboard,
      )),
    );
  }

  Future<void> _onLoadEarnings(
    LoadVendorEarnings event,
    Emitter<VendorDashboardState> emit,
  ) async {
    emit(state.copyWith(earningsStatus: EarningsLoadStatus.loading));

    final result = await repository.getEarnings();

    result.fold(
      (failure) => emit(state.copyWith(
        earningsStatus: EarningsLoadStatus.error,
        earningsError: failure.message,
      )),
      (earnings) => emit(state.copyWith(
        earningsStatus: EarningsLoadStatus.loaded,
        earnings: earnings,
      )),
    );
  }

  void _onClearError(
    ClearDashboardError event,
    Emitter<VendorDashboardState> emit,
  ) {
    emit(state.copyWith(
      dashboardError: null,
      earningsError: null,
    ));
  }
}
