// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AC.bg,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: _buildHero(context, state)),
          // Stats
          SliverToBoxAdapter(child: _buildStats(state)),
          // Content
          SliverToBoxAdapter(child: _buildContent(context, state)),
          SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 100)),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E0800), Color(0xFF6B1800), AC.bg],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.fromLTRB(18, MediaQuery.of(context).padding.top + 20, 18, 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70, height: 70,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AC.fireDark, AC.fire, AC.brand],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    state.isLoggedIn ? '🧑' : '👤',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isLoggedIn ? state.user.name : 'Guest User',
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: AC.text),
                    ),
                    Text(
                      state.isLoggedIn ? state.user.phone : 'Log in for full experience',
                      style: const TextStyle(fontSize: 12, color: AC.text3),
                    ),
                  ],
                ),
              ),
              if (state.isLoggedIn)
                GestureDetector(
                  onTap: () => _editProfile(context, state),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AC.bg3.withOpacity(.6), borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Icon(Icons.edit_rounded, size: 16, color: AC.text2)),
                  ),
                ),
            ],
          ),
          if (state.isLoggedIn) ...[
            const SizedBox(height: 16),
            // Loyalty bar
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AC.bg2.withOpacity(.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AC.brand.withOpacity(.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('⭐ Loyalty Points', style: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w700, color: AC.gold)),
                      const Spacer(),
                      Text('${state.user.loyaltyPoints} pts',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w900, color: AC.gold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (state.user.loyaltyPoints % 500) / 500,
                      backgroundColor: AC.bg3,
                      color: AC.gold,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${500 - (state.user.loyaltyPoints % 500)} pts to next reward 🎁',
                    style: const TextStyle(fontSize: 10, color: AC.text3),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStats(AppState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: Row(
        children: [
          _StatCard(
            emoji: '📦',
            value: '${state.orders.length}',
            label: 'Orders',
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '❤️',
            value: '${state.favorites.length}',
            label: 'Favourites',
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '🪑',
            value: '${state.reservations.length}',
            label: 'Bookings',
          ),
          const SizedBox(width: 10),
          _StatCard(
            emoji: '💰',
            value: state.orders.isEmpty
              ? '₹0'
              : '₹${state.orders.fold(0.0, (s, o) => s + o.total).toStringAsFixed(0)}',
            label: 'Spent',
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!state.isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AC.fire.withOpacity(.15), AC.brand.withOpacity(.08)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AC.fire.withOpacity(.3)),
              ),
              child: Column(
                children: [
                  const Text('🔥 Join BurgerBlast',
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w800, color: AC.text)),
                  const SizedBox(height: 6),
                  const Text('Log in to track orders, save favourites, earn loyalty points & book tables!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AC.text3, height: 1.5)),
                  const SizedBox(height: 14),
                  PrimaryBtn(
                    label: 'Log In / Sign Up',
                    icon: Icons.login_rounded,
                    onTap: () => Navigator.of(context).pushNamed('/login'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const SectionHead(title: 'Account'),
          const SizedBox(height: 10),
          _MenuSection(items: [
            _MI('👤', 'Edit Profile', () => state.isLoggedIn ? _editProfile(context, state) : null),
            _MI('📍', 'Saved Addresses', () {}),
            _MI('💳', 'Payment Methods', () {}),
            _MI('🔔', 'Notifications', () {}),
            _MI('❤️', 'Favourites', () {}),
          ]),

          const SizedBox(height: 20),
          const SectionHead(title: 'Restaurant'),
          const SizedBox(height: 10),
          _MenuSection(items: [
            _MI('🪑', 'Book a Table', () => Navigator.of(context).pushNamed('/reserve')),
            _MI('📞', 'Call Us: ${RC.phone}', () {}),
            _MI('📧', RC.email, () {}),
            _MI('📍', RC.mapAddress, () {}),
            _MI('⏰', 'Hours: ${RC.openTime} – ${RC.closeTime}', () {}),
          ]),

          const SizedBox(height: 20),
          const SectionHead(title: 'More'),
          const SizedBox(height: 10),
          _MenuSection(items: [
            _MI('⭐', 'Rate our App', () {}),
            _MI('💬', 'Send Feedback', () {}),
            _MI('🔒', 'Privacy Policy', () {}),
            _MI('📋', 'Terms & Conditions', () {}),
            _MI('ℹ️', 'App Version 1.0.0', () {}),
          ]),

          const SizedBox(height: 22),
          if (state.isLoggedIn)
            GestureDetector(
              onTap: () {
                state.logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AC.error.withOpacity(.1),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: AC.error.withOpacity(.3)),
                ),
                child: const Center(
                  child: Text('🚪  Log Out',
                    style: TextStyle(fontSize: 14, color: AC.error, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, AppState state) {
    final nameCtrl  = TextEditingController(text: state.user.name);
    final emailCtrl = TextEditingController(text: state.user.email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: AC.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, style: const TextStyle(color: AC.text),
              decoration: const InputDecoration(hintText: 'Full name', prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: AC.text3))),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, style: const TextStyle(color: AC.text),
              decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined, size: 18, color: AC.text3))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              state.updateProfile(name: nameCtrl.text.trim(), email: emailCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  const _StatCard({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AC.bg2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(.05)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w900, color: AC.text)),
            Text(label, style: const TextStyle(fontSize: 9, color: AC.text3)),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MI> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: e.value.onTap,
                leading: Text(e.value.emoji, style: const TextStyle(fontSize: 18)),
                title: Text(e.value.label, style: const TextStyle(fontSize: 13, color: AC.text, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AC.text3),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              ),
              if (!isLast) const Divider(height: 1, color: AC.bg3, indent: 14, endIndent: 14),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MI {
  final String emoji, label;
  final VoidCallback? onTap;
  _MI(this.emoji, this.label, this.onTap);
}
