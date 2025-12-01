import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/auth/presentations/cubit/auth_cubit.dart';
import 'package:malinaowaterbilling/features/billing/presentation/pages/billing_page.dart';
import 'package:malinaowaterbilling/features/users/presentation/pages/customer_page.dart';
import 'package:malinaowaterbilling/features/water_rates/presentation/pages/water_rates_page.dart';
import 'package:malinaowaterbilling/features/widgets/admin_drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String _currentRoute = '/dashboard';

  final List<Widget> _pages = [
    const DashboardHomeContent(),
    const CustomersPage(),
    const BillingPage(),
    const WaterRatesPage(),
  ];

  final List<String> _routes = [
    '/dashboard',
    '/customers',
    '/billing',
    '/rates',
  ];

  void _onDrawerItemSelected(int index) {
    setState(() {
      _currentIndex = index;
      _currentRoute = _routes[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _pages[_currentIndex],
      drawer: AdminDrawer(
        currentIndex: _currentIndex,
        onItemSelected: _onDrawerItemSelected,
        currentRoute: _currentRoute,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 1,
      leading: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(9.0),
          child: IconButton(
            icon: Icon(Icons.menu_rounded, color: AppColors.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Malinao Water Billing",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            _getAppBarTitle(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return "Dashboard";
      case 1:
        return "Customers Management";
      case 2:
        return "Billing Management";
      case 3:
        return "Water Rates";
      default:
        return "Dashboard";
    }
  }
}

// ============================================
// DASHBOARD HOME CONTENT
// ============================================

class DashboardHomeContent extends StatelessWidget {
  const DashboardHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardCubit>().loadDashboardData();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is DashboardDataLoaded) {
          final data = state;

          return AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardCubit>().loadDashboardData();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 500),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    ),
                    children: [
                      _buildWelcomeHeader(context),
                      const SizedBox(height: 24),
                      _buildStatsGrid(
                        totalCustomers: data.totalCustomers,
                        pendingBills: data.pendingBills,
                        paidBills: data.paidBills,
                        totalRevenue: data.totalRevenue,
                      ),
                      const SizedBox(height: 24),
                      _buildRevenueChart(data.chartData),
                      const SizedBox(height: 24),
                      _buildRecentActivity(data.recentActivity),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome Back, ${user?.name ?? 'Admin'}",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Here's your system overview for ${DateFormat('MMMM yyyy').format(DateTime.now())}",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid({
    required int totalCustomers,
    required int pendingBills,
    required int paidBills,
    required double totalRevenue,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: "Total Customers",
          value: totalCustomers.toString(),
          icon: Icons.people_outline,
          color: AppColors.primary,
        ),
        _buildStatCard(
          title: "Pending Bills",
          value: pendingBills.toString(),
          icon: Icons.pending_actions_outlined,
          color: AppColors.warning,
        ),
        _buildStatCard(
          title: "Paid Bills",
          value: paidBills.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        _buildStatCard(
          title: "Total Revenue",
          value: "₱${NumberFormat('#,##0.00').format(totalRevenue)}",
          icon: Icons.attach_money_outlined,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 60, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No revenue data available',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      spots.add(FlSpot(i.toDouble(), chartData[i]['revenue'] * 1.0));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Revenue Overview",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Map<String, dynamic>> activities) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "View All",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          activities.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No recent activity',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : Column(
                  children: activities
                      .map((activity) => _buildActivityItem(activity))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final date = DateTime.fromMillisecondsSinceEpoch(activity['time']);
    final formatted = DateFormat('MMM dd, hh:mm a').format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.payment_outlined,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['customer'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  activity['action'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (activity['amount'] != null)
                Text(
                  "₱${NumberFormat('#,##0.00').format(activity['amount'])}",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              Text(
                formatted,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
