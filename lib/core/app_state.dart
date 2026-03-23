import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'app_theme.dart';

class AppState extends ChangeNotifier {
  // ── Auth ─────────────────────────────────────────────────────────────────
  bool _loggedIn = false;
  AppUser _user = AppUser();
  bool get loggedIn => _loggedIn;
  AppUser get user => _user;

  void login({required String name, required String phone, required String email}) {
    _loggedIn = true;
    _user = AppUser(name: name, phone: phone, email: email, loyaltyPoints: 50);
    notifyListeners();
  }

  void logout() {
    _loggedIn = false;
    _user = AppUser();
    notifyListeners();
  }

  void updateProfile({String? name, String? email}) {
    if (name != null) _user.name = name;
    if (email != null) _user.email = email;
    notifyListeners();
  }

  // ── Favorites ────────────────────────────────────────────────────────────
  final Set<String> _favs = {};
  Set<String> get favs => Set.unmodifiable(_favs);
  bool isFav(String id) => _favs.contains(id);
  void toggleFav(String id) {
    _favs.contains(id) ? _favs.remove(id) : _favs.add(id);
    notifyListeners();
  }

  // ── Cart ─────────────────────────────────────────────────────────────────
  final List<CartItem> _cart = [];
  String _coupon = '';
  double _saving = 0;
  bool _freeDel = false;

  List<CartItem> get cart => List.unmodifiable(_cart);
  int get cartCount => _cart.fold(0, (s, c) => s + c.qty);
  bool get cartEmpty => _cart.isEmpty;
  String get coupon => _coupon;
  double get saving => _saving;
  bool get freeDel => _freeDel;

  double get subtotal => _cart.fold(0.0, (s, c) => s + c.total);

  double get deliveryFee {
    if (_freeDel || subtotal >= RC.freeDelMin) return 0;
    return RC.deliveryFee;
  }

  double get tax => (subtotal - _saving).clamp(0.0, double.infinity) * RC.taxRate;
  double get total => subtotal - _saving + deliveryFee + tax;

  int qtyOf(String id) {
    final i = _cart.indexWhere((c) => c.item.id == id);
    return i >= 0 ? _cart[i].qty : 0;
  }

  void add(FoodItem item) {
    final i = _cart.indexWhere((c) => c.item.id == item.id);
    if (i >= 0) {
      _cart[i].qty++;
    } else {
      _cart.add(CartItem(item: item));
    }
    notifyListeners();
  }

  void remove(FoodItem item) {
    final i = _cart.indexWhere((c) => c.item.id == item.id);
    if (i >= 0) {
      if (_cart[i].qty > 1) {
        _cart[i].qty--;
      } else {
        _cart.removeAt(i);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _coupon = '';
    _saving = 0;
    _freeDel = false;
    notifyListeners();
  }

  String? applyCoupon(String code) {
    final offer = SampleData.offers.cast<Offer?>().firstWhere(
      (o) => o!.code.toUpperCase() == code.toUpperCase(),
      orElse: () => null,
    );
    if (offer == null) return 'Invalid coupon code';
    if (subtotal < offer.minOrder) {
      return 'Min order ${RC.currency}${offer.minOrder.toStringAsFixed(0)} required';
    }
    _coupon = offer.code;
    if (offer.freeDelivery) {
      _freeDel = true;
      _saving = 0;
    } else {
      _freeDel = false;
      double s = subtotal * (offer.discountPct / 100);
      if (offer.maxSaving != null) s = s.clamp(0, offer.maxSaving!);
      _saving = s;
    }
    notifyListeners();
    return null;
  }

  void removeCoupon() {
    _coupon = '';
    _saving = 0;
    _freeDel = false;
    notifyListeners();
  }

  // ── Orders ───────────────────────────────────────────────────────────────
  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders.reversed.toList());

  Order placeOrder({required String address, required String payment}) {
    final order = Order(
      id: const Uuid().v4().substring(0, 8).toUpperCase(),
      items: _cart.map((c) => CartItem(item: c.item, qty: c.qty, note: c.note)).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      tax: tax,
      discount: _saving,
      total: total,
      placedAt: DateTime.now(),
      address: address,
      payment: payment,
      coupon: _coupon.isEmpty ? null : _coupon,
    );
    _orders.add(order);
    if (_loggedIn) _user.loyaltyPoints += (order.total / 10).round();
    clearCart();

    Future.delayed(const Duration(seconds: 4), () {
      order.status = OrderStatus.confirmed;
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 10), () {
      order.status = OrderStatus.preparing;
      notifyListeners();
    });
    Future.delayed(const Duration(seconds: 22), () {
      order.status = OrderStatus.onTheWay;
      notifyListeners();
    });
    return order;
  }

  // ── Reservations ─────────────────────────────────────────────────────────
  final List<Reservation> _reservations = [];
  List<Reservation> get reservations =>
      List.unmodifiable(_reservations.reversed.toList());

  Reservation makeReservation({
    required String name,
    required String phone,
    required DateTime dateTime,
    required int guests,
    String? note,
  }) {
    final r = Reservation(
      id: const Uuid().v4().substring(0, 6).toUpperCase(),
      name: name,
      phone: phone,
      dateTime: dateTime,
      guests: guests,
      tableNo: (_reservations.length % RC.totalTables) + 1,
      note: note,
    );
    _reservations.add(r);
    Future.delayed(const Duration(seconds: 3), () {
      r.status = ResStatus.confirmed;
      notifyListeners();
    });
    notifyListeners();
    return r;
  }

  void cancelReservation(String id) {
    final i = _reservations.indexWhere((r) => r.id == id);
    if (i >= 0) {
      _reservations[i].status = ResStatus.cancelled;
      notifyListeners();
    }
  }
}
