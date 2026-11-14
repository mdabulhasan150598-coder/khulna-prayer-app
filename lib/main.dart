import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

void main() {
  runApp(const PrayerApp());
}

class PrayerApp extends StatelessWidget {
  const PrayerApp({super.key});

  static const Color primary = Color(0xFF075B43);
  static const Color deepGreen = Color(0xFF064532);
  static const Color pageBg = Color(0xFFF4F7F5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'খুলনা নামাজ ও রোজা',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: pageBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const PrayerHomePage(),
    );
  }
}

class PrayerHomePage extends StatefulWidget {
  const PrayerHomePage({super.key});

  @override
  State<PrayerHomePage> createState() => _PrayerHomePageState();
}

class _PrayerHomePageState extends State<PrayerHomePage> {
  // অ্যাপটি আপাতত খুলনা জেলার জন্য নির্ধারিত।
  static const double khulnaLat = 22.8456;
  static const double khulnaLng = 89.5403;

  static const List<String> banglaMonths = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
    'মে', 'জুন', 'জুলাই', 'আগস্ট',
    'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  static const List<String> banglaDays = [
    'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার',
    'শুক্রবার', 'শনিবার', 'রবিবার',
  ];

  DateTime selectedDate = DateTime.now();

  String toBn(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (var i = 0; i < en.length; i++) {
      input = input.replaceAll(en[i], bn[i]);
    }
    return input;
  }

  String formatDate(DateTime date) {
    final dayName = banglaDays[date.weekday - 1];
    final monthName = banglaMonths[date.month - 1];
    return '$dayName, ${toBn(date.day.toString())} $monthName ${toBn(date.year.toString())}';
  }

  String formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour < 12 ? 'সকাল' : 'বিকেল';
    final adjustedSuffix = time.hour >= 17 ? 'সন্ধ্যা' : suffix;
    return '${toBn(hour.toString().padLeft(2, '0'))}:${toBn(minute)} $adjustedSuffix';
  }

  bool get isSelectedDateToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = Coordinates(khulnaLat, khulnaLng);
    final params = CalculationMethod.karachi.getParameters()
      ..madhab = Madhab.hanafi;
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(selectedDate),
      params,
    );

    final sehriEnd = prayerTimes.fajr.subtract(const Duration(minutes: 3));
    final prayerItems = <Map<String, dynamic>>[
      {'name': 'ফজর', 'time': prayerTimes.fajr, 'icon': Icons.nightlight_round},
      {'name': 'জোহর', 'time': prayerTimes.dhuhr, 'icon': Icons.wb_sunny_outlined},
      {'name': 'আসর', 'time': prayerTimes.asr, 'icon': Icons.wb_twilight},
      {'name': 'মাগরিব', 'time': prayerTimes.maghrib, 'icon': Icons.wb_twilight},
      {'name': 'এশা', 'time': prayerTimes.isha, 'icon': Icons.nights_stay_outlined},
    ];

    var nextPrayerIndex = -1;
    if (isSelectedDateToday) {
      final now = DateTime.now();
      nextPrayerIndex = prayerItems.indexWhere(
        (item) => now.isBefore(item['time'] as DateTime),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'খুলনা নামাজ ও রোজা',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(
              'খুলনা জেলা',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'আজকের তারিখ',
            onPressed: () => setState(() => selectedDate = DateTime.now()),
            icon: const Icon(Icons.today_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildRamadanTimes(sehriEnd, prayerTimes.maghrib),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'আজকের নামাজের সময়',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PrayerApp.deepGreen,
                    ),
                  ),
                ),
                if (isSelectedDateToday && nextPrayerIndex >= 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F2E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'পরবর্তী ওয়াক্ত',
                      style: TextStyle(
                        color: PrayerApp.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 1,
              shadowColor: Colors.black12,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < prayerItems.length; i++) ...[
                    _buildPrayerTile(
                      name: prayerItems[i]['name'] as String,
                      time: prayerItems[i]['time'] as DateTime,
                      icon: prayerItems[i]['icon'] as IconData,
                      isNext: i == nextPrayerIndex,
                    ),
                    if (i != prayerItems.length - 1)
                      const Divider(height: 1, indent: 58, endIndent: 16),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSunriseTile(prayerTimes.sunrise),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1ED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: PrayerApp.primary, size: 19),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'সময় গণনা: Karachi পদ্ধতি • আসর: হানাফি। এটি খুলনা শহরের স্থানাঙ্কভিত্তিক আনুমানিক সময়; জেলার বিভিন্ন এলাকায় ও স্থানীয় মসজিদের সময়ে পার্থক্য হতে পারে। রমজানে ইসলামিক ফাউন্ডেশনের খুলনা জেলার প্রকাশিত সেহরি-ইফতারের সময়সূচি অগ্রাধিকার দিন।',
                      style: TextStyle(
                        color: Color(0xFF496257),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'আল্লাহ আমাদের নামাজ ও রোজা কবুল করুন',
                style: TextStyle(
                  color: Color(0xFF718078),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'আগের দিন',
            onPressed: () => changeDate(-1),
            icon: const Icon(Icons.chevron_left_rounded),
            color: PrayerApp.primary,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  formatDate(selectedDate),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: PrayerApp.deepGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isSelectedDateToday ? 'আজকের সময়সূচি' : 'তারিখ অনুযায়ী সময়সূচি',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'পরের দিন',
            onPressed: () => changeDate(1),
            icon: const Icon(Icons.chevron_right_rounded),
            color: PrayerApp.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRamadanTimes(DateTime sehriEnd, DateTime iftar) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PrayerApp.primary, PrayerApp.deepGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x26075B43), blurRadius: 15, offset: Offset(0, 7)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 17, 16, 18),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.nights_stay_outlined, color: Colors.white70, size: 17),
                SizedBox(width: 7),
                Text(
                  'আনুমানিক সেহরি ও ইফতারের সময়',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildTimeInfo(
                    title: 'সেহরি শেষ',
                    time: formatTime(sehriEnd),
                    icon: Icons.dark_mode_outlined,
                  ),
                ),
                Container(width: 1, height: 62, color: Colors.white30),
                Expanded(
                  child: _buildTimeInfo(
                    title: 'ইফতার',
                    time: formatTime(iftar),
                    icon: Icons.restaurant_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'সেহরি শেষের সময় ফজরের ৩ মিনিট আগে ধরে গণনা করা হয়েছে',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required String title,
    required String time,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 21),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTile({
    required String name,
    required DateTime time,
    required IconData icon,
    required bool isNext,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFFEAF5EE) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isNext ? const Color(0xFFD4EBDD) : const Color(0xFFF0F4F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: PrayerApp.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: PrayerApp.deepGreen,
                    fontSize: 15,
                    fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                if (isNext)
                  const Text(
                    'পরবর্তী ওয়াক্ত',
                    style: TextStyle(
                      color: PrayerApp.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            formatTime(time),
            style: TextStyle(
              color: isNext ? PrayerApp.primary : const Color(0xFF34483E),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseTile(DateTime sunrise) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5DF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF2E4C4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Color(0xFFB7791F), size: 21),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'সূর্যোদয়',
              style: TextStyle(
                color: Color(0xFF79551D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            formatTime(sunrise),
            style: const TextStyle(
              color: Color(0xFF79551D),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
