import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'smca_container_screen.dart'; 

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AnatHomeLayout(),          
    const Center(child: Text("الخدمات")),
    const SmcaContainerScreen(),     
    const Center(child: Text("نفيس")),
    const Center(child: Text("الملف الشخصي")),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9), 
        body: _pages[_currentIndex],
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 10),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "الرئيسية"),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "الخدمات"),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 2 ? const Color(0xFF00BFA5).withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
                border: _currentIndex == 2 ? Border.all(color: const Color(0xFF00BFA5)) : null,
              ),
              child: Icon(Icons.monitor_heart_outlined, color: _currentIndex == 2 ? const Color(0xFF00BFA5) : Colors.grey),
            ),
            label: "SMCA",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: "نفيس"),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "ملفي"),
        ],
      ),
    );
  }
}

class AnatHomeLayout extends StatelessWidget {
  const AnatHomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // 1️⃣ بطاقة الساعات
            _buildHoursCard(),

            const SizedBox(height: 20),

            // 2️⃣ البانر (لقاء...)
            _buildBanner(),

            const SizedBox(height: 12),

            // 3️⃣ نقاط المؤشر (6 نقاط) ✅ تم التعديل
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == 0 ? 8 : 6, // النقطة النشطة أكبر قليلاً
                  height: index == 0 ? 8 : 6,
                  decoration: BoxDecoration(
                    color: index == 0 ? const Color(0xFF00BFA5) : Colors.grey.shade300, // أخضر للنشطة، رمادي للباقي
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // 4️⃣ المربعين (الخدمات السريعة) ✅ تم التعديل للأرقام 4 و 2
            Row(
              children: [
                Expanded(
                  child: _quickServiceCard(
                    title: "الوصفات الطبية\nالمصدرة", 
                    count: "4", // ✅ الرقم 4
                    icon: Icons.medication_outlined,
                    iconColor: Colors.blue
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _quickServiceCard(
                    title: "إجازات بانتظار\nالموافقة", 
                    count: "2", // ✅ الرقم 2
                    icon: Icons.access_time_filled, 
                    iconColor: Colors.orange
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5️⃣ عنوان بطاقاتي مع زر "عرض الكل" الأزرق ✅ تم التعديل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("بطاقاتي", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                
                // زر عرض الكل > باللون الأزرق
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text("عرض الكل", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1565C0))),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF1565C0)), // سهم صغير
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // البطاقة الرقمية
            _buildDigitalCard(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Widgets ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("مرحباً بك،", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
          Text("د. سارة الأحمد", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: const Icon(Icons.notifications_none, color: Colors.black54),
        )
      ],
    );
  }

  Widget _buildHoursCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 80, width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
                ),
                Text("211", style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ساعات التعليم الطبي", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("49", style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(" / 60 ساعة", style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("عرض التفاصيل >", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF263238), // خلفية داكنة للبانر
      ),
      child: Stack(
        children: [
          // هنا يمكنك وضع صورة خلفية
           ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              "https://via.placeholder.com/600x300/00695C/FFFFFF?text=Conference", // صورة مؤقتة
              width: double.infinity, height: double.infinity, fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                  child: Text("إعلان", style: GoogleFonts.cairo(color: Colors.white, fontSize: 10)),
                ),
                const SizedBox(height: 4),
                Text("لقاء الصحة الرقمية", style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickServiceCard({required String title, required String count, required IconData icon, required Color iconColor}) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor.withOpacity(0.8), size: 24),
              // الرقم بخط كبير وواضح
              Text(count, style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          Text(title, style: GoogleFonts.cairo(fontSize: 11, height: 1.2, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDigitalCard() {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF263238), Color(0xFF455A64)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.qr_code_2, color: Colors.white, size: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text("نشط", style: GoogleFonts.cairo(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const Spacer(),
          Text("د. سارة الأحمد", style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text("طبيب مقيم - جراحة عامة", style: GoogleFonts.cairo(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}