// lib/core/app_state.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'app_theme.dart';

class AppState extends ChangeNotifier {
  // ── Auth ────────────────────────────────────────────────────────────────
  bool _isLoggedIn = false;
  AppUser _user = AppUser();

  bool get isLoggedIn => _isLoggedIn;
  AppUser get user => _user;

  void login({
    required String name,
    required String phone,
    required String email,
  }) {
    _isLoggedIn = true;
    _user = AppUser(name: name, phone: phone, email: email, loyaltyPoints: 50);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _user = AppUser();
    notifyListeners();
  }

  void updateProfile({String? name, String? phone, String? email}) {
    if (name != null) _user.name = name;
    if (phone != null) _user.phone = phone;
    if (email != null) _user.email = email;
    notifyListeners();
  }

  void addAddress(String address) {
    _user.savedAddresses.add(address);
    notifyListeners();
  }

  // ── Cart ────────────────────────────────────────────────────────────────
  final List<CartItem> _cart = [];
  String _appliedCoupon = '';
  double _couponSaving = 0;
  bool _freeDelivery = false;

  List<CartItem> get cart => List.unmodifiable(_cart);
  int get cartCount => _cart.fold(0, (s, ci) => s + ci.qty);
  String get appliedCoupon => _appliedCoupon;
  double get couponSaving => _couponSaving;
  bool get freeDelivery => _freeDelivery;
  bool get cartEmpty => _cart.isEmpty;

  double get subtotal => _cart.fold(0, (s, ci) => s + ci.total);
  double get deliveryFee {
    if (_freeDelivery || subtotal >= RC.freeDelMin) return 0;
    return RC.deliveryFee;
  }
  double get tax => (subtotal - _couponSaving).clamp(0, double.infinity) * RC.taxRate;
  double get total => subtotal - _couponSaving + deliveryFee + tax;

  void addToCart(FoodItem item) {
    final idx = _cart.indexWhere((ci) => ci.item.id == item.id);
    if (idx >= 0) {
      _cart[idx].qty++;
    } else {
      _cart.add(CartItem(item: item));
    }
    notifyListeners();
  }

  void removeFromCart(FoodItem item) {
    final idx = _cart.indexWhere((ci) => ci.item.id == item.id);
    if (idx >= 0) {
      if (_cart[idx].qty > 1) {
        _cart[idx].qty--;
      } else {
        _cart.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _appliedCoupon = '';
    _couponSaving = 0;
    _freeDelivery = false;
    notifyListeners();
  }

  int qtyOf(String id) {
    final idx = _cart.indexWhere((ci) => ci.item.id == id);
    return idx >= 0 ? _cart[idx].qty : 0;
  }

  void setCustomization(String itemId, String note) {
    final idx = _cart.indexWhere((ci) => ci.item.id == itemId);
    if (idx >= 0) {
      _cart[idx].customization = note;
      notifyListeners();
    }
  }

  // Coupons
  String? applyCoupon(String code) {
    final offer = SampleData.offers.cast<Offer?>().firstWhere(
      (o) => o!.code.toUpperCase() == code.toUpperCase(),
      orElse: () => null,
    );
    if (offer == null) return 'Invalid coupon code. Try again!';
    if (subtotal < offer.minOrder) {
      return 'Minimum order ${RC.currency}${offer.minOrder.toStringAsFixed(0)} required';
    }
    _appliedCoupon = offer.code;
    if (offer.isFreeDelivery) {
      _freeDelivery = true;
      _couponSaving = 0;
    } else {
      _freeDelivery = false;
      double saving = subtotal * (offer.discountPct / 100);
      if (offer.maxSaving != null) saving = saving.clamp(0, offer.maxSaving!);
      _couponSaving = saving;
    }
    notifyListeners();
    return null;
  }

  void removeCoupon() {
    _appliedCoupon = '';
    _couponSaving = 0;
    _freeDelivery = false;
    notifyListeners();
  }

  // ── Orders ──────────────────────────────────────────────────────────────
  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders.reversed.toList());

  Order placeOrder({required String address, required String payment}) {
    final order = Order(
      id: const Uuid().v4().substring(0, 8).toUpperCase(),
      items: _cart.map((ci) => CartItem(
        item: ci.item, qty: ci.qty, customization: ci.customization,
      )).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      couponDiscount: _couponSaving,
      total: total,
      placedAt: DateTime.now(),
      address: address,
      paymentMethod: payment,
      couponCode: _appliedCoupon.isEmpty ? null : _appliedCoupon,
    );
    _orders.add(order);
    clearCart();
    // Add loyalty points for logged-in user
    _user.loyaltyPoints += (order.total / 10).round();

    // Simulate live status updates
    Future.delayed(const Duration(seconds: 4), () { order.status = OrderStatus.confirmed; notifyListeners(); });
    Future.delayed(const Duration(seconds: 10), () { order.status = OrderStatus.preparing; notifyListeners(); });
    Future.delayed(const Duration(seconds: 22), () { order.status = OrderStatus.onTheWay; notifyListeners(); });
    return order;
  }

  // ── Reservations ────────────────────────────────────────────────────────
  final List<Reservation> _reservations = [];
  List<Reservation> get reservations => List.unmodifiable(_reservations.reversed.toList());

  Reservation makeReservation({
    required String name,
    required String phone,
    required DateTime dateTime,
    required int guests,
    String? note,
  }) {
    // Assign random table
    final table = (_reservations.length % RC.totalTables) + 1;
    final r = Reservation(
      id: Uuid().v4().substring(0, 6).toUpperCase(),
      customerName: name,
      phone: phone,
      dateTime: dateTime,
      guests: guests,
      tableNumber: table,
      specialRequest: note,
    );
    _reservations.add(r);
    // Auto-confirm after 3s
    Future.delayed(const Duration(seconds: 3), () {
      r.status = ReservationStatus.confirmed;
      notifyListeners();
    });
    notifyListeners();
    return r;
  }

  void cancelReservation(String id) {
    final idx = _reservations.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _reservations[idx].status = ReservationStatus.cancelled;
      notifyListeners();
    }
  }

  // ── Favorites ───────────────────────────────────────────────────────────
  final Set<String> _favorites = {};
  Set<String> get favorites => Set.unmodifiable(_favorites);

  void toggleFavorite(String itemId) {
    if (_favorites.contains(itemId)) {
      _favorites.remove(itemId);
    } else {
      _favorites.add(itemId);
    }
    notifyListeners();
  }

  bool isFav(String itemId) => _favorites.contains(itemId);
}
