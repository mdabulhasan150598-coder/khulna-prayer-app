import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const PrayerApp());
}

class PrayerApp extends StatelessWidget {
  const PrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'খুলনা নামাজ ও রোজা',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D5C3A)),
        useMaterial3: true,
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
  // খুলনা জেলার ভৌগোলিক স্থানাঙ্ক (Latitude & Longitude)
  final double khulnaLat = 22.8456;
  final double khulnaLng = 89.5403;

  DateTime selectedDate = DateTime.now();

  // ইংরেজি সংখ্যাকে বাংলায় রূপান্তর
  String toBn(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(en[i], bn[i]);
    }
    return input;
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    // ১২ ঘণ্টার ফরম্যাট (যেমন: 05:15 AM)
    String formatted = DateFormat('hh:mm a').format(time);
    return toBn(formatted);
  }

  @override
  Widget build(BuildContext context) {
    // করাচি মেথড এবং হানাফি আসর হিসাব
    final myCoordinates = Coordinates(khulnaLat, khulnaLng);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    final dateComponents = DateComponents.from(selectedDate);
    final prayerTimes = PrayerTimes(myCoordinates, dateComponents, params);

    // সেহরি সতর্কতা: ফজর শুরু হওয়ার ৩ মিনিট আগে সেহরি শেষ ধরা নিরাপদ
    final sehriEnd = prayerTimes.fajr.subtract(const Duration(minutes: 3));

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F8),
      appBar: AppBar(
        title: const Text(
          'খুলনা - নামাজ ও রোজা',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D5C3A),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // তারিখ ও নেভিগেশন বার
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFE8F5E9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: () {
                      setState(() {
                        selectedDate = selectedDate.subtract(const Duration(days: 1));
                      });
                    },
                  ),
                  Text(
                    toBn(DateFormat('dd MMMM, yyyy').format(selectedDate)),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () {
                      setState(() {
                        selectedDate = selectedDate.add(const Duration(days: 1));
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // সেহরি ও ইফতার কার্ড
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: const Color(0xFFFFF9C4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('সেহরি শেষ (সতর্কতা)', style: TextStyle(color: Colors.brown, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              formatTime(sehriEnd),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.amber),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('ইফতার (মাগরিব)', style: TextStyle(color: Colors.brown, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              formatTime(prayerTimes.maghrib),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // নামাজের সময়সূচি লিস্ট
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildPrayerTile('ফজর (শুরু)', prayerTimes.fajr),
                    const Divider(height: 1),
                    _buildPrayerTile('সূর্যোদয়', prayerTimes.sunrise),
                    const Divider(height: 1),
                    _buildPrayerTile('জোহর', prayerTimes.dhuhr),
                    const Divider(height: 1),
                    _buildPrayerTile('আসর (হানাফি)', prayerTimes.asr),
                    const Divider(height: 1),
                    _buildPrayerTile('মাগরিব', prayerTimes.maghrib),
                    const Divider(height: 1),
                    _buildPrayerTile('এশা', prayerTimes.isha),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'হিসাব মান: করাচি মেথড ও ইসলামিক ফাউন্ডেশন বাংলাদেশ',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTile(String title, DateTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(
            formatTime(time),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D5C3A)),
          ),
        ],
      ),
    );
  }
}