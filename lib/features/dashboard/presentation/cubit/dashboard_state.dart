part of 'dashboard_cubit.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardDataLoaded extends DashboardState {
  final int totalCustomers;
  final int pendingBills;
  final int paidBills;
  final double totalRevenue;
  final List<Map<String, dynamic>> chartData;
  final List<Map<String, dynamic>> recentActivity;

  const DashboardDataLoaded({
    required this.totalCustomers,
    required this.pendingBills,
    required this.paidBills,
    required this.totalRevenue,
    required this.chartData,
    this.recentActivity = const [],
  });

  DashboardDataLoaded copyWith({
    int? totalCustomers,
    int? pendingBills,
    int? paidBills,
    double? totalRevenue,
    List<Map<String, dynamic>>? chartData,
    List<Map<String, dynamic>>? recentActivity,
  }) {
    return DashboardDataLoaded(
      totalCustomers: totalCustomers ?? this.totalCustomers,
      pendingBills: pendingBills ?? this.pendingBills,
      paidBills: paidBills ?? this.paidBills,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      chartData: chartData ?? this.chartData,
      recentActivity: recentActivity ?? this.recentActivity,
    );
  }

  @override
  List<Object?> get props => [
    totalCustomers,
    pendingBills,
    paidBills,
    totalRevenue,
    chartData,
    recentActivity,
  ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
