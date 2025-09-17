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
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(),
              ),
            ),
          ),
        ),
        title: Text(
          'Order #$orderNumber',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 6,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white, size: 28),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () {
                context.read<OrderCubit>().getOrderDetails(orderId);
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white.withOpacity(0.4)),
                ),
                child: const Icon(Icons.refresh, color: AppColors.white, size: 22),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
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
            ).animate().fadeIn(duration: 600.ms).scale();
          } else if (state is OrderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.red,
                    size: 80,
                  ).animate().shake(duration: 800.ms),
                  const SizedBox(height: 20),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.darkGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<OrderCubit>().getOrderDetails(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderInfoCard(orderDetails)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),
                if (orderDetails.cart?.isNotEmpty == true) ...[
                  _buildSectionTitle('Order Items'),
                  const SizedBox(height: 12),
                  ...orderDetails.cart!
                      .asMap()
                      .entries
                      .map(
                        (entry) => _buildCartItemCard(entry.value)
                        .animate()
                        .fadeIn(duration: 600.ms, delay: (100 * entry.key).ms)
                        .slideX(begin: 0.2, end: 0),
                  )
                      .toList(),
                  const SizedBox(height: 24),
                ],
                _buildPickupButton(context, state)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfoCard(OrderItem orderDetails) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Order Information',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (orderDetails.table?.isNotEmpty == true)
                    _buildInfoRow(Icons.table_restaurant, 'Table', orderDetails.table!),
                  if (orderDetails.location?.isNotEmpty == true)
                    _buildInfoRow(Icons.location_on, 'Location', orderDetails.location!),
                  if (orderDetails.notes?.isNotEmpty == true)
                    _buildInfoRow(Icons.note_alt, 'Notes', orderDetails.notes!),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
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
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGrey,
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildCartItemCard(Cart cartItem) {
    return Card(
      elevation: 0,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cart Item',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (cartItem.product?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Products'),
                    const SizedBox(height: 12),
                    ...cartItem.product!
                        .map((productItem) => _buildProductItem(productItem))
                        .toList(),
                    const SizedBox(height: 16),
                  ],
                  if (cartItem.variations?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Variations'),
                    const SizedBox(height: 12),
                    ...cartItem.variations!
                        .map((variation) => _buildVariationItem(variation))
                        .toList(),
                    const SizedBox(height: 16),
                  ],
                  if (cartItem.extras?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Extras'),
                    const SizedBox(height: 12),
                    ...cartItem.extras!
                        .map((extra) => _buildExtraItem(extra))
                        .toList(),
                    const SizedBox(height: 16),
                  ],
                  if (cartItem.addons?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Add-ons'),
                    const SizedBox(height: 12),
                    ...cartItem.addons!
                        .map((addon) => _buildAddonItem(addon))
                        .toList(),
                    const SizedBox(height: 16),
                  ],
                  if (cartItem.excludes?.isNotEmpty == true) ...[
                    _buildSubSectionTitle('Excludes', color: AppColors.red),
                    const SizedBox(height: 12),
                    ...cartItem.excludes!
                        .map((exclude) => _buildExcludeItem(exclude))
                        .toList(),
                  ],
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
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.darkGrey,
      ),
    );
  }

  Widget _buildProductItem(CartProduct productItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(productItem.product),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            productItem.product?.name ?? 'Unknown Product',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ),
                        if (productItem.count != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'x${productItem.count}',
                              style: GoogleFonts.poppins(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (productItem.product?.price != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${productItem.product!.price} EGP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (productItem.product?.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        productItem.product!.description!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (productItem.product != null) ...[
            const SizedBox(height: 12),
            _buildProductDetails(productItem.product!),
          ],
          if (productItem.preparation?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _buildDetailRow(Icons.kitchen, 'Preparation', productItem.preparation!),
          ],
          if (productItem.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.note, 'Notes', productItem.notes!),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildProductImage(Product? product) {
    String? imageUrl = product?.image;
    String? imageLink = product?.imageLink;
    String? finalImageUrl = imageLink?.isNotEmpty == true
        ? imageLink
        : (imageUrl?.isNotEmpty == true ? imageUrl : null);

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: finalImageUrl != null
            ? Image.network(
          finalImageUrl,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: AppColors.grey.withOpacity(0.3),
              highlightColor: AppColors.grey.withOpacity(0.1),
              child: Container(
                width: 90,
                height: 90,
                color: AppColors.grey.withOpacity(0.2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey.withOpacity(0.2),
      ),
      child: const Icon(
        Icons.image,
        color: AppColors.grey,
        size: 50,
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.priceAfterDiscount != null && product.priceAfterDiscount != product.price)
          _buildDetailRow(Icons.local_offer, 'Price After Discount', '${product.priceAfterDiscount} EGP'),
        if (product.priceAfterTax != null)
          _buildDetailRow(Icons.receipt, 'Price After Tax', '${product.priceAfterTax} EGP'),
        if (product.itemType?.isNotEmpty == true)
          _buildDetailRow(Icons.inventory, 'Item Type', product.itemType!),
        if (product.stockType?.isNotEmpty == true)
          _buildDetailRow(Icons.warehouse, 'Stock Type', product.stockType!),
        if (product.number?.isNotEmpty == true)
          _buildDetailRow(Icons.numbers, 'Product Number', product.number!),
        if (product.points != null)
          _buildDetailRow(Icons.star, 'Points', product.points.toString()),
        if (product.ordersCount != null)
          _buildDetailRow(Icons.shopping_bag, 'Orders Count', product.ordersCount.toString()),
        if (product.recommended != null)
          _buildDetailRow(Icons.thumb_up, 'Recommended', product.recommended == 1 ? 'Yes' : 'No'),
        if (product.favourite == true)
          _buildDetailRow(Icons.favorite, 'Favourite', 'Yes'),
        if (product.status != null)
          _buildDetailRow(Icons.info, 'Status', product.status == 1 ? 'Active' : 'Inactive'),
        if (product.productTimeStatus != null)
          _buildDetailRow(Icons.schedule, 'Time Status', product.productTimeStatus.toString()),
        if (product.from?.isNotEmpty == true || product.to?.isNotEmpty == true)
          _buildDetailRow(Icons.access_time, 'Available Time', '${product.from ?? ''} - ${product.to ?? ''}'),
        if (product.discount != null) ...[
          const SizedBox(height: 12),
          _buildDiscountInfo(product.discount!),
        ],
        if (product.taxes?.isNotEmpty == true)
          _buildDetailRow(Icons.receipt_long, 'Taxes', product.taxes!),
        if (product.allExtras?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _buildExpandableSection(
            'Available Extras (${product.allExtras!.length})',
            product.allExtras!.map((extra) => _buildAllExtrasItem(extra)).toList(),
          ),
        ],
        if (product.addons?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _buildExpandableSection(
            'Available Addons (${product.addons!.length})',
            product.addons!.map((addon) => _buildProductAddonItem(addon)).toList(),
          ),
        ],
        if (product.createdAt?.isNotEmpty == true)
          _buildDetailRow(Icons.calendar_today, 'Created', product.createdAt!),
        if (product.updatedAt?.isNotEmpty == true)
          _buildDetailRow(Icons.update, 'Updated', product.updatedAt!),
      ],
    );
  }

  Widget _buildExpandableSection(String title, List<Widget> children) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
      children: children,
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInfo(Discount discount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.green.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discount Info:',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.green,
            ),
          ),
          if (discount.name?.isNotEmpty == true)
            Text(
              'Name: ${discount.name}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkGrey),
            ),
          if (discount.type?.isNotEmpty == true)
            Text(
              'Type: ${discount.type}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkGrey),
            ),
          if (discount.amount != null)
            Text(
              'Amount: ${discount.amount}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.darkGrey),
            ),
        ],
      ),
    );
  }

  Widget _buildAllExtrasItem(AllExtras extra) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '• ${extra.name ?? 'Extra'} - ${extra.price ?? 0} EGP (After Discount: ${extra.priceAfterDiscount ?? 0} EGP)',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildProductAddonItem(Addon addon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ${addon.name ?? 'Addon'} - ${addon.price ?? 0} EGP',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          if (addon.tax != null)
            Text(
              '  Tax: ${addon.tax!.name} (${addon.tax!.type}: ${addon.tax!.amount})',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariationItem(Variations variation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            variation.variation?.name ?? 'Variation',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          if (variation.variation != null) ...[
            const SizedBox(height: 8),
            _buildVariationDetails(variation.variation!),
          ],
          if (variation.options?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              'Selected Options:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            ...variation.options!.map((option) => _buildOptionItem(option)).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildVariationDetails(Variation variation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (variation.type?.isNotEmpty == true)
          Text(
            'Type: ${variation.type}',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
          ),
        if (variation.min != null)
          Text(
            'Min: ${variation.min}',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
          ),
        if (variation.max != null)
          Text(
            'Max: ${variation.max}',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
          ),
        if (variation.required != null)
          Text(
            'Required: ${variation.required == 1 ? 'Yes' : 'No'}',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
          ),
        if (variation.createdAt?.isNotEmpty == true)
          Text(
            'Created: ${variation.createdAt}',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.grey),
          ),
      ],
    );
  }

  Widget _buildOptionItem(Options option) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ${option.name ?? 'Option'}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          if (option.price != null)
            Text(
              '  Price: ${option.price} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (option.totalOptionPrice != null)
            Text(
              '  Total: ${option.totalOptionPrice} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (option.afterDiscount != null)
            Text(
              '  After Discount: ${option.afterDiscount} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (option.priceAfterTax != null)
            Text(
              '  After Tax: ${option.priceAfterTax} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (option.points != null)
            Text(
              '  Points: ${option.points}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (option.status != null)
            Text(
              '  Status: ${option.status == 1 ? 'Active' : 'Inactive'}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildExtraItem(Extras extra) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ${extra.name ?? 'Extra'}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
            ),
          ),
          if (extra.price != null)
            Text(
              '  Price: ${extra.price} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (extra.priceAfterDiscount != null)
            Text(
              '  After Discount: ${extra.priceAfterDiscount} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (extra.priceAfterTax != null)
            Text(
              '  After Tax: ${extra.priceAfterTax} EGP',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
          if (extra.min != null || extra.max != null)
            Text(
              '  Quantity: ${extra.min ?? 0} - ${extra.max ?? 0}',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildAddonItem(CartAddon cartAddon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '• ${cartAddon.addon?.name ?? 'Addon'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              if (cartAddon.count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'x${cartAddon.count}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          if (cartAddon.addon != null) ...[
            const SizedBox(height: 8),
            if (cartAddon.addon!.price != null)
              Text(
                '  Price: ${cartAddon.addon!.price} EGP',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
              ),
            if (cartAddon.addon!.priceAfterTax != null)
              Text(
                '  After Tax: ${cartAddon.addon!.priceAfterTax} EGP',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
              ),
            if (cartAddon.addon!.quantityAdd != null)
              Text(
                '  Quantity Add: ${cartAddon.addon!.quantityAdd}',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
              ),
            if (cartAddon.addon!.tax != null)
              Text(
                '  Tax: ${cartAddon.addon!.tax!.name} (${cartAddon.addon!.tax!.amount}%)',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.grey),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildExcludeItem(Excludes exclude) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withOpacity(0.4)),
      ),
      child: Text(
        '- ${exclude.name ?? 'N/A'}',
        style: GoogleFonts.poppins(
          fontSize: 14,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.green, AppColors.green.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: isLoading
            ? const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 3,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 24, color: AppColors.white),
            const SizedBox(width: 12),
            Text(
              'Mark as Picked Up',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  void _showPickupConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white.withOpacity(0.95),
          contentPadding: const EdgeInsets.all(20),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.green, size: 32),
              const SizedBox(width: 12),
              Text(
                'Confirm Pickup',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to mark Order #$orderNumber as picked up?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: AppColors.grey,
                  fontSize: 16,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).scale();
      },
    );
  }
}