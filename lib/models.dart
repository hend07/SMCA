class Doctor {
  String name;
  String role;
  String phone;
  String status;
  String lastUpdate;
  String department;
  
  String date;      
  String day;       
  String coverage;  

  Doctor({
    required this.name,
    required this.role,
    required this.phone,
    required this.status,
    required this.lastUpdate,
    required this.department,
    // القيم الافتراضية للحقول الجديدة
    this.date = "", 
    this.day = "",
    this.coverage = "24 Hours",
  });
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