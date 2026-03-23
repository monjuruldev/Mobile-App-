import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'app_theme.dart';

class AppState extends ChangeNotifier {
  // ── Auth ─────────────────────────
  bool _loggedIn = false;
  AppUser _user = AppUser();

  bool get isLoggedIn => _loggedIn;
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

  // ── Favorites ───────────────────
  final Set<String> _favs = {};

  List<String> get favorites => _favs.toList();

  bool isFav(String id) => _favs.contains(id);

  void toggleFav(String id) {
    _favs.contains(id) ? _favs.remove(id) : _favs.add(id);
    notifyListeners();
  }

  // ── Cart ────────────────────────
  final List<CartItem> _cart = [];

  List<CartItem> get cart => List.unmodifiable(_cart);

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

  double get total => _cart.fold(0.0, (s, c) => s + c.total);

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ── Orders ──────────────────────
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  Order placeOrder({required String address, required String payment}) {
    final order = Order(
      id: Uuid().v4().substring(0, 8).toUpperCase(),
      items: _cart.map((c) => CartItem(item: c.item, qty: c.qty)).toList(),
      subtotal: total,
      deliveryFee: 0,
      tax: 0,
      discount: 0,
      total: total,
      placedAt: DateTime.now(),
      address: address,
      payment: payment,
    );

    _orders.add(order);
    clearCart();
    notifyListeners();

    return order;
  }
}
