import 'package:flutter/material.dart';

class AppUser {
  String name;
  String phone;
  String email;
  int loyaltyPoints;
  List<String> addresses;

  AppUser({
    this.name = 'Guest',
    this.phone = '',
    this.email = '',
    this.loyaltyPoints = 0,
    List<String>? addresses,
  }) : addresses = addresses ?? ['Home – Guwahati, Assam'];
}

class Category {
  final String id;
  final String name;
  final String emoji;
  const Category({required this.id, required this.name, required this.emoji});
}

class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? mrp;
  final String emoji;
  final String categoryId;
  final bool isVeg;
  final bool isBestseller;
  final bool isSpicy;
  final bool isNew;
  final double rating;
  final int calories;
  final int prepMins;

  const FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.mrp,
    required this.emoji,
    required this.categoryId,
    this.isVeg = false,
    this.isBestseller = false,
    this.isSpicy = false,
    this.isNew = false,
    this.rating = 4.5,
    this.calories = 400,
    this.prepMins = 15,
  });

  int get discountPct =>
      mrp != null ? ((mrp! - price) / mrp! * 100).round() : 0;
}

class CartItem {
  final FoodItem item;
  int qty;
  String note;
  CartItem({required this.item, this.qty = 1, this.note = ''});
  double get total => item.price * qty;
}

enum OrderStatus { placed, confirmed, preparing, onTheWay, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.placed:     return 'Order Placed';
      case OrderStatus.confirmed:  return 'Confirmed';
      case OrderStatus.preparing:  return 'Preparing';
      case OrderStatus.onTheWay:   return 'On The Way';
      case OrderStatus.delivered:  return 'Delivered';
      case OrderStatus.cancelled:  return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.placed:     return '📋';
      case OrderStatus.confirmed:  return '✅';
      case OrderStatus.preparing:  return '👨‍🍳';
      case OrderStatus.onTheWay:   return '🛵';
      case OrderStatus.delivered:  return '🎉';
      case OrderStatus.cancelled:  return '❌';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.placed:     return const Color(0xFFFFCC00);
      case OrderStatus.confirmed:  return const Color(0xFF4ADE80);
      case OrderStatus.preparing:  return const Color(0xFFFF6B35);
      case OrderStatus.onTheWay:   return const Color(0xFF38BDF8);
      case OrderStatus.delivered:  return const Color(0xFF4ADE80);
      case OrderStatus.cancelled:  return const Color(0xFFFF4040);
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.placed:     return 0;
      case OrderStatus.confirmed:  return 1;
      case OrderStatus.preparing:  return 2;
      case OrderStatus.onTheWay:   return 3;
      case OrderStatus.delivered:  return 4;
      case OrderStatus.cancelled:  return -1;
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double discount;
  final double total;
  final DateTime placedAt;
  final String address;
  final String payment;
  final String? coupon;
  OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.placedAt,
    required this.address,
    required this.payment,
    this.coupon,
    this.status = OrderStatus.placed,
  });
}

enum ResStatus { pending, confirmed, cancelled }

class Reservation {
  final String id;
  final String name;
  final String phone;
  final DateTime dateTime;
  final int guests;
  final int tableNo;
  final String? note;
  ResStatus status;

  Reservation({
    required this.id,
    required this.name,
    required this.phone,
    required this.dateTime,
    required this.guests,
    required this.tableNo,
    this.note,
    this.status = ResStatus.pending,
  });

  String get statusLabel {
    switch (status) {
      case ResStatus.pending:   return 'Pending';
      case ResStatus.confirmed: return 'Confirmed';
      case ResStatus.cancelled: return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case ResStatus.pending:   return const Color(0xFFFFCC00);
      case ResStatus.confirmed: return const Color(0xFF4ADE80);
      case ResStatus.cancelled: return const Color(0xFFFF4040);
    }
  }
}

class Offer {
  final String id;
  final String code;
  final String title;
  final String subtitle;
  final String emoji;
  final double discountPct;
  final double? maxSaving;
  final double minOrder;
  final bool freeDelivery;

  const Offer({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.discountPct = 0,
    this.maxSaving,
    required this.minOrder,
    this.freeDelivery = false,
  });
}

// ─── Sample Data ─────────────────────────────────────────────────────────────
class SampleData {
  static const List<Category> categories = [
    Category(id: 'all',      name: 'All',      emoji: '🍽️'),
    Category(id: 'burgers',  name: 'Burgers',  emoji: '🍔'),
    Category(id: 'combos',   name: 'Combos',   emoji: '🎁'),
    Category(id: 'sides',    name: 'Sides',    emoji: '🍟'),
    Category(id: 'wraps',    name: 'Wraps',    emoji: '🌯'),
    Category(id: 'drinks',   name: 'Drinks',   emoji: '🥤'),
    Category(id: 'desserts', name: 'Desserts', emoji: '🍦'),
  ];

  static const List<FoodItem> menu = [
    // Burgers
    FoodItem(id: 'b1', name: 'Classic Smash Burger',
      description: 'Double smash patty, American cheese, special sauce, pickles & shredded lettuce in a brioche bun',
      price: 189, mrp: 229, emoji: '🍔', categoryId: 'burgers',
      isBestseller: true, rating: 4.9, calories: 620, prepMins: 12),
    FoodItem(id: 'b2', name: 'Spicy Crispy Chicken',
      description: 'Crispy fried chicken thigh with jalapeño sauce, coleslaw & pickles on a toasted sesame bun',
      price: 199, emoji: '🐔', categoryId: 'burgers',
      isBestseller: true, isSpicy: true, rating: 4.8, calories: 580, prepMins: 14),
    FoodItem(id: 'b3', name: 'BBQ Bacon Stack',
      description: 'Triple beef patty, smoked bacon, BBQ sauce, onion rings, cheddar & chipotle mayo',
      price: 279, mrp: 319, emoji: '🥓', categoryId: 'burgers',
      rating: 4.7, calories: 890, prepMins: 15),
    FoodItem(id: 'b4', name: 'Garden Veggie Burger',
      description: 'House-made black bean patty, avocado spread, fresh tomato, lettuce & sriracha aioli',
      price: 159, emoji: '🥗', categoryId: 'burgers',
      isVeg: true, rating: 4.5, calories: 390, prepMins: 12),
    FoodItem(id: 'b5', name: 'Mushroom Swiss Melt',
      description: 'Juicy beef patty with sautéed mushrooms, Swiss cheese & truffle mayo',
      price: 219, emoji: '🍄', categoryId: 'burgers',
      isNew: true, rating: 4.6, calories: 540, prepMins: 13),
    FoodItem(id: 'b6', name: 'Paneer Tikka Burger',
      description: 'Tandoori marinated paneer cutlet, mint chutney, pickled onions & masala mayo',
      price: 169, mrp: 199, emoji: '🧀', categoryId: 'burgers',
      isVeg: true, isBestseller: true, isSpicy: true, rating: 4.7, calories: 420, prepMins: 15),
    // Combos
    FoodItem(id: 'c1', name: 'Classic Combo Meal',
      description: 'Classic Smash Burger + Large Fries + 500ml Soft Drink',
      price: 329, mrp: 409, emoji: '🎁', categoryId: 'combos',
      isBestseller: true, rating: 4.8, calories: 1050, prepMins: 15),
    FoodItem(id: 'c2', name: 'Chicken Feast Combo',
      description: 'Spicy Chicken Burger + 6pc Nuggets + Large Fries + Drink',
      price: 399, mrp: 499, emoji: '🍗', categoryId: 'combos',
      rating: 4.7, calories: 1240, prepMins: 18),
    FoodItem(id: 'c3', name: 'Veggie Combo Meal',
      description: 'Veggie Burger + Medium Fries + Fresh Lime Soda',
      price: 269, mrp: 330, emoji: '🌿', categoryId: 'combos',
      isVeg: true, rating: 4.5, calories: 780, prepMins: 14),
    FoodItem(id: 'c4', name: 'Party Pack (4 people)',
      description: '4 Burgers + 4 Large Fries + 4 Drinks + 20pc Nuggets',
      price: 1199, mrp: 1599, emoji: '🎉', categoryId: 'combos',
      rating: 4.9, calories: 4200, prepMins: 25),
    // Sides
    FoodItem(id: 's1', name: 'Loaded Cheese Fries',
      description: 'Crispy golden fries drowned in molten cheddar sauce & jalapeños',
      price: 129, emoji: '🧀', categoryId: 'sides',
      isVeg: true, isBestseller: true, isSpicy: true, rating: 4.8, calories: 520, prepMins: 8),
    FoodItem(id: 's2', name: 'Classic French Fries',
      description: 'Golden crispy fries, perfectly salted',
      price: 79, emoji: '🍟', categoryId: 'sides',
      isVeg: true, rating: 4.7, calories: 320, prepMins: 7),
    FoodItem(id: 's3', name: 'Chicken Nuggets (9pc)',
      description: 'Crispy bite-sized chicken nuggets with dipping sauce',
      price: 149, emoji: '🍗', categoryId: 'sides',
      isBestseller: true, rating: 4.7, calories: 430, prepMins: 10),
    FoodItem(id: 's4', name: 'Onion Rings (10pc)',
      description: 'Beer-battered crispy onion rings with smoky chipotle dip',
      price: 99, emoji: '🧅', categoryId: 'sides',
      isVeg: true, rating: 4.5, calories: 280, prepMins: 8),
    // Wraps
    FoodItem(id: 'w1', name: 'Grilled Chicken Wrap',
      description: 'Herb-marinated grilled chicken, fresh greens, tomato & honey mustard in a whole wheat tortilla',
      price: 169, emoji: '🌯', categoryId: 'wraps',
      rating: 4.6, calories: 460, prepMins: 12),
    FoodItem(id: 'w2', name: 'Paneer Tikka Wrap',
      description: 'Smoky tandoori paneer, crispy lettuce, onion rings, mint chutney & chaat masala',
      price: 149, emoji: '🧆', categoryId: 'wraps',
      isVeg: true, rating: 4.5, calories: 390, prepMins: 12),
    // Drinks
    FoodItem(id: 'd1', name: 'Chocolate Milkshake',
      description: 'Thick creamy chocolate shake topped with whipped cream',
      price: 119, emoji: '🍫', categoryId: 'drinks',
      isVeg: true, isBestseller: true, rating: 4.9, calories: 480, prepMins: 5),
    FoodItem(id: 'd2', name: 'Fresh Lemonade',
      description: 'Hand-squeezed lemonade with mint, served over crushed ice',
      price: 69, emoji: '🍋', categoryId: 'drinks',
      isVeg: true, rating: 4.7, calories: 110, prepMins: 3),
    FoodItem(id: 'd3', name: 'Classic Cola (500ml)',
      description: 'Ice-cold cola served in a frosty glass',
      price: 59, emoji: '🥤', categoryId: 'drinks',
      isVeg: true, rating: 4.5, calories: 180, prepMins: 1),
    FoodItem(id: 'd4', name: 'Mango Lassi',
      description: 'Thick chilled mango yogurt drink with a pinch of cardamom',
      price: 89, emoji: '🥭', categoryId: 'drinks',
      isVeg: true, isBestseller: true, rating: 4.8, calories: 290, prepMins: 4),
    // Desserts
    FoodItem(id: 'ds1', name: 'Nutella Lava Brownie',
      description: 'Warm gooey brownie with Nutella lava center + vanilla ice cream',
      price: 149, emoji: '🍫', categoryId: 'desserts',
      isVeg: true, isBestseller: true, rating: 4.9, calories: 520, prepMins: 10),
    FoodItem(id: 'ds2', name: 'Classic Soft Serve',
      description: 'Creamy vanilla soft-serve ice cream in a cone or cup',
      price: 59, emoji: '🍦', categoryId: 'desserts',
      isVeg: true, rating: 4.7, calories: 210, prepMins: 2),
  ];

  static const List<Offer> offers = [
    Offer(id: 'o1', code: 'BLAST50', title: '50% Off First Order',
      subtitle: 'Save up to ₹100 on your first order',
      emoji: '🔥', discountPct: 50, maxSaving: 100, minOrder: 149),
    Offer(id: 'o2', code: 'BURGER30', title: '30% Off on ₹349+',
      subtitle: 'Save up to ₹120',
      emoji: '🍔', discountPct: 30, maxSaving: 120, minOrder: 349),
    Offer(id: 'o3', code: 'FREEDEL', title: 'Free Delivery',
      subtitle: 'Zero delivery fee on any order',
      emoji: '🛵', minOrder: 199, freeDelivery: true),
    Offer(id: 'o4', code: 'COMBO25', title: '25% Off Combos',
      subtitle: 'On all combo meals above ₹249',
      emoji: '🎁', discountPct: 25, maxSaving: 80, minOrder: 249),
  ];

  static const List<String> timeSlots = [
    '11:00 AM', '11:30 AM', '12:00 PM', '12:30 PM',
    '1:00 PM',  '1:30 PM',  '2:00 PM',  '2:30 PM',
    '6:00 PM',  '6:30 PM',  '7:00 PM',  '7:30 PM',
    '8:00 PM',  '8:30 PM',  '9:00 PM',  '9:30 PM',
  ];
}
