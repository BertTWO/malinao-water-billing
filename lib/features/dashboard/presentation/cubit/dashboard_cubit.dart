import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:malinaowaterbilling/features/dashboard/domain/repository/dashboard_repo.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepo _dashboardRepo;

  DashboardCubit(this._dashboardRepo) : super(DashboardInitial()) {
    loadDashboardData();
  }

  // Load all dashboard data
  void loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final totalCustomers = await _dashboardRepo.getTotalCustomers();
      final pendingBills = await _dashboardRepo.getPendingBills();
      final paidBills = await _dashboardRepo.getPaidBills();
      final totalRevenue = await _dashboardRepo.getTotalRevenue();
      final chartData = await _dashboardRepo.getRevenueChartData();

      emit(
        DashboardDataLoaded(
          totalCustomers: totalCustomers,
          pendingBills: pendingBills,
          paidBills: paidBills,
          totalRevenue: totalRevenue,
          chartData: chartData,
        ),
      );

      // Start listening to recent activity after loading main data
      listenToRecentActivity();
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // Listen to recent activity
  void listenToRecentActivity() {
    _dashboardRepo.getRecentActivity().listen((activities) {
      if (state is DashboardDataLoaded) {
        final currentState = state as DashboardDataLoaded;
        emit(currentState.copyWith(recentActivity: activities));
      }
    });
  }

  // Refresh dashboard data
  void refreshDashboard() {
    loadDashboardData();
  }
}
