import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../review/presentation/widgets/star_rating_widget.dart';
import '../../../shop/domain/entities/product.dart';
import '../bloc/product_detail_bloc.dart';

/// Product detail screen with variant selection and add to cart.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });
  final String productId;

  @override
  State<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _currentImageIndex = 0;
  int _quantity = 1;
  final Map<String, String> _selectedVariants = {};
  bool _isAddingToCart = false;
  bool _descriptionExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    context
        .read<ProductDetailBloc>()
        .add(LoadProductDetail(widget.productId));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) async {
    setState(() => _isAddingToCart = true);

    try {
      context.read<CartBloc>().add(CartItemAdded(
            product,
            quantity: _quantity,
          ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ajouté au panier'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Voir',
              textColor: Colors.white,
              onPressed: () => context.push('/cart'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, productState) {
        if (productState.status == ProductDetailStatus.loading ||
            productState.status == ProductDetailStatus.initial) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (productState.status == ProductDetailStatus.failure) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text(
                productState.error ?? 'Erreur de chargement',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        final product = productState.product!;
        return _buildContent(context, product);
      },
    );
  }

  Widget _buildContent(BuildContext context, Product product) {
    final currencyFormat = NumberFormat.currency(
      locale: 'fr_BI',
      symbol: '',
      decimalDigits: 0,
    );
    final images = product.images.isNotEmpty
        ? product.images
        : [product.imageUrl ?? ''];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // Image Gallery
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: AppIconButton(
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                  backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: AppIconButton(
                    icon: Icons.share,
                    onPressed: () {},
                    backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppIconButton(
                    icon: Icons.favorite_border,
                    onPressed: () {},
                    backgroundColor: AppColors.surface.withValues(alpha: 0.8),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) => Container(
                        color: AppColors.surfaceContainer,
                        child: Image.network(
                          images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceContainer,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Image Indicators
                    if (images.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              images.length,
                              (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: _currentImageIndex == index ? 24 : 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: _currentImageIndex == index
                                          ? AppColors.accent
                                          : AppColors.textSecondary
                                              .withValues(alpha: 0.5),
                                    ),
                                  )),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Product Details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Shop info
                    InkWell(
                      onTap: () => context.push('/shop/${product.shopId}'),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.store,
                              size: 18,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            product.shopName ?? 'Boutique',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Rating
                    Row(
                      children: [
                        StarRatingDisplay(
                          rating: product.rating,
                          reviewCount: product.reviewCount,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'En stock: ${product.stock}'
                                : 'Rupture',
                            style: TextStyle(
                              color: product.stock > 0
                                  ? AppColors.success
                                  : AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${currencyFormat.format(product.price)} BIF',
                          style: AppTextStyles.price.copyWith(
                            fontSize: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 12),
                          Text(
                            '${currencyFormat.format(product.originalPrice)} BIF',
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${product.discountPercentage}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Variants
                    if (product.variants.isNotEmpty) ...[
                      ...product.variants.map((variant) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                variant.type,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: variant.options.map((option) {
                                  final isSelected =
                                      _selectedVariants[variant.type] == option;
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedVariants[variant.type] =
                                            option;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.surfaceContainer,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.accent
                                              : AppColors.borderGray,
                                        ),
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.textOnAccent
                                              : AppColors.textPrimary,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          )),
                    ],

                    // Quantity
                    Row(
                      children: [
                        const Text(
                          'Quantité',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: AppColors.textSecondary),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: AppColors.accent),
                                onPressed: _quantity < product.stock
                                    ? () => setState(() => _quantity++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Description (expandable)
                    Text(
                      'Description',
                      style: AppTextStyles.heading5,
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final description = product.description ?? '';
                        const maxLinesCollapsed = 3;
                        final needExpand = description.length > 120 || description.split('\n').length > maxLinesCollapsed;
                        final showFull = _descriptionExpanded || !needExpand;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                              maxLines: showFull ? null : maxLinesCollapsed,
                              overflow: showFull ? null : TextOverflow.ellipsis,
                            ),
                            if (needExpand)
                              GestureDetector(
                                onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _descriptionExpanded ? 'Voir moins' : 'Voir plus',
                                    style: AppTextStyles.link,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 120), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
              top: BorderSide(color: AppColors.borderGray),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Total
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currencyFormat.format(product.price * _quantity)} BIF',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart Button
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Ajouter au panier',
                  backgroundColor: AppColors.primary,
                  isLoading: _isAddingToCart,
                  onPressed: _isAddingToCart ? null : () => _addToCart(product),
                  icon: Icons.shopping_cart_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
