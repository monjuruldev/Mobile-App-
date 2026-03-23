// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _catId = 'all';
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<FoodItem> get filtered {
    var items = SampleData.menu;
    if (_catId != 'all') items = items.where((i) => i.categoryId == _catId).toList();
    if (_query.isNotEmpty) {
      items = items.where((i) =>
        i.name.toLowerCase().contains(_query.toLowerCase()) ||
        i.description.toLowerCase().contains(_query.toLowerCase())
      ).toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AC.bg,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader(state)),

                // ── Search ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(color: AC.text, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search burgers, sides, drinks...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AC.text3, size: 20),
                        suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: AC.text3),
                              onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); })
                          : null,
                      ),
                    ),
                  ),
                ),

                // ── Promo Banner (hidden during search) ─────────────────
                if (_query.isEmpty) ...[
                  SliverToBoxAdapter(child: _buildBanner()),
                  // Offers strip
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                  SliverToBoxAdapter(
                    child: SectionHead(
                      title: '🎁 Hot Deals',
                      action: 'See all',
                      onAction: () {},
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverToBoxAdapter(child: _buildOffers(state)),
                ],

                // ── Categories ──────────────────────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 22)),
                SliverToBoxAdapter(
                  child: SectionHead(
                    title: _query.isEmpty ? '🍽️ Our Menu' : '🔍 Results',
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                if (_query.isEmpty)
                  SliverToBoxAdapter(child: _buildCategories()),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ── Menu Items ──────────────────────────────────────────
                filtered.isEmpty
                  ? SliverToBoxAdapter(
                      child: EmptyState(
                        emoji: '🔍',
                        title: 'Nothing here!',
                        sub: 'Try searching something else',
                        btnLabel: 'Clear',
                        onBtn: () { _searchCtrl.clear(); setState(() => _query = ''); },
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => MenuCard(item: filtered[i]),
                        childCount: filtered.length,
                      ),
                    ),

                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          ),
          CartBar(onTap: () => Navigator.of(context).pushNamed('/cart')),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(14, top + 14, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AC.bg2, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(color: AC.fire, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('Delivering to', style: TextStyle(fontSize: 11, color: AC.text3)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      state.isLoggedIn
                        ? 'Hi ${state.user.name.split(' ').first}! 👋'
                        : RC.address,
                      style: const TextStyle(
                        fontFamily: 'Outfit', fontSize: 16,
                        fontWeight: FontWeight.w800, color: AC.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AC.fire),
                  ],
                ),
              ],
            ),
          ),
          // Loyalty badge
          if (state.isLoggedIn)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AC.brand.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AC.brand.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text('${state.user.loyaltyPoints} pts',
                    style: const TextStyle(fontSize: 11, color: AC.gold, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          // Notification
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(11)),
            child: Stack(
              children: [
                const Center(child: Icon(Icons.notifications_outlined, color: AC.text2, size: 20)),
                Positioned(
                  top: 8, right: 8,
                  child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AC.fire, shape: BoxShape.circle)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      height: 148,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A0800), Color(0xFF3D1000), Color(0xFF6B1A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AC.fire.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AC.fire.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(top: -25, right: -15,
            child: Container(width: 120, height: 120, decoration: BoxDecoration(color: AC.fire.withOpacity(.12), shape: BoxShape.circle))),
          Positioned(bottom: -35, right: 50,
            child: Container(width: 80, height: 80, decoration: BoxDecoration(color: AC.brand.withOpacity(.08), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AC.fire.withOpacity(.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AC.fire.withOpacity(.4)),
                        ),
                        child: const Text('🔥 TODAY ONLY', style: TextStyle(fontSize: 9, color: AC.brand, fontWeight: FontWeight.w900, letterSpacing: .6)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buy 2 Get\n1 FREE!',
                        style: TextStyle(fontFamily: 'Bangers', fontSize: 28, letterSpacing: 1.2, color: Colors.white, height: 1.1),
                      ),
                      const SizedBox(height: 8),
                      const Text('On all Classic Burgers', style: TextStyle(fontSize: 11, color: AC.text2)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AC.fire,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: [BoxShadow(color: AC.fire.withOpacity(.5), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: const Text('Order Now', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text('🍔', style: TextStyle(fontSize: 78)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffers(AppState state) {
    return SizedBox(
      height: 115,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: SampleData.offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final o = SampleData.offers[i];
          return OfferChip(
            offer: o,
            applied: state.appliedCoupon == o.code,
            onApply: () {
              final err = state.applyCoupon(o.code);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(err ?? '✅ ${o.code} applied!'),
                backgroundColor: err != null ? AC.error : AC.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ));
            },
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: SampleData.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final cat = SampleData.categories[i];
          final sel = cat.id == _catId;
          return GestureDetector(
            onTap: () => setState(() => _catId = cat.id),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: sel ? AC.fire.withOpacity(.15) : AC.bg3,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AC.fire : Colors.transparent, width: 1.5),
                  ),
                  child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(height: 5),
                Text(cat.name,
                  style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600,
                    color: sel ? AC.fire : AC.text3,
                  )),
              ],
            ),
          );
        },
      ),
    );
  }
}
