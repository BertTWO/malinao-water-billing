// lib/features/billing/presentation/pages/billing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/billing/domain/entity/water_billing.dart';
import 'package:malinaowaterbilling/features/billing/presentation/cubit/billing_cubit.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';
import 'package:malinaowaterbilling/features/users/presentation/cubit/users_cubit.dart';
import 'package:malinaowaterbilling/features/water_rates/presentation/cubit/water_rates_cubit.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillingCubit>().getAllBills();
      context.read<WaterRatesCubit>().getCurrentRate();
      context
          .read<UsersCubit>()
          .getApprovedCustomers(); // Load approved customers
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerSearchDialog(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: Text(
          "Create Bill",
          style: GoogleFonts.inter(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Billing Management",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create and manage water bills",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Stats
          BlocBuilder<BillingCubit, BillingState>(
            builder: (context, state) {
              int totalBills = 0;
              int unpaidBills = 0;
              int paidBills = 0;

              if (state is BillsLoaded) {
                totalBills = state.bills.length;
                unpaidBills = state.bills
                    .where((b) => b.status == 'unpaid')
                    .length;
                paidBills = state.bills.where((b) => b.status == 'paid').length;
              }

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBillingStat(
                        title: "Total Bills",
                        value: totalBills.toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBillingStat(
                        title: "Unpaid",
                        value: unpaidBills.toString(),
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildBillingStat(
                        title: "Paid",
                        value: paidBills.toString(),
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bills List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<BillingCubit>().getAllBills();
              },
              child: BlocBuilder<BillingCubit, BillingState>(
                builder: (context, state) {
                  if (state is BillingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BillingError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BillsLoaded) {
                    final bills = state.bills;

                    if (bills.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.textTertiary,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No bills yet",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              "Create your first bill",
                              style: GoogleFonts.inter(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: bills.length,
                      itemBuilder: (context, index) {
                        final bill = bills[index];
                        return _buildBillCard(bill);
                      },
                    );
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingStat({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(WaterBillEntity bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bill #${bill.id.substring(0, 8)}",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bill.status == 'paid'
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  bill.status == 'paid' ? 'Paid' : 'Unpaid',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: bill.status == 'paid'
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildBillDetail("Previous", "${bill.previousReading} m³"),
              _buildBillDetail("Current", "${bill.currentReading} m³"),
              _buildBillDetail(
                "Used",
                "${bill.consumption.toStringAsFixed(1)} m³",
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Amount: ₱${NumberFormat('#,##0.00').format(bill.amount)}",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "Due: ${DateFormat('MMM dd, yyyy').format(bill.dueDate)}",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillDetail(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textTertiary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    UserModel? selectedCustomer; // <-- stays outside the builder now

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                "Select Customer",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search by name, email, or meter ID...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textTertiary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Only THIS part uses BlocBuilder now
                    Expanded(
                      child: BlocBuilder<UsersCubit, UsersState>(
                        builder: (context, userState) {
                          if (userState is UsersLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<UserModel> allCustomers = [];
                          if (userState is UsersLoaded) {
                            allCustomers = userState.customers
                                .where((c) => c.status == 'active')
                                .toList();
                          }

                          // Apply search filter
                          final query = searchController.text.toLowerCase();
                          final filtered = allCustomers.where((c) {
                            return c.name.toLowerCase().contains(query) ||
                                c.email.toLowerCase().contains(query) ||
                                c.meterId.toLowerCase().contains(query);
                          }).toList();

                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                query.isEmpty
                                    ? "No active customers found"
                                    : "No customers match your search",
                                style: GoogleFonts.inter(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final customer = filtered[index];
                              final isSelected =
                                  selectedCustomer?.uid == customer.uid;

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(customer.name),
                                subtitle: Text(
                                  "${customer.email}\nMeter: ${customer.meterId}",
                                  style: GoogleFonts.inter(fontSize: 12),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedCustomer = customer;
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ),

                // FIXED BUTTON
                ElevatedButton(
                  onPressed: selectedCustomer != null
                      ? () {
                          Navigator.pop(dialogContext);

                          // IMPORTANT: use ROOT context, not the dialog's disposed context
                          final rootContext = Navigator.of(context).context;

                          _showCreateBillDialog(rootContext, selectedCustomer!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.textTertiary,
                  ),
                  child: Text(
                    "Next",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateBillDialog(BuildContext context, UserModel customer) async {
    final currentReadingController = TextEditingController();
    double calculatedAmount = 0.0;
    double consumption = 0.0;

    // Get last reading from database
    final previousReading = await context
        .read<BillingCubit>()
        .getLastReadingForCustomer(customer.uid);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          void calculateAmount() {
            final curr = double.tryParse(currentReadingController.text) ?? 0;

            if (curr > previousReading) {
              consumption = curr - previousReading;

              // Get current water rate
              double currentRate = 25.50;
              final rateState = context.read<WaterRatesCubit>().state;
              if (rateState is WaterRatesLoaded && rateState.rate != null) {
                currentRate = rateState.rate!.ratePerCubic;
              }

              calculatedAmount = consumption * currentRate;
            } else {
              calculatedAmount = 0.0;
              consumption = 0.0;
            }
            setState(() {});
          }

          return AlertDialog(
            title: Text(
              "Create Bill for ${customer.name}",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Meter: ${customer.meterId}",
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Previous Reading
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Previous Reading:",
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "${previousReading.toStringAsFixed(1)} m³",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Reading Input
                  TextField(
                    controller: currentReadingController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Current Meter Reading (m³)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: "Enter this month's reading",
                      prefixIcon: Icon(Icons.speed, color: AppColors.primary),
                    ),
                    onChanged: (value) => calculateAmount(),
                  ),
                  const SizedBox(height: 16),

                  // Calculation Results
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Water Consumption:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "${consumption.toStringAsFixed(1)} m³",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<WaterRatesCubit, WaterRatesState>(
                          builder: (context, rateState) {
                            double currentRate = 25.50;
                            if (rateState is WaterRatesLoaded &&
                                rateState.rate != null) {
                              currentRate = rateState.rate!.ratePerCubic;
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rate per m³:",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  "₱${currentRate.toStringAsFixed(2)}",
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Divider(color: AppColors.border),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "TOTAL AMOUNT:",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "₱${NumberFormat('#,##0.00').format(calculatedAmount)}",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: calculatedAmount > 0
                    ? () {
                        final newBill = WaterBillEntity(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          customerId: customer.uid,
                          currentReading: double.parse(
                            currentReadingController.text,
                          ),
                          previousReading: previousReading,
                          amount: calculatedAmount,
                          status: 'unpaid',
                          dueDate: DateTime.now().add(const Duration(days: 30)),
                        );

                        context.read<BillingCubit>().createBill(newBill);
                        Navigator.pop(dialogContext);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Bill created successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  "Create Bill",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
