// lib/features/water_rates/presentation/pages/water_rates_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/water_rates/domain/water_rates.dart';
import 'package:malinaowaterbilling/features/water_rates/presentation/cubit/water_rates_cubit.dart';

class WaterRatesPage extends StatefulWidget {
  const WaterRatesPage({super.key});

  @override
  State<WaterRatesPage> createState() => _WaterRatesPageState();
}

class _WaterRatesPageState extends State<WaterRatesPage> {
  @override
  void initState() {
    super.initState();
    // Load current rate when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterRatesCubit>().getCurrentRate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                  "Water Rates",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Set water consumption rates",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Current Rate Card
          Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<WaterRatesCubit, WaterRatesState>(
              builder: (context, state) {
                double currentRate = 0.0;
                DateTime updatedAt = DateTime.now();

                if (state is WaterRatesLoaded && state.rate != null) {
                  currentRate = state.rate!.ratePerCubic;
                  updatedAt = state.rate!.updatedAt;
                }

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Current Water Rate",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "₱$currentRate",
                        style: GoogleFonts.inter(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        "per cubic meter",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Last updated: ${DateFormat('MMM dd, yyyy').format(updatedAt)}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              _showUpdateRateDialog(context, currentRate),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "Update Rate",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Rate History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  "Rate History",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rate History List
          Expanded(
            child: BlocBuilder<WaterRatesCubit, WaterRatesState>(
              builder: (context, state) {
                if (state is WaterRatesHistoryLoaded) {
                  final rates = state.rates;

                  if (rates.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            color: AppColors.textTertiary,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "No rate history",
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Rate changes will appear here",
                            style: GoogleFonts.inter(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: rates.length,
                    itemBuilder: (context, index) {
                      final rate = rates[index];
                      return _buildRateHistoryItem(rate);
                    },
                  );
                }

                // Show current rate in history if no specific history state
                if (state is WaterRatesLoaded && state.rate != null) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [_buildRateHistoryItem(state.rate!)],
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateHistoryItem(WaterRateEntity rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
              Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "₱${rate.ratePerCubic} per m³",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  "Effective ${DateFormat('MMM dd, yyyy').format(rate.updatedAt)}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "Active",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateRateDialog(BuildContext context, double currentRate) {
    final rateController = TextEditingController(text: currentRate.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Update Water Rate",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current rate: ₱$currentRate per m³",
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "New Rate (₱ per cubic meter)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: "₱",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This rate will be used for all new bills",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate =
                  double.tryParse(rateController.text) ?? currentRate;
              if (newRate > 0) {
                context.read<WaterRatesCubit>().updateRate(newRate);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Update Rate",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
