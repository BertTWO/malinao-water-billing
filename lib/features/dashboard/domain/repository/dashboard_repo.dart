abstract class DashboardRepo {
  Future<int> getTotalCustomers();
  Future<int> getPendingBills();
  Future<int> getPaidBills();
  Future<double> getTotalRevenue();
  Stream<List<Map<String, dynamic>>> getRecentActivity();

  //revenue data for atleast 6 ka buwan
  Future<List<Map<String, dynamic>>> getRevenueChartData();
}
