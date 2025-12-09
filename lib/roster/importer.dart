// lib/roster_importer.dart
// CSV parser to import roster CSVs (the file you provided).
import 'dart:convert';

class RosterEntry {
  final DateTime date;
  final String day;
  final String department;
  final String doctorName;
  final String role;
  final String phone;
  final String shiftType;
  final bool isWeekend;

  RosterEntry({
    required this.date,
    required this.day,
    required this.department,
    required this.doctorName,
    required this.role,
    required this.phone,
    required this.shiftType,
    required this.isWeekend,
  });

  @override
  String toString() {
    return '${date.toIso8601String().split("T").first} | $department | $doctorName | $role | $phone | $shiftType | weekend:$isWeekend';
  }
}

class RosterImporter {
  static List<RosterEntry> parse(String csvContent) {
    final lines = const LineSplitter().convert(csvContent).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return [];

    final header = _splitCsvLine(lines.first);
    final cols = header.map((c) => c.toLowerCase()).toList();

    int idx(String name) {
      final i = cols.indexWhere((c) => c.contains(name.toLowerCase()));
      return i;
    }

    final dateIdx = idx('date');
    final dayIdx = idx('day');
    final deptIdx = idx('department');
    final nameIdx = idx('doctor_name') >= 0 ? idx('doctor_name') : idx('doctor');
    final roleIdx = idx('role');
    final phoneIdx = idx('phone_number') >= 0 ? idx('phone_number') : idx('phone');
    final shiftIdx = idx('shift');
    final weekendIdx = idx('is_weekend');

    final entries = <RosterEntry>[];

    for (var i = 1; i < lines.length; i++) {
      final row = _splitCsvLine(lines[i]);
      if (row.length <= dateIdx) continue;

      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(row[dateIdx]);
      } catch (e) {
        parsedDate = DateTime.tryParse(row[dateIdx]) ?? DateTime.now();
      }

      final day = (dayIdx >= 0 && dayIdx < row.length) ? row[dayIdx] : '';
      final dept = (deptIdx >= 0 && deptIdx < row.length) ? row[deptIdx] : '';
      final name = (nameIdx >= 0 && nameIdx < row.length) ? row[nameIdx] : '';
      final role = (roleIdx >= 0 && roleIdx < row.length) ? row[roleIdx] : '';
      final phone = (phoneIdx >= 0 && phoneIdx < row.length) ? row[phoneIdx] : '';
      final shift = (shiftIdx >= 0 && shiftIdx < row.length) ? row[shiftIdx] : '';
      final weekendRaw = (weekendIdx >= 0 && weekendIdx < row.length) ? row[weekendIdx] : '';
      final isWeekend = weekendRaw.toLowerCase() == 'yes' || weekendRaw == '1' || weekendRaw.toLowerCase() == 'true';

      entries.add(RosterEntry(
        date: parsedDate,
        day: day,
        department: dept,
        doctorName: name,
        role: role,
        phone: phone,
        shiftType: shift,
        isWeekend: isWeekend,
      ));
    }

    return entries;
  }

  static List<String> _splitCsvLine(String line) {
    final List<String> result = [];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }
}