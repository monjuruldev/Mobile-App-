import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

// ════════════════════════════════════════════════════════════════
//  SPLASH SCREEN
// ════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut)
        .drive(Tween<double>(begin: 0.3, end: 1.0));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween<double>(begin: 0.0, end: 1.0));
    _slide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 30.0, end: 0.0));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
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
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AC.fireDark, AC.fire, AC.brand],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AC.fire.withOpacity(0.6),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🍔', style: TextStyle(fontSize: 52)),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                AnimatedBuilder(
                  animation: _slide,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slide.value),
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        RC.name,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: AC.text,
                          shadows: [
                            Shadow(
                              color: AC.fire.withOpacity(0.6),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        RC.tagline,
                        style: TextStyle(
                          fontSize: 13,
                          color: AC.text3,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 54),
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AC.fire.withOpacity(0.5),
                  ),
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
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _loading = false;
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut)
        .drive(Tween<double>(begin: 0.0, end: 1.0));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    context.read<AppState>().login(
      name: _nameCtrl.text.trim().isEmpty ? 'Foodie' : _nameCtrl.text.trim(),
      phone: phone,
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
              _buildHero(),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
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
          Positioned(
            top: -30, right: -20,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50, left: 20,
            child: Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('🍔', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 8),
                  Text(
                    RC.name,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _isLogin ? 'Welcome back! 👋' : 'Create your account',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle bar
          Container(
            decoration: BoxDecoration(
              color: AC.bg2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _TabBtn(
                  label: 'Log In',
                  active: _isLogin,
                  onTap: () => setState(() => _isLogin = true),
                ),
                _TabBtn(
                  label: 'Sign Up',
                  active: !_isLogin,
                  onTap: () => setState(() => _isLogin = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          if (!_isLogin) ...[
            _fieldLabel('Your Name'),
            const SizedBox(height: 7),
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AC.text),
              decoration: const InputDecoration(
                hintText: 'e.g. Rahul Sharma',
                prefixIcon: Icon(Icons.person_outline_rounded,
                    color: AC.text3, size: 20),
              ),
            ),
            const SizedBox(height: 16),
          ],

          _fieldLabel('Phone Number'),
          const SizedBox(height: 7),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AC.text),
            decoration: const InputDecoration(
              hintText: '+91 XXXXX XXXXX',
              prefixIcon: Icon(Icons.phone_outlined,
                  color: AC.text3, size: 20),
            ),
          ),

          if (!_isLogin) ...[
            const SizedBox(height: 16),
            _fieldLabel('Email (optional)'),
            const SizedBox(height: 7),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: AC.text),
              decoration: const InputDecoration(
                hintText: 'you@email.com',
                prefixIcon: Icon(Icons.email_outlined,
                    color: AC.text3, size: 20),
              ),
            ),
          ],

          const SizedBox(height: 26),
          PrimaryBtn(
            label: _isLogin ? 'Continue →' : 'Create Account →',
            icon: _isLogin
                ? Icons.login_rounded
                : Icons.check_circle_outline_rounded,
            loading: _loading,
            onTap: _submit,
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
              child: const Text(
                'Continue as Guest →',
                style: TextStyle(
                  fontSize: 13,
                  color: AC.text3,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Row(
            children: [
              Expanded(child: Divider(color: AC.bg3)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: TextStyle(fontSize: 11, color: AC.text3),
                ),
              ),
              Expanded(child: Divider(color: AC.bg3)),
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
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600,
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
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: active ? Colors.white : AC.text3,
            ),
          ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: AC.text2,
            ),
          ),
        ],
      ),
    );
  }
}
