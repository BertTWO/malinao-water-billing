// lib/features/users/presentation/pages/customer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malinaowaterbilling/core/theme/app_theme.dart';
import 'package:malinaowaterbilling/features/users/domain/entity/user.dart';
import 'package:malinaowaterbilling/features/users/presentation/cubit/users_cubit.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersCubit>().getAllCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search customers...",
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textTertiary,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      context.read<UsersCubit>().searchCustomers(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _showCreateCustomerDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    "Add Customer",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<UsersCubit>().getAllCustomers();
              },
              child: BlocBuilder<UsersCubit, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is UsersError) {
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

                  if (state is UsersLoaded) {
                    final customers = state.customers;

                    if (customers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: AppColors.textTertiary,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No customers found",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              _searchQuery.isEmpty
                                  ? "Click 'Add Customer' to create a new customer"
                                  : "Try a different search",
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
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return _buildCustomerCard(context, customer);
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

  Widget _buildCustomerCard(BuildContext context, UserModel customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Customer Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.person_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 16),

          // Customer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  customer.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  customer.address,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  "Meter: ${customer.meterId} • ${customer.contactNumber}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              IconButton(
                onPressed: () => _showEditCustomerDialog(context, customer),
                icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: "Edit",
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context, customer),
                icon: Icon(Icons.delete_outline, color: AppColors.error),
                tooltip: "Delete",
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateCustomerDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final addressController = TextEditingController();
    final contactController = TextEditingController();
    final meterIdController = TextEditingController();

    // Add a variable to track the selected role
    String _selectedRole = 'customer'; // Default to 'customer'

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(
                "Add New User",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Role Selection
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.textTertiary.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue!;
                              });
                            },
                            items: <String>['customer', 'admin']
                                .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Icon(
                                          value == 'admin'
                                              ? Icons.admin_panel_settings
                                              : Icons.person,
                                          color: value == 'admin'
                                              ? AppColors.primary
                                              : AppColors.textSecondary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          value == 'admin'
                                              ? 'Admin'
                                              : 'Customer',
                                          style: GoogleFonts.inter(
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? "Name is required" : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return "Email is required";
                          if (!value!.contains('@')) return "Invalid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return "Password is required";
                          if (value!.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: const Icon(Icons.home_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? "Address is required"
                            : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: contactController,
                        decoration: InputDecoration(
                          labelText: "Contact Number",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => value?.isEmpty ?? true
                            ? "Contact number is required"
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // Conditionally show meter ID field only for customers
                      if (_selectedRole == 'customer')
                        TextFormField(
                          controller: meterIdController,
                          decoration: InputDecoration(
                            labelText: "Meter ID",
                            prefixIcon: const Icon(Icons.speed_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: _selectedRole == 'customer'
                              ? (value) => value?.isEmpty ?? true
                                    ? "Meter ID is required for customers"
                                    : null
                              : null,
                        ),
                    ],
                  ),
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
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      context.read<UsersCubit>().createCustomer(
                        name: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        address: addressController.text,
                        contactNumber: contactController.text,
                        meterId: meterIdController.text,
                        isAdmin: _selectedRole.toLowerCase() == 'admin',
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    "Create",
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditCustomerDialog(BuildContext context, UserModel customer) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final addressController = TextEditingController(text: customer.address);
    final contactController = TextEditingController(
      text: customer.contactNumber,
    );
    final meterIdController = TextEditingController(text: customer.meterId);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "Edit Customer",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? "Name is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    labelText: "Address",
                    prefixIcon: const Icon(Icons.home_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? "Address is required" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: "Contact Number",
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty ?? true
                      ? "Contact number is required"
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: meterIdController,
                  decoration: InputDecoration(
                    labelText: "Meter ID",
                    prefixIcon: const Icon(Icons.speed_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? "Meter ID is required" : null,
                ),
              ],
            ),
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
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final updatedCustomer = customer.copyWith(
                  name: nameController.text,
                  address: addressController.text,
                  contactNumber: contactController.text,
                  meterId: meterIdController.text,
                );
                context.read<UsersCubit>().updateCustomer(updatedCustomer);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              "Update",
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          "Delete Customer",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to delete ${customer.name}?"),
            const SizedBox(height: 8),
            Text(
              "This action cannot be undone.",
              style: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
            ),
          ],
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
            onPressed: () {
              context.read<UsersCubit>().deleteCustomer(customer.uid);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              "Delete",
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
