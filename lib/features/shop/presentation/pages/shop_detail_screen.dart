import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';

class ShopDetailScreen extends StatefulWidget {
  const ShopDetailScreen({
    super.key,
    required this.shopId,
    this.shopExtra,
  });

  final String shopId;
  final Shop? shopExtra;

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<ShopBloc>();
    if (widget.shopExtra == null) {
      bloc.add(ShopDetailRequested(widget.shopId));
    }
    bloc.add(ShopProductsRequested(widget.shopId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      buildWhen: (prev, next) =>
          prev.detailStatus != next.detailStatus ||
          prev.selectedShop != next.selectedShop ||
          prev.productsStatus != next.productsStatus ||
          prev.shopProducts != next.shopProducts,
      builder: (context, state) {
        final shop = widget.shopExtra ??
            (state.detailStatus == ShopDetailStatus.success
                ? state.selectedShop
                : null);
        if (shop == null) {
          if (state.detailStatus == ShopDetailStatus.failure) {
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
                  state.detailError ?? 'Erreur de chargement',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final products = state.shopProducts;
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            final cartCount = cartState.itemCount;
            return Scaffold(
              backgroundColor: AppColors.background,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    leading: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainer,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (shop.logoUrl != null && shop.logoUrl!.isNotEmpty)
                            Image.network(
                              shop.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceLight,
                                child: const Icon(Icons.store_rounded, size: 64, color: AppColors.textTertiary),
                              ),
                            )
                          else
                            Container(
                              color: AppColors.surfaceLight,
                              child: const Icon(Icons.store_rounded, size: 64, color: AppColors.textTertiary),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.background.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -28),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.surface,
                              child: shop.logoUrl != null && shop.logoUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        shop.logoUrl!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.store_rounded, color: AppColors.primary),
                                      ),
                                    )
                                  : const Icon(Icons.store_rounded, color: AppColors.primary, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shop.name, style: AppTextStyles.heading2),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          shop.type,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.star_rounded, size: 16, color: AppColors.guraOrange),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${shop.rating.toStringAsFixed(1)} (${shop.totalReviews} avis)',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.delivery_dining_rounded, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        shop.deliveryScope ?? 'Bujumbura',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Text(
                        shop.description ?? 'Aucune description.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Produits', style: AppTextStyles.heading4),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (state.productsStatus == ShopProductsStatus.loading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (products.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Aucun produit disponible.',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => context.push('/product/${product.id}'),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
              floatingActionButton: cartCount > 0
                  ? FloatingActionButton.extended(
                      onPressed: () => context.push('/cart'),
                      backgroundColor: AppColors.primary,
                      icon: Badge(
                        label: Text('$cartCount', style: AppTextStyles.badge.copyWith(fontSize: 10)),
                        child: const Icon(Icons.shopping_cart_rounded),
                      ),
                      label: const Text('Voir le panier'),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}

