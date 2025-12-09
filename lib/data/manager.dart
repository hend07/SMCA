import 'package:intl/intl.dart';
import '../models.dart';

class DataManager {
  // ✅ تصحيح الخطأ: جعل الدوال عامة (بدون _)
  static String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());
  static String get todayDay => DateFormat('EEEE').format(DateTime.now());
  static String now() => DateFormat('HH:mm').format(DateTime.now());

  // البيانات
  static List<Doctor> doctors = [
    Doctor(name: "Dr. Ahmed", role: "Consultant", phone: "0590123456", status: "On Call", lastUpdate: "07:00", department: "ER", date: todayDate, day: todayDay, coverage: "12h"),
    Doctor(name: "Dr. Khalid", role: "Specialist", phone: "0500000000", status: "On Call", lastUpdate: "08:00", department: "Surgery", date: todayDate, day: todayDay, coverage: "24h"),
    Doctor(name: "Dr. Sara", role: "Resident", phone: "0555555555", status: "On Call", lastUpdate: "07:30", department: "ICU", date: todayDate, day: todayDay, coverage: "24h"),
    Doctor(name: "Dr. Nada", role: "Tech", phone: "0544444444", status: "On Call", lastUpdate: "08:15", department: "Radiology", date: todayDate, day: todayDay, coverage: "12h"),
  ];

  static List<CaseLog> logs = [];

  // دالة الإضافة
  static void addDoctor(String dept, String doctorName) {
    bool exists = doctors.any((d) => d.department.toLowerCase() == dept.toLowerCase() && d.name.toLowerCase() == doctorName.toLowerCase());
    if (!exists) {
      doctors.add(Doctor(
        name: doctorName, role: "AI Added", phone: "Unknown", status: "On Call", lastUpdate: now(), department: dept,
        date: todayDate, day: todayDay, coverage: "12h"
      ));
    }
  }

  // استبدال الطبيب المناوب في قسم معين أو إضافته إذا لم يكن القسم موجوداً
  static void replaceDoctorInDept(String dept, String doctorName) {
    final idx = doctors.indexWhere((d) => d.department.toLowerCase() == dept.toLowerCase());

    if (idx != -1) {
      final current = doctors[idx];
      doctors[idx] = Doctor(
        name: doctorName,
        role: current.role,
        phone: current.phone,
        status: "On Call",
        lastUpdate: now(),
        department: current.department,
        date: todayDate,
        day: todayDay,
        coverage: current.coverage,
      );
    } else {
      addDoctor(dept, doctorName);
    }
  }

  // دالة لتصفية الأطباء حسب القسم
  static List<Doctor> getByDept(String dept) {
    return doctors.where((d) => d.department.toLowerCase() == dept.toLowerCase()).toList();
  }
}