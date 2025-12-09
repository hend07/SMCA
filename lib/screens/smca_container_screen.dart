import 'package:flutter/material.dart';
import 'roster_screen.dart'; // تأكد من استيراد صفحاتك هنا
import 'logs_screen.dart';

class SmcaContainerScreen extends StatelessWidget {
  const SmcaContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // عدد الصفحات الأربع
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SMCA System"),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true, // اجعلها قابلة للسحب إذا كانت العناوين طويلة
            tabs: [
              Tab(icon: Icon(Icons.people), text: "Roster"),   // صفحة المناوبات
              Tab(icon: Icon(Icons.notifications_active), text: "Alerts"), // صفحة التنبيهات
              Tab(icon: Icon(Icons.history), text: "Logs"),    // صفحة السجلات
              Tab(icon: Icon(Icons.settings), text: "Settings"), // صفحة رابعة (إعدادات مثلاً)
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RosterScreen(),        // صفحة 1: المناوبات
            Center(child: Text("Alerts Screen")), // صفحة 2: استبدلها بصفحة التنبيهات
            LogsScreen(),          // صفحة 3: السجلات
            Center(child: Text("Settings Screen")), // صفحة 4: صفحة إضافية
          ],
        ),
      ),
    );
  }
}