import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/utils/app_colors.dart';
import '../logic/cubit/order_cubit.dart';
import '../logic/cubit/order_state.dart';
import '../logic/model/order_item.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int orderId;
  final String orderNumber;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<OrderCubit>()..getOrderDetails(orderId),
      child: OrderDetailsView(
        orderId: orderId,
        orderNumber: orderNumber,
      ),
    );
  }
}

class OrderDetailsView extends StatelessWidget {
  final int orderId;
  final String orderNumber;

  const OrderDetailsView({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGround,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.primary.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Reduced blur intensity
                child: Container(),
              ),
            ),
          ),
        ),
        title: Text(
          'Order #$orderNumber',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white, size: 26),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                context.read<OrderCubit>().getOrderDetails(orderId);
              },
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white.withOpacity(0.3)),
                ),
                child: const Icon(Icons.refresh, color: AppColors.white, size: 20),
              ),
              tooltip: 'Refresh Order',
            ),
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderPickupSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Order picked up successfully!',
                  style: GoogleFonts.poppins(color: AppColors.white),
                ),
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(12),
              ),
            );
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: GoogleFonts.poppins(color: AppColors.white),
                ),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(12),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderDetailsLoading) {
            return Center(
              child: Shimmer.fromColors(
                baseColor: AppColors.grey.withOpacity(0.3),
                highlightColor: AppColors.grey.withOpacity(0.1),
                child: const CircularProgressIndicator(color: AppColors.primary),
              ),
            ).animate().fadeIn(duration: 400.ms); // Simplified animation
          } else if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.darkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrderCubit>().getOrderDetails(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ).animate().fadeIn(duration: 400.ms), // Simplified animation
                ],
              ),
            );
          }

          final orderDetails = context.read<OrderCubit>().currentOrderDetails;
          if (orderDetails == null) {
            return Center(
              child: Text(
                'No order details available',
                style: GoogleFonts.poppins(
                  color: AppColors.darkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(), // Smoother scrolling
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfoCard(orderDetails, context)
                    .animate()
                    .fadeIn(duration: 400.ms), // Simplified animation
                const SizedBox(height: 20),
                if (orderDetails.cart?.isNotEmpty == true) ...[
                  _buildSectionTitle('Order Items'),
                  const SizedBox(height: 10),
                  ...orderDetails.cart!
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildCartItemCard(entry.value)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (150 * entry.key).ms), // Staggered, lighter animation
                  )
                      .toList(),
                  const SizedBox(height: 20),
                ],
                if (orderDetails.kitchen?.isNotEmpty == true) ...[
                  _buildSectionTitle('Kitchen Info'),
                  const SizedBox(height: 10),
                  ...orderDetails.kitchen!
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildKitchenCard(entry.value)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: (150 * entry.key).ms), // Staggered, lighter animation
                  )
                      .toList(),
                  const SizedBox(height: 20),
                ],
                _buildPickupButton(context, state)
                    .animate()
                    .fadeIn(duration: 400.ms), // Simplified animation
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderItem orderDetails,BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Reduced shadow intensity
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Reduced blur intensity
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.09,
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Order Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (orderDetails.table?.isNotEmpty == true)
                    _buildInfoRow(Icons.table_restaurant, 'Table', orderDetails.table!),
                  if (orderDetails.location?.isNotEmpty == true)
                    _buildInfoRow(Icons.location_on, 'Location', orderDetails.location!),
                  if (orderDetails.notes != null)
                    _buildInfoRow(Icons.note_alt, 'Notes', orderDetails.notes.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      ),
    );
  }

  Widget _buildCartItemCard(Cart cartItem) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Reduced shadow intensity
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Reduced blur intensity
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (cartItem.product?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Products'),
                    const SizedBox(height: 10),
                    ...cartItem.product!.map((product) => _buildProductItem(product)).toList(),
                    const SizedBox(height: 12),
                  ],
                  if (cartItem.variations?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Variations'),
                    const SizedBox(height: 10),
                    ...cartItem.variations!.map((variation) => _buildVariationItem(variation)).toList(),
                    const SizedBox(height: 12),
                  ],
                  if (cartItem.extras?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Extras'),
                    const SizedBox(height: 10),
                    ...cartItem.extras!.map((extra) => _buildExtraItem(extra)).toList(),
                    const SizedBox(height: 12),
                  ],
                  if (cartItem.addons?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Add-ons'),
                    const SizedBox(height: 10),
                    ...cartItem.addons!.map((addon) => _buildAddonItem(addon)).toList(),
                    const SizedBox(height: 12),
                  ],
                  if (cartItem.excludes?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Excludes', color: AppColors.red),
                    const SizedBox(height: 10),
                    ...cartItem.excludes!.map((exclude) => _buildExcludeItem(exclude)).toList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.product?.name ?? 'Product',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (product.count != null)
                  Text(
                    'Quantity: ${product.count}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenCard(Kitchen kitchen) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Reduced shadow intensity
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Reduced blur intensity
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.kitchen, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kitchen.name ?? 'Kitchen',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        if (kitchen.type?.isNotEmpty == true)
                          Text(
                            'Type: ${kitchen.type}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title, {Color? color}) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.darkGrey,
      ),
    );
  }

  Widget _buildVariationItem(Variations variation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '• ${variation.variation?.name ?? 'Variation'}',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  Widget _buildExtraItem(Extras extra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '• ${extra.name ?? 'Extra'}',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
      ),
    );
  }

  Widget _buildAddonItem(Addons addon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '• ${addon.addon?.name ?? 'Addon'}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
          if (addon.count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'x${addon.count}',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExcludeItem(Excludes exclude) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Text(
        '- ${exclude.name ?? 'N/A'}',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPickupButton(BuildContext context, OrderState state) {
    final isLoading = state is OrderPickupLoading;

    return InkWell(
      onTap: isLoading
          ? null
          : () {
        _showPickupConfirmation(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.green, AppColors.green.withOpacity(0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.2), // Reduced shadow intensity
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: isLoading
            ? const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 2,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 20, color: AppColors.white),
            const SizedBox(width: 10),
            Text(
              'Mark as Picked Up',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms); // Simplified animation
  }

  void _showPickupConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.all(16),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.green, size: 24),
              const SizedBox(width: 10),
              Text(
                'Confirm Pickup',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to mark Order #$orderNumber as picked up?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<OrderCubit>().pickupOrder(orderId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms); // Faster dialog animation
      },
    );
  }
}