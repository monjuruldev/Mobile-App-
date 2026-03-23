// lib/screens/reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/models.dart';
import '../core/app_state.dart';
import '../widgets/shared.dart';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});
  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AC.bg,
      appBar: AppBar(
        backgroundColor: AC.bg2,
        automaticallyImplyLeading: false,
        title: const Text('Table Reservation', style: TextStyle(fontFamily: 'Outfit', fontSize: 20, fontWeight: FontWeight.w800, color: AC.text)),
        bottom: TabBar(
          controller: _tab,
          labelColor: AC.fire,
          unselectedLabelColor: AC.text3,
          indicatorColor: AC.fire,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [Tab(text: 'Book a Table'), Tab(text: 'My Bookings')],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _BookingForm(),
          _MyBookings(),
        ],
      ),
    );
  }
}

// ─── Booking Form ─────────────────────────────────────────────────────────────
class _BookingForm extends StatefulWidget {
  const _BookingForm();
  @override
  State<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<_BookingForm> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  int _guests = 2;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill from profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      if (state.isLoggedIn) {
        _nameCtrl.text  = state.user.name;
        _phoneCtrl.text = state.user.phone;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all required fields'),
        backgroundColor: AC.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Parse time
    final parts = _selectedTime!.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
    var hour = int.parse(parts[0]);
    final min = int.parse(parts[1]);
    if (_selectedTime!.contains('PM') && hour != 12) hour += 12;
    if (_selectedTime!.contains('AM') && hour == 12) hour = 0;

    final dateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, hour, min);

    final r = context.read<AppState>().makeReservation(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dateTime: dateTime,
      guests: _guests,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    setState(() => _loading = false);
    if (mounted) _showSuccess(r);
  }

  void _showSuccess(Reservation r) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: AC.success.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('🎉', style: TextStyle(fontSize: 36))),
            ),
            const SizedBox(height: 16),
            const Text('Reservation Requested!',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: AC.text)),
            const SizedBox(height: 8),
            Text(
              'Booking #${r.id}\nWe\'ll confirm shortly via SMS!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AC.text2, height: 1.5),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _confirmRow('📅', _fmtDate(r.dateTime)),
                  const SizedBox(height: 6),
                  _confirmRow('⏰', _fmtTimePretty(r.dateTime)),
                  const SizedBox(height: 6),
                  _confirmRow('👥', '${r.guests} Guests'),
                  const SizedBox(height: 6),
                  _confirmRow('🪑', 'Table #${r.tableNumber}'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryBtn(
              label: 'Done',
              onTap: () { Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmRow(String emoji, String val) => Row(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 15)),
      const SizedBox(width: 8),
      Text(val, style: const TextStyle(fontSize: 13, color: AC.text, fontWeight: FontWeight.w500)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AC.fire.withOpacity(.15), AC.brand.withOpacity(.08)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AC.fire.withOpacity(.2)),
          ),
          child: Row(
            children: [
              const Text('🪑', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Reserve a Table',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: AC.text)),
                    Text('${RC.totalTables} tables available  •  Opens ${RC.openTime}',
                      style: const TextStyle(fontSize: 11, color: AC.text3)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),
        const Text('Your Name *', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(color: AC.text),
          decoration: const InputDecoration(
            hintText: 'Full name',
            prefixIcon: Icon(Icons.person_outline_rounded, color: AC.text3, size: 20),
          ),
        ),

        const SizedBox(height: 14),
        const Text('Phone Number *', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
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

        // Date picker
        const SizedBox(height: 20),
        const Text('Date *', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildDatePicker(),

        // Time picker
        const SizedBox(height: 20),
        const Text('Time Slot *', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildTimeGrid(),

        // Guest count
        const SizedBox(height: 20),
        const Text('Number of Guests *', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildGuestSelector(),

        // Special request
        const SizedBox(height: 20),
        const Text('Special Request (optional)', style: TextStyle(fontSize: 12, color: AC.text2, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        TextField(
          controller: _noteCtrl,
          style: const TextStyle(color: AC.text),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Birthday? Anniversary? Any allergies?',
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: 12),
              child: Icon(Icons.note_outlined, color: AC.text3, size: 20),
            ),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 26),
        PrimaryBtn(
          label: 'Reserve Table',
          icon: Icons.check_circle_outline_rounded,
          loading: _loading,
          onTap: _submit,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    final days = List.generate(14, (i) => now.add(Duration(days: i + 1)));
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final sel = d.day == _selectedDate.day && d.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() { _selectedDate = d; _selectedTime = null; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              decoration: BoxDecoration(
                color: sel ? AC.fire : AC.bg2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: sel ? AC.fire : Colors.white.withOpacity(.06)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayNames[d.weekday - 1], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sel ? Colors.white.withOpacity(.75) : AC.text3)),
                  const SizedBox(height: 3),
                  Text('${d.day}', style: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: sel ? Colors.white : AC.text)),
                  Text(months[d.month - 1], style: TextStyle(fontSize: 9, color: sel ? Colors.white.withOpacity(.75) : AC.text3)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: SampleData.timeSlots.map((t) {
        final sel = t == _selectedTime;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: sel ? AC.fire : AC.bg2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? AC.fire : Colors.white.withOpacity(.06)),
            ),
            child: Text(t,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AC.text2)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuestSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AC.bg2, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        children: [
          const Text('👥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text('$_guests ${_guests == 1 ? "Guest" : "Guests"}',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w700, color: AC.text)),
          ),
          Row(
            children: [
              _GuestBtn(icon: Icons.remove_rounded, onTap: _guests > 1 ? () => setState(() => _guests--) : null),
              const SizedBox(width: 8),
              Text('$_guests', style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w800, color: AC.text)),
              const SizedBox(width: 8),
              _GuestBtn(icon: Icons.add_rounded, onTap: _guests < RC.maxTableSize ? () => setState(() => _guests++) : null),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _fmtTimePretty(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ap';
  }
}

class _GuestBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _GuestBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AC.fire : AC.surface,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 16, color: onTap != null ? Colors.white : AC.text3),
      ),
    );
  }
}


// ─── My Bookings ──────────────────────────────────────────────────────────────
class _MyBookings extends StatelessWidget {
  const _MyBookings();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (_, state, __) {
        final list = state.reservations;
        if (list.isEmpty) {
          return const EmptyState(
            emoji: '🍽️', title: 'No reservations yet',
            sub: 'Book a table for your next visit and we\'ll take care of the rest!',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(14),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ReservationCard(r: list[i], state: state),
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation r;
  final AppState state;
  const _ReservationCard({required this.r, required this.state});

  @override
  Widget build(BuildContext context) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h = r.dateTime.hour % 12 == 0 ? 12 : r.dateTime.hour % 12;
    final m = r.dateTime.minute.toString().padLeft(2, '0');
    final ap = r.dateTime.hour < 12 ? 'AM' : 'PM';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AC.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(11)),
                child: const Center(child: Text('🪑', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking #${r.id}',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w800, color: AC.text)),
                  Text('Table #${r.tableNumber}  •  ${r.guests} guests',
                    style: const TextStyle(fontSize: 11, color: AC.text3)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: r.statusColor.withOpacity(.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(r.statusLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: r.statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AC.bg3, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Expanded(
                  child: _dRow('📅', '${r.dateTime.day} ${months[r.dateTime.month - 1]}'),
                ),
                Expanded(
                  child: _dRow('⏰', '$h:$m $ap'),
                ),
                Expanded(
                  child: _dRow('📞', r.phone),
                ),
              ],
            ),
          ),
          if (r.specialRequest != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.note_outlined, size: 13, color: AC.text3),
                const SizedBox(width: 5),
                Expanded(child: Text(r.specialRequest!, style: const TextStyle(fontSize: 11, color: AC.text3))),
              ],
            ),
          ],
          if (r.status == ReservationStatus.pending || r.status == ReservationStatus.confirmed) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _confirmCancel(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: AC.error.withOpacity(.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text('Cancel Reservation',
                  style: TextStyle(fontSize: 13, color: AC.error, fontWeight: FontWeight.w700))),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dRow(String emoji, String val) => Column(
    children: [
      Text(emoji, style: const TextStyle(fontSize: 14)),
      const SizedBox(height: 3),
      Text(val, style: const TextStyle(fontSize: 11, color: AC.text2, fontWeight: FontWeight.w600)),
    ],
  );

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AC.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Reservation?', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w800, color: AC.text)),
        content: const Text('Are you sure you want to cancel this reservation?', style: TextStyle(color: AC.text2)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep it')),
          TextButton(
            onPressed: () { state.cancelReservation(r.id); Navigator.pop(ctx); },
            child: const Text('Cancel', style: TextStyle(color: AC.error)),
          ),
        ],
      ),
    );
  }
}
