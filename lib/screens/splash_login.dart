// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade, _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light,
    ));
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut).drive(Tween(begin: .3, end: 1.0));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn).drive(Tween(begin: 0.0, end: 1.0));
    _slide = CurvedAnimation(parent: _ctrl, curve: const Interval(.4, 1.0, curve: Curves.easeOut))
      .drive(Tween(begin: 30.0, end: 0.0));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.2),
            radius: 1.0,
            colors: [Color(0xFF2E1200), AC.bg],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AC.fireDark, AC.fire, AC.brand],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AC.fire.withOpacity(0.6), blurRadius: 35, spreadRadius: 5)],
                    ),
                    child: const Center(child: Text('🍔', style: TextStyle(fontSize: 52))),
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedBuilder(
                  animation: _slide,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: child,
                  ),
                  child: Column(
                    children: [
                      Text(RC.name,
                        style: TextStyle(
                          fontFamily: 'Bangers',
                          fontSize: 46,
                          letterSpacing: 2.5,
                          color: AC.text,
                          shadows: [Shadow(color: AC.fire.withOpacity(.6), blurRadius: 20)],
                        )),
                      const SizedBox(height: 4),
                      Text(RC.tagline,
                        style: const TextStyle(fontSize: 13, color: AC.text3, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(height: 54),
                SizedBox(
                  width: 26, height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AC.fire.withOpacity(.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ════════════════════════════════════════════════════════════════
//  LOGIN SCREEN
// ════════════════════════════════════════════════════════════════
// lib/screens/login_screen.dart
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  late AnimationController _pageCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut).drive(Tween(begin: 0.0, end: 1.0));
    _pageCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_phoneCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.read<AppState>().login(
      name: _nameCtrl.text.trim().isEmpty ? 'Foodie 🍔' : _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
    );
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Hero
              Container(
                width: double.infinity,
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AC.fireDark, AC.fire, AC.brand],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -30, right: -20,
                      child: Container(width: 160, height: 160, decoration: BoxDecoration(color: Colors.white.withOpacity(.08), shape: BoxShape.circle))),
                    Positioned(bottom: -50, left: 20,
                      child: Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.white.withOpacity(.06), shape: BoxShape.circle))),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('🍔', style: TextStyle(fontSize: 52)),
                            const SizedBox(height: 8),
                            Text(RC.name,
                              style: const TextStyle(fontFamily: 'Bangers', fontSize: 36, letterSpacing: 2, color: Colors.white)),
                            Text(_isLogin ? 'Welcome back! 👋' : 'Create your account',
                              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(.75))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle
                    Container(
                      decoration: BoxDecoration(color: AC.bg2, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          _TabBtn(label: 'Log In', active: _isLogin, onTap: () => setState(() => _isLogin = true)),
                          _TabBtn(label: 'Sign Up', active: !_isLogin, onTap: () => setState(() => _isLogin = false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    if (!_isLogin) ...[
                      const Text('Your Name', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 7),
                      TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: AC.text),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Rahul Sharma',
                          prefixIcon: Icon(Icons.person_outline_rounded, color: AC.text3, size: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text('Phone Number', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AC.text),
                      decoration: const InputDecoration(
                        hintText: '+91 XXXXX XXXXX',
                        prefixIcon: Icon(Icons.phone_outlined, color: AC.text3, size: 20),
                      ),
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      const Text('Email (optional)', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 7),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AC.text),
                        decoration: const InputDecoration(
                          hintText: 'you@email.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AC.text3, size: 20),
                        ),
                      ),
                    ],

                    const SizedBox(height: 26),
                    PrimaryBtn(
                      label: _isLogin ? 'Continue →' : 'Create Account →',
                      icon: _isLogin ? Icons.login_rounded : Icons.check_circle_outline_rounded,
                      loading: _loading,
                      onTap: _submit,
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
                        child: const Text(
                          'Continue as Guest →',
                          style: TextStyle(fontSize: 13, color: AC.text3, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AC.bg3)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or continue with', style: const TextStyle(fontSize: 11, color: AC.text3)),
                        ),
                        const Expanded(child: Divider(color: AC.bg3)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _SocialBtn(label: 'Google', emoji: '🔍')),
                        const SizedBox(width: 12),
                        Expanded(child: _SocialBtn(label: 'Apple', emoji: '🍎')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: active ? AC.fire : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: active ? Colors.white : AC.text3)),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final String emoji;
  const _SocialBtn({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AC.text2)),
        ],
      ),
    );
  }
}
