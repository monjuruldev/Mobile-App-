// lib/widgets/shared.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/app_state.dart';

// ─── Veg/Non-veg dot ─────────────────────────────────────────────────────────
class VegDot extends StatelessWidget {
  final bool isVeg;
  final double size;
  const VegDot({super.key, required this.isVeg, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? AC.veg : AC.nonVeg;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: size * 0.5, height: size * 0.5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

// ─── Quantity Control ────────────────────────────────────────────────────────
class QtyControl extends StatelessWidget {
  final FoodItem item;
  final bool compact;
  const QtyControl({super.key, required this.item, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final qty = state.qtyOf(item.id);
    final h = compact ? 30.0 : 36.0;

    if (qty == 0) {
      return SizedBox(
        height: h,
        child: ElevatedButton(
          onPressed: () => state.addToCart(item),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20),
            minimumSize: Size(0, h),
            backgroundColor: AC.fire,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'ADD',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
        ),
      );
    }

    return Container(
      height: h,
      decoration: BoxDecoration(
        color: AC.bg3,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
            onTap: () => state.removeFromCart(item),
            size: h,
            color: qty == 1 ? AC.error : AC.fire,
          ),
          SizedBox(
            width: compact ? 30 : 36,
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w800,
                color: AC.text,
              ),
            ),
          ),
          _Btn(icon: Icons.add_rounded, onTap: () => state.addToCart(item), size: h, color: AC.fire),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  const _Btn({required this.icon, required this.onTap, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: size * 0.48, color: Colors.white),
      ),
    );
  }
}

// ─── Menu Item Card ───────────────────────────────────────────────────────────
class MenuCard extends StatelessWidget {
  final FoodItem item;
  const MenuCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji image
          Stack(
            children: [
              Container(
                width: 82, height: 82,
                decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 38))),
              ),
              if (item.isBestseller)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: const BoxDecoration(
                      color: AC.brand,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'BESTSELLER',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: .3),
                    ),
                  ),
                ),
              if (item.isNew && !item.isBestseller)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: const BoxDecoration(
                      color: AC.info,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'NEW',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: .3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VegDot(isVeg: item.isVeg),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(item.name,
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w700, color: AC.text)),
                    ),
                    if (item.isSpicy) const Text('🌶️', style: TextStyle(fontSize: 12)),
                    GestureDetector(
                      onTap: () => state.toggleFavorite(item.id),
                      child: Icon(
                        state.isFav(item.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: state.isFav(item.id) ? AC.fire : AC.text3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AC.text3, height: 1.45)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: AC.gold),
                    const SizedBox(width: 3),
                    Text('${item.rating}',
                      style: const TextStyle(fontSize: 11, color: AC.text2, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    const Icon(Icons.local_fire_department_rounded, size: 11, color: AC.text3),
                    const SizedBox(width: 2),
                    Text('${item.calories} cal',
                      style: const TextStyle(fontSize: 11, color: AC.text3)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('${RC.currency}${item.price.toStringAsFixed(0)}',
                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w800, color: AC.text)),
                            if (item.mrp != null) ...[
                              const SizedBox(width: 6),
                              Text('${RC.currency}${item.mrp!.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AC.text3, decoration: TextDecoration.lineThrough)),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AC.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('${item.discountPct}% off',
                                  style: const TextStyle(fontSize: 9, color: AC.success, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    QtyControl(item: item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Floating Cart Bar ────────────────────────────────────────────────────────
class CartBar extends StatelessWidget {
  final VoidCallback onTap;
  const CartBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.cartEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 22),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AC.fireDark, AC.fire, AC.fireLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AC.fire.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${state.cartCount}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
            const SizedBox(width: 12),
            const Text('View Cart',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
            const Spacer(),
            Text('${RC.currency}${state.total.toStringAsFixed(0)}',
              style: const TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 13),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHead({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(title,
            style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: AC.text)),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                style: const TextStyle(fontSize: 12, color: AC.fire, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final Color? color;
  const PrimaryBtn({super.key, required this.label, required this.onTap, this.icon, this.loading = false, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AC.fire;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: onTap == null ? AC.surface : c,
          borderRadius: BorderRadius.circular(13),
          boxShadow: onTap != null ? [
            BoxShadow(color: c.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5)),
          ] : [],
        ),
        child: loading
          ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
                Text(label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: .3,
                  )),
              ],
            ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String sub;
  final String? btnLabel;
  final VoidCallback? onBtn;
  const EmptyState({super.key, required this.emoji, required this.title, required this.sub, this.btnLabel, this.onBtn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: AC.text)),
            const SizedBox(height: 8),
            Text(sub, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AC.text3, height: 1.6)),
            if (btnLabel != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(onPressed: onBtn, child: Text(btnLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Offer Chip ───────────────────────────────────────────────────────────────
class OfferChip extends StatelessWidget {
  final Offer offer;
  final bool applied;
  final VoidCallback? onApply;
  const OfferChip({super.key, required this.offer, this.applied = false, this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: applied ? AC.success.withOpacity(0.5) : AC.fire.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(offer.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(offer.title,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.w800, color: AC.text)),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(offer.subtitle, style: const TextStyle(fontSize: 10, color: AC.text3)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (applied ? AC.success : AC.fire).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: (applied ? AC.success : AC.fire).withOpacity(0.3)),
                ),
                child: Text(offer.code,
                  style: TextStyle(fontSize: 10, color: applied ? AC.success : AC.fire, fontWeight: FontWeight.w900, letterSpacing: .4)),
              ),
              const Spacer(),
              if (!applied && onApply != null)
                GestureDetector(
                  onTap: onApply,
                  child: const Text('Apply →', style: TextStyle(fontSize: 11, color: AC.fire, fontWeight: FontWeight.w700)),
                )
              else if (applied)
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: AC.success),
                    SizedBox(width: 3),
                    Text('Applied', style: TextStyle(fontSize: 11, color: AC.success, fontWeight: FontWeight.w700)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
