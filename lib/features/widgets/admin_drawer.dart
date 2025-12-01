import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/auth/domain/models/app_user.dart';
import 'package:malinaowaterbilling/features/auth/presentations/cubit/auth_cubit.dart';

class AdminDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemSelected;
  final String currentRoute;

  const AdminDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.currentRoute,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerHeader(context),
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  isSelected: currentRoute == '/dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people_outlined,
                  title: 'Customers',
                  isSelected: currentRoute == '/customers',
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Billing',
                  isSelected: currentRoute == '/billing',
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_outlined,
                  title: 'Water Rates',
                  isSelected: currentRoute == '/rates',
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(3);
                  },
                ),
              ],
            ),
          ),
          _buildLogoutButton(context),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    AppUser? user = BlocProvider.of<AuthCubit>(context).currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Text(
            "Malinao Water Billing",
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Administrator Panel",
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(Icons.person_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? "Admin",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user?.email ?? "",
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        trailing: isSelected
            ? Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(Icons.logout_outlined, color: AppColors.error),
          title: Text(
            "Logout",
            style: GoogleFonts.inter(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            _showLogoutConfirmation(context);
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Confirm Logout",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Logout",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
