import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/emergency_screen.dart';
import 'screens/roster_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'screens/logs_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found: $e");
  }
  await initializeDateFormatting(); 
  runApp(const SmartAlertApp());
}

class SmartAlertApp extends StatelessWidget {
  const SmartAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMCA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00BFA5)), // لون التيل
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      // تفعيل الاتجاه من اليمين لليسار
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
      home: const AnatSimulationScreen(),
    );
  }
}

// 📱 1. شاشة محاكاة تطبيق "أناة" (بتصميم كامل)
class AnatSimulationScreen extends StatefulWidget {
  const AnatSimulationScreen({super.key});

  @override
  State<AnatSimulationScreen> createState() => _AnatSimulationScreenState();
}

class _AnatSimulationScreenState extends State<AnatSimulationScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية رمادية فاتحة
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("أناة", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(width: 5),
            Icon(Icons.check_circle_outline, color: Colors.teal[300])
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.teal),
        actions: const [Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.notifications_none, color: Colors.teal))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1️⃣ بطاقة الساعات (الدائرة)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 80, width: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: 0.7, strokeWidth: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
                        ),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("211", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            Text("أيام", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("عدد الساعات التعليمية المستحقة", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const Text("49 من أصل 60 ساعة", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        const Text("تاريخ انتهاء الرخصة 2026-07-08", style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), minimumSize: const Size(80, 30)),
                            child: const Text("عرض التفاصيل", style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2️⃣ البانر الإعلاني
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/600x300"), // استبدل الرابط بصورتك
                  fit: BoxFit.cover,
                  opacity: 0.7
                )
              ),
              alignment: Alignment.center,
              child: const Text("لقاح الإنفلونزا الموسمية", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 10),

            // 3️⃣ نقاط المؤشر
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == 2 ? 8 : 6, height: index == 2 ? 8 : 6,
                decoration: BoxDecoration(color: index == 2 ? const Color(0xFF00BFA5) : Colors.grey.shade300, shape: BoxShape.circle),
              )),
            ),

            const SizedBox(height: 20),

            // 4️⃣ المربعات الصغيرة (إجازات / وصفات) - 🛑 هذا الجزء كان ناقصاً
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.medication, color: Colors.blue), Text("4", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                         Text("الوصفات الطبية\nالمصدرة", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00BFA5))),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Icon(Icons.access_time_filled, color: Colors.orange), Text("2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
                         Text("إجازات بانتظار\nالموافقة", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5️⃣ قسم بطاقاتي - 🛑 هذا الجزء كان ناقصاً
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("بطاقاتي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: (){}, child: const Text("عرض الكل >", style: TextStyle(color: Color(0xFF1565C0)))),
              ],
            ),
            
            // بطاقة رقمية وهمية
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF37474F), Color(0xFF455A64)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("د. سارة الأحمد", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("طبيب مقيم", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
      
      // الشريط السفلي
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const SMCAMainScreen()));
          }
        },
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'الخدمات'),
          
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00BFA5), width: 1.5)
              ),
              child: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF00BFA5)),
            ),
            label: 'SMCA',
          ),

          const BottomNavigationBarItem(icon: Icon(Icons.stars), label: 'نفيس'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'الملف'),
        ],
      ),
    );
  }
}

// 🏥 2. الشاشة الرئيسية لتطبيقك (SMCA)
class SMCAMainScreen extends StatefulWidget {
  const SMCAMainScreen({super.key});

  @override
  State<SMCAMainScreen> createState() => _SMCAMainScreenState();
}

class _SMCAMainScreenState extends State<SMCAMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    EmergencyScreen(),
    RosterScreen(),
    AIChatScreen(),
    LogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMCA System"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_hospital_outlined), selectedIcon: Icon(Icons.local_hospital), label: 'Emergency'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Roster'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'Logs'),
        ],
      ),
    );
  }
}