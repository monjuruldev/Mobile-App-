// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/app_state.dart';
import 'screens/splash_login.dart';
import 'screens/home_screen.dart';
import 'screens/cart_orders.dart';
import 'screens/reservation_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AC.bg2,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const BurgerBlastApp(),
    ),
  );
}

class BurgerBlastApp extends StatelessWidget {
  const BurgerBlastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: RC.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/',
      routes: {
        '/':        (_) => const SplashScreen(),
        '/login':   (_) => const LoginScreen(),
        '/home':    (_) => const AppShell(),
        '/cart':    (_) => const CartScreen(),
        '/track':   (_) => const OrderTrackingScreen(),
        '/reserve': (_) => const ReservationScreen(),
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  APP SHELL — Bottom navigation
// ════════════════════════════════════════════════════════════════
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idx = 0;

  static const _screens = [
    HomeScreen(),
    OrdersScreen(),
    ReservationScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, state, _) {
          final activeOrders = state.orders.where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled,
          ).length;

          return Container(
            decoration: const BoxDecoration(
              color: AC.bg2,
              border: Border(top: BorderSide(color: AC.bg3, width: 1)),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _NavTab(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded,
                      label: 'Menu', active: _idx == 0, onTap: () => setState(() => _idx = 0)),
                    _NavTab(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded,
                      label: 'Orders', active: _idx == 1, badge: activeOrders,
                      onTap: () => setState(() => _idx = 1)),
                    // Centre cart FAB
                    _CartFAB(onTap: () => Navigator.of(context).pushNamed('/cart'), count: state.cartCount),
                    _NavTab(icon: Icons.table_restaurant_outlined, activeIcon: Icons.table_restaurant_rounded,
                      label: 'Reserve', active: _idx == 2, onTap: () => setState(() => _idx = 2)),
                    _NavTab(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,
                      label: 'Profile', active: _idx == 3, onTap: () => setState(() => _idx = 3)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon, required this.activeIcon,
    required this.label, required this.active,
    this.badge = 0, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(active ? activeIcon : icon, size: 22,
                  color: active ? AC.fire : AC.text3),
                if (badge > 0)
                  Positioned(
                    top: -4, right: -6,
                    child: Container(
                      width: 16, height: 16,
                      decoration: const BoxDecoration(color: AC.fire, shape: BoxShape.circle),
                      child: Center(child: Text('$badge',
                        style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w900))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
              color: active ? AC.fire : AC.text3)),
          ],
        ),
      ),
    );
  }
}

class _CartFAB extends StatelessWidget {
  final VoidCallback onTap;
  final int count;
  const _CartFAB({required this.onTap, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46, height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AC.fireDark, AC.fireLight],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AC.fire.withOpacity(.45), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 18),
                ),
                if (count > 0)
                  Positioned(
                    top: -5, right: -5,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(color: AC.brand, shape: BoxShape.circle),
                      child: Center(child: Text('$count',
                        style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w900))),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            const Text('Cart', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AC.fire)),
          ],
        ),
      ),
    );
  }
}
