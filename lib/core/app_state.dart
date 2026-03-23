import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';
import 'app_theme.dart';

class AppState extends ChangeNotifier {
  bool _loggedIn = false;
  AppUser _user = AppUser();

  bool get loggedIn => _loggedIn;
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

  void updateProfile({String? name, String? email}) {
    if (name != null) _user.name = name;
    if (email != null) _user.email = email;
    notifyListeners();
  }

  final Set<String> _favs = {};
  Set<String> get favs => Set.unmodifiable(_favs);
  List<String> get favorites => _favs.toList();

  bool isFav(String id) => _favs.contains(id);

  void toggleFav(String id) {
    _favs.contains(id) ? _favs.remove(id) : _favs.add(id);
    notifyListeners();
  }

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

  Order placeOrder({required String address, required String payment}) {
    final order = Order(
      id: Uuid().v4().substring(0, 8).toUpperCase(),
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

    return order;
  }
}
