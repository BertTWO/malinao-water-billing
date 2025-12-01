// lib/features/customer/presentation/pages/customer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/auth/presentations/cubit/auth_cubit.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/payment.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/water_billing.dart';
import 'package:malinaowaterbilling/features/billing/presentation/cubit/billing_cubit.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';
import 'package:malinaowaterbilling/features/users/presentation/cubit/users_cubit.dart';

class CustomerDashboard extends StatefulWidget {
  final UserModel currentUser;

  const CustomerDashboard({super.key, required this.currentUser});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingCubit>().getAllBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Customer Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, billingState) {
          // Get current user's bills
          List<WaterBillEntity> userBills = [];
          WaterBillEntity? currentBill;
          List<WaterBillEntity> paidBills = [];
          List<PaymentEntity> userPayments = [];

          if (billingState is BillsLoaded) {
            userBills = billingState.bills
                .where((bill) => bill.customerId == widget.currentUser.uid)
                .toList();

            // Find current unpaid bill (most recent unpaid)
            currentBill = userBills
                .where((bill) => bill.status == 'unpaid')
                .toList()
                .lastOrNull;

            // Get paid bills
            paidBills = userBills
                .where((bill) => bill.status == 'paid')
                .toList();

            // Get payments (you'll need to implement this in your BillingCubit)
            // userPayments = getPaymentsForUser(widget.currentUser.uid);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Welcome Header
                _buildWelcomeHeader(),
                const SizedBox(height: 20),

                // Current Bill
                _buildCurrentBill(currentBill),
                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 20),

                // Profile Information with Edit
                _buildProfileInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back, ${widget.currentUser.name}!",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's your water billing overview",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentBill(WaterBillEntity? currentBill) {
    if (currentBill == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              "No Current Bill",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any pending bills",
              style: GoogleFonts.inter(color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current Bill",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'UNPAID',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Amount Due:",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "₱${NumberFormat('#,##0.00').format(currentBill.amount)}",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Consumption
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Consumption:",
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              Text(
                "${currentBill.consumption.toStringAsFixed(1)} m³",
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Due Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Due Date:",
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(currentBill.dueDate),
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Make Payment Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPaymentDialog(context, currentBill),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "Make Payment",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history_outlined,
                  label: "Payment\nHistory",
                  onTap: () => _showRealPaymentHistory(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.receipt_long_outlined,
                  label: "Previous\nBills",
                  onTap: () => _showRealPreviousBills(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Profile Information",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: () => _showEditProfileDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildProfileItem("Name", widget.currentUser.name),
          _buildProfileItem("Email", widget.currentUser.email),
          _buildProfileItem("Address", widget.currentUser.address),
          _buildProfileItem("Meter ID", widget.currentUser.meterId),
          _buildProfileItem("Contact", widget.currentUser.contactNumber),
          _buildProfileItem("Status", widget.currentUser.status.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? "Not provided" : value,
              style: GoogleFonts.inter(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, WaterBillEntity bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Make Payment",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Pay your current bill of ₱${NumberFormat('#,##0.00').format(bill.amount)}?",
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: 'gcash',
              items: ['gcash', 'cash', 'bank'].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method.toUpperCase()),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: "Payment Method",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Mark bill as paid
              context.read<BillingCubit>().recordPayment(
                PaymentEntity(
                  billId: bill.id,
                  amount: bill.amount,
                  paymentDate: DateTime.timestamp(),
                ),
              );
              Navigator.pop(context);
            },
            child: Text("Confirm Payment"),
          ),
        ],
      ),
    );
  }

  void _showRealPaymentHistory(BuildContext context) {
    // This would show real payment history from your database
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Payment History",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<BillingCubit, BillingState>(
            builder: (context, billingState) {
              List<WaterBillEntity> paidBills = [];

              if (billingState is BillsLoaded) {
                paidBills = billingState.bills
                    .where(
                      (bill) =>
                          bill.customerId == widget.currentUser.uid &&
                          bill.status == 'paid',
                    )
                    .toList();
              }

              if (paidBills.isEmpty) {
                return Center(child: Text("No payment history found"));
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: paidBills
                    .map(
                      (bill) => _buildPaymentItem(
                        DateFormat('MMM yyyy').format(bill.dueDate),
                        bill.amount,
                        bill.dueDate,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String period, double amount, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            "₱${NumberFormat('#,##0.00').format(amount)}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _showRealPreviousBills(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Previous Bills",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<BillingCubit, BillingState>(
            builder: (context, billingState) {
              List<WaterBillEntity> userBills = [];

              if (billingState is BillsLoaded) {
                userBills = billingState.bills
                    .where((bill) => bill.customerId == widget.currentUser.uid)
                    .toList();
              }

              if (userBills.isEmpty) {
                return Center(child: Text("No bills found"));
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: userBills
                    .map(
                      (bill) => _buildBillItem(
                        DateFormat('MMM yyyy').format(bill.dueDate),
                        bill.consumption,
                        bill.amount,
                        bill.status,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(
    String period,
    double consumption,
    double amount,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              Text(
                "${consumption.toStringAsFixed(1)} m³",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₱${NumberFormat('#,##0.00').format(amount)}",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              Text(
                status.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: status == 'paid'
                      ? AppColors.success
                      : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.currentUser.name);
    final emailController = TextEditingController(
      text: widget.currentUser.email,
    );
    final addressController = TextEditingController(
      text: widget.currentUser.address,
    );
    final contactController = TextEditingController(
      text: widget.currentUser.contactNumber,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: RefreshIndicator(
          onRefresh: () async {
            context.read<BillingCubit>().getAllBills();
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                SizedBox(height: 9),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(height: 9),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: "Address"),
                ),
                SizedBox(height: 9),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(labelText: "Contact Number"),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user profile
              final updatedUser = widget.currentUser.copyWith(
                name: nameController.text,
                email: emailController.text,
                address: addressController.text,
                contactNumber: contactController.text,
              );

              context.read<UsersCubit>().updateCustomer(updatedUser);
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Logout",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.pop(context);
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
