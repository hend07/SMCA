class Doctor {
  String name;
  String role;
  String phone;
  String status;
  String lastUpdate;
  String department;
  
  String date;      
  String day;       
  String coverage; // هذا سيحمل وقت المناوبة (مثلاً: 07:30 AM - 07:30 PM)

  Doctor({
    required this.name,
    required this.role,
    required this.phone,
    required this.status,
    required this.lastUpdate,
    required this.department,
    this.date = "", 
    this.day = "",
    this.coverage = "24 Hours",
  });

  // دالة مساعدة لإنشاء دكتور من سطر CSV
  factory Doctor.fromCsv(List<dynamic> row) {
    return Doctor(
      name: row[0].toString(),
      role: row[1].toString(),
      department: row[2].toString(),
      phone: row[3].toString(),
      status: row[4].toString(),
      lastUpdate: DateTime.now().toString(),
      // نحدد التغطية تلقائياً بناءً على الحالة إذا لم تكن موجودة في الملف
      coverage: _calculateShift(row[4].toString()),
    );
  }

  static String _calculateShift(String status) {
    if (status.contains("Day") || status.contains("Morning")) return "07:30 AM - 07:30 PM";
    if (status.contains("Night") || status.contains("Evening")) return "07:30 PM - 07:30 AM";
    return "07:30 AM - 04:30 PM";
  }
}

class CaseLog {
  String date;
  String code;
  String room;
  String duration;
  int teamCount;
  String vitals;

  CaseLog(this.date, this.code, this.room, this.duration, this.teamCount, this.vitals);
}