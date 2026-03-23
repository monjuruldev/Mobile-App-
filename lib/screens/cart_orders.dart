// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponCtrl = TextEditingController();
  String _address   = 'Home – ${RC.address}';
  String _payment   = 'Cash on Delivery';

  @override
  void dispose() { _couponCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg2,
        title: Text(
          'Cart ${state.cartEmpty ? "" : "(${state.cartCount})"}',
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: AC.text),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!state.cartEmpty)
            TextButton(
              onPressed: () => _confirmClear(state),
              child: const Text('Clear', style: TextStyle(color: AC.error, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: state.cartEmpty
        ? EmptyState(
            emoji: '🛒',
            title: 'Cart is empty!',
            sub: 'Add your favourite burgers & sides to get started.',
            btnLabel: 'Browse Menu',
            onBtn: () => Navigator.of(context).pop(),
          )
        : Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: [
                    const SizedBox(height: 14),
                    ...state.cart.map((ci) => _CartTile(ci: ci, state: state)),
                    const SizedBox(height: 12),
                    _addMoreBtn(),
                    const SizedBox(height: 22),
                    _couponSection(state),
                    const SizedBox(height: 22),
                    _addressSection(),
                    const SizedBox(height: 22),
                    _paymentSection(),
                    const SizedBox(height: 22),
                    _billSection(state),
                  ],
                ),
              ),
              _checkoutBar(context, state),
            ],
          ),
    );
  }

  Widget _addMoreBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: AC.fire.withOpacity(.4)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: AC.fire, size: 17),
              SizedBox(width: 7),
              Text('Add more items', style: TextStyle(color: AC.fire, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _couponSection(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHead(title: '🎁 Apply Coupon'),
          const SizedBox(height: 10),
          if (state.appliedCoupon.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AC.success.withOpacity(.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AC.success.withOpacity(.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AC.success, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.appliedCoupon,
                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w800, color: AC.success)),
                        Text(
                          state.freeDelivery
                            ? 'Free delivery applied! 🛵'
                            : 'You save ${RC.currency}${state.couponSaving.toStringAsFixed(0)}! 🎉',
                          style: const TextStyle(fontSize: 11, color: AC.success),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: state.removeCoupon,
                    child: const Icon(Icons.close_rounded, color: AC.error, size: 18),
                  ),
                ],
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponCtrl,
                    style: const TextStyle(color: AC.text, fontSize: 13),
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'Enter coupon code'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    final err = state.applyCoupon(_couponCtrl.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? '✅ Coupon applied!'),
                      backgroundColor: err != null ? AC.error : AC.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ));
                    if (err == null) _couponCtrl.clear();
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: const Text('Apply'),
                ),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: SampleData.offers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final o = SampleData.offers[i];
                return GestureDetector(
                  onTap: () {
                    final err = state.applyCoupon(o.code);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? '✅ ${o.code} applied!'),
                      backgroundColor: err != null ? AC.error : AC.success,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AC.bg3,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AC.fire.withOpacity(.2)),
                    ),
                    child: Row(
                      children: [
                        Text(o.emoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(o.code, style: const TextStyle(fontSize: 11, color: AC.fire, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHead(title: '📍 Delivery Address'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AC.bg2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AC.fire.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('🏠', style: TextStyle(fontSize: 18))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Home', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: AC.text)),
                      Text(_address, style: const TextStyle(fontSize: 11, color: AC.text3)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _editAddress,
                  child: const Text('Change', style: TextStyle(fontSize: 12, color: AC.fire, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() {
    final methods = ['Cash on Delivery', 'UPI / PhonePe', 'Credit / Debit Card', 'Net Banking'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHead(title: '💳 Payment'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AC.bg2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(.05)),
            ),
            child: Column(
              children: methods.map((m) => RadioListTile<String>(
                value: m, groupValue: _payment,
                onChanged: (v) => setState(() => _payment = v!),
                activeColor: AC.fire,
                title: Text(m, style: const TextStyle(fontSize: 13, color: AC.text, fontWeight: FontWeight.w500)),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _billSection(AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHead(title: '🧾 Bill Summary'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AC.bg2,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(.05)),
            ),
            child: Column(
              children: [
                _row('Item Total', '${RC.currency}${state.subtotal.toStringAsFixed(0)}'),
                if (state.couponSaving > 0) ...[
                  const SizedBox(height: 8),
                  _row('Coupon (${state.appliedCoupon})', '− ${RC.currency}${state.couponSaving.toStringAsFixed(0)}', green: true),
                ],
                const SizedBox(height: 8),
                _row('Delivery Fee', state.deliveryFee == 0 ? 'FREE 🎉' : '${RC.currency}${state.deliveryFee.toStringAsFixed(0)}', green: state.deliveryFee == 0),
                const SizedBox(height: 8),
                _row('GST (5%)', '${RC.currency}${state.tax.toStringAsFixed(0)}'),
                const Divider(color: AC.bg3, height: 22),
                Row(
                  children: [
                    const Text('Total', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AC.text)),
                    const Spacer(),
                    Text('${RC.currency}${state.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w900, color: AC.fire)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v, {bool green = false}) => Row(
    children: [
      Text(l, style: const TextStyle(fontSize: 13, color: AC.text2)),
      const Spacer(),
      Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: green ? AC.success : AC.text)),
    ],
  );

  Widget _checkoutBar(BuildContext context, AppState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(14, 12, 14, MediaQuery.of(context).padding.bottom + 14),
      decoration: const BoxDecoration(
        color: AC.bg2,
        border: Border(top: BorderSide(color: AC.bg3)),
      ),
      child: PrimaryBtn(
        label: 'Place Order  •  ${RC.currency}${state.total.toStringAsFixed(0)}',
        icon: Icons.check_circle_outline_rounded,
        onTap: () {
          final order = state.placeOrder(address: _address, payment: _payment);
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
          Navigator.of(context).pushNamed('/track', arguments: order);
        },
      ),
    );
  }

  void _confirmClear(AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear Cart?', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: AC.text)),
        content: const Text('Remove all items from your cart?', style: TextStyle(color: AC.text2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () { state.clearCart(); Navigator.pop(ctx); },
            child: const Text('Clear', style: TextStyle(color: AC.error))),
        ],
      ),
    );
  }

  void _editAddress() {
    final ctrl = TextEditingController(text: _address);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delivery Address', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: AC.text)),
        content: TextField(controller: ctrl, style: const TextStyle(color: AC.text), maxLines: 2,
          decoration: const InputDecoration(hintText: 'Enter your address')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { setState(() => _address = ctrl.text); Navigator.pop(ctx); },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Tile ────────────────────────────────────────────────────────────────
class _CartTile extends StatelessWidget {
  final CartItem ci;
  final AppState state;
  const _CartTile({required this.ci, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(ci.item.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ci.item.name,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: AC.text)),
                Text('${RC.currency}${ci.item.price.toStringAsFixed(0)} each',
                  style: const TextStyle(fontSize: 11, color: AC.text3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              QtyControl(item: ci.item, compact: true),
              const SizedBox(height: 5),
              Text('${RC.currency}${ci.total.toStringAsFixed(0)}',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: AC.text)),
            ],
          ),
        ],
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  ORDER TRACKING SCREEN
// ════════════════════════════════════════════════════════════════
class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as Order?;
    if (order == null) return const Scaffold(body: Center(child: Text('Order not found')));

    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Live Tracking', style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AC.text)),
            Text('Order #${order.id}', style: const TextStyle(fontSize: 11, color: AC.text3)),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (_, __, ___) => ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _statusCard(order),
            const SizedBox(height: 16),
            _tracker(order),
            const SizedBox(height: 16),
            _deliveryInfo(order),
            const SizedBox(height: 16),
            _itemsList(order),
            const SizedBox(height: 16),
            _billCard(order),
            const SizedBox(height: 24),
            if (order.status == OrderStatus.delivered)
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false),
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Order Again'),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: order.status.color.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: order.status.color.withOpacity(.35)),
      ),
      child: Column(
        children: [
          Text(order.status.emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 8),
          Text(order.status.label,
            style: TextStyle(fontFamily: 'Bangers', fontSize: 26, letterSpacing: 1, color: order.status.color)),
          const SizedBox(height: 5),
          Text(_msg(order.status), textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AC.text2, height: 1.5)),
          if (order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_rounded, size: 13, color: AC.text3),
                const SizedBox(width: 4),
                Text('Estimated ${RC.avgDelivery} mins',
                  style: const TextStyle(fontSize: 11, color: AC.text3)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _msg(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed:    return 'Waiting for restaurant to confirm...';
      case OrderStatus.confirmed: return 'Order confirmed! Getting the kitchen ready.';
      case OrderStatus.preparing: return 'Our chef is flame-grilling your order 🔥';
      case OrderStatus.onTheWay:  return 'Your rider is speeding your way! 🛵';
      case OrderStatus.delivered: return 'Delivered! Enjoy your meal 😋';
      case OrderStatus.cancelled: return 'Order cancelled. Refund in 3–5 days.';
    }
  }

  Widget _tracker(Order order) {
    if (order.status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AC.bg2, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('Order cancelled', style: TextStyle(color: AC.text3))),
      );
    }

    final steps = [
      ('Placed', '📋'),
      ('Confirmed', '✅'),
      ('Preparing', '👨‍🍳'),
      ('On The Way', '🛵'),
      ('Delivered', '🎉'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tracking', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w800, color: AC.text)),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((e) {
            final i = e.key;
            final done = order.status.step >= i;
            final current = order.status.step == i;
            final isLast = i == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: done ? AC.fire.withOpacity(.18) : AC.bg3,
                        shape: BoxShape.circle,
                        border: Border.all(color: done ? AC.fire : AC.bg3, width: 2),
                      ),
                      child: Center(
                        child: current
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: AC.fire))
                          : Text(e.value.$2, style: const TextStyle(fontSize: 15)),
                      ),
                    ),
                    if (!isLast)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 2, height: 28,
                        color: done ? AC.fire.withOpacity(.4) : AC.bg3,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value.$1,
                        style: TextStyle(
                          fontFamily: 'Outfit', fontSize: 13,
                          fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                          color: done ? AC.text : AC.text3,
                        )),
                      if (current) const Text('In progress...', style: TextStyle(fontSize: 10, color: AC.fire)),
                      SizedBox(height: isLast ? 0 : 18),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _deliveryInfo(Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AC.bg2, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Delivery Info', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w800, color: AC.text)),
          const SizedBox(height: 12),
          _iRow('📍', 'Address', order.address),
          const SizedBox(height: 8),
          _iRow('💳', 'Payment', order.paymentMethod),
          const SizedBox(height: 8),
          _iRow('📅', 'Placed', _fmtTime(order.placedAt)),
          if (order.couponCode != null) ...[
            const SizedBox(height: 8),
            _iRow('🎁', 'Coupon', order.couponCode!),
          ],
        ],
      ),
    );
  }

  Widget _iRow(String emoji, String label, String val) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 15)),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(fontSize: 12, color: AC.text3)),
      const Spacer(),
      Expanded(
        flex: 2,
        child: Text(val, textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 12, color: AC.text, fontWeight: FontWeight.w500)),
      ),
    ],
  );

  String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day}/${dt.month}/${dt.year}  $h:$m $ap';
  }

  Widget _itemsList(Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AC.bg2, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w800, color: AC.text)),
          const SizedBox(height: 12),
          ...order.items.map((ci) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(ci.item.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(ci.item.name, style: const TextStyle(fontSize: 12, color: AC.text, fontWeight: FontWeight.w500))),
                Text('×${ci.qty}', style: const TextStyle(fontSize: 12, color: AC.text3)),
                const SizedBox(width: 10),
                Text('${RC.currency}${ci.total.toStringAsFixed(0)}',
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: AC.text)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _billCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AC.bg2, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bill', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w800, color: AC.text)),
          const SizedBox(height: 12),
          _br('Item Total', '${RC.currency}${order.subtotal.toStringAsFixed(0)}'),
          if (order.couponDiscount > 0) ...[const SizedBox(height: 6), _br('Discount', '− ${RC.currency}${order.couponDiscount.toStringAsFixed(0)}', green: true)],
          const SizedBox(height: 6),
          _br('Delivery', order.deliveryFee == 0 ? 'FREE' : '${RC.currency}${order.deliveryFee.toStringAsFixed(0)}', green: order.deliveryFee == 0),
          const SizedBox(height: 6),
          _br('Tax', '${RC.currency}${order.tax.toStringAsFixed(0)}'),
          const Divider(color: AC.bg3, height: 20),
          Row(
            children: [
              const Text('Total Paid', style: TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w800, color: AC.text)),
              const Spacer(),
              Text('${RC.currency}${order.total.toStringAsFixed(0)}',
                style: const TextStyle(fontFamily: 'Outfit', fontSize: 17, fontWeight: FontWeight.w900, color: AC.fire)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _br(String l, String v, {bool green = false}) => Row(
    children: [
      Text(l, style: const TextStyle(fontSize: 12, color: AC.text2)),
      const Spacer(),
      Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: green ? AC.success : AC.text)),
    ],
  );
}


// ════════════════════════════════════════════════════════════════
//  ORDERS HISTORY SCREEN
// ════════════════════════════════════════════════════════════════
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg2,
        automaticallyImplyLeading: false,
        title: const Text('My Orders', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: AC.text)),
      ),
      body: Consumer<AppState>(
        builder: (_, state, __) {
          final orders = state.orders;
          if (orders.isEmpty) {
            return const EmptyState(
              emoji: '📦', title: 'No orders yet',
              sub: 'Your order history will show up here once you place your first order!',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/track', arguments: order),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AC.bg2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.status.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id}',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w800, color: AC.text)),
                    Text('${order.items.fold(0, (s, ci) => s + ci.qty)} items  •  ${RC.currency}${order.total.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: AC.text3)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(order.status.label,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: order.status.color)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 30,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: order.items.length,
                itemBuilder: (_, i) => Container(
                  width: 30, height: 30,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text(order.items[i].item.emoji, style: const TextStyle(fontSize: 14))),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 11, color: AC.text3),
                const SizedBox(width: 4),
                Text(_fmtDate(order.placedAt), style: const TextStyle(fontSize: 11, color: AC.text3)),
                const Spacer(),
                const Text('View Details →', style: TextStyle(fontSize: 11, color: AC.fire, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]}  •  $h:$m $ap';
  }
}
