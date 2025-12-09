import 'dart:convert';
import 'dart:html' as html; 
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

import '../data/manager.dart';
import '../models.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> departments = ["ER", "Surgery", "ICU", "Radiology"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: departments.length, vsync: this);
  }

  String _normalizeDeptName(String rawName) {
    String lower = rawName.toLowerCase().trim();
    if (lower.contains("emergency") || lower == "er" || lower.startsWith("er ") || lower.contains("طوارئ")) {
      return "ER";
    }
    if (lower.contains("surgery") || lower.contains("operation") || lower.contains("جراحة")) {
      return "Surgery";
    }
    if (lower.contains("icu") || lower.contains("intensive") || lower.contains("عناية")) {
      return "ICU";
    }
    if (lower.contains("radio") || lower.contains("x-ray") || lower.contains("أشعة")) {
      return "Radiology";
    }
    return rawName; 
  }

  Future<void> _uploadCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['csv', 'txt', 'tsv'], withData: true,
      );

      if (result != null) {
        if (result.files.single.bytes == null) throw "تعذر قراءة بيانات الملف";

        String fileContent;
        try {
          fileContent = utf8.decode(result.files.single.bytes!);
        } catch (e) {
          fileContent = latin1.decode(result.files.single.bytes!);
        }

        String delimiter = ',';
        if (fileContent.contains('\t')) delimiter = '\t';
        else if (fileContent.contains(';')) delimiter = ';';

        List<List<dynamic>> rows = CsvToListConverter(fieldDelimiter: delimiter, shouldParseNumbers: false).convert(fileContent);
        if (rows.isEmpty) throw "الملف فارغ";

        List<String> headers = rows[0].map((e) => e.toString().toLowerCase().trim()).toList();
        
        int nameIdx = headers.indexWhere((h) => h.contains('name'));
        int roleIdx = headers.indexWhere((h) => h.contains('role'));
        int phoneIdx = headers.indexWhere((h) => h.contains('phone'));
        int statusIdx = headers.indexWhere((h) => h.contains('status'));
        int updateIdx = headers.indexWhere((h) => h.contains('lastupdate') || h.contains('update'));
        int deptIdx = headers.indexWhere((h) => h.contains('department') || h.contains('dept'));
        int dateIdx = headers.indexWhere((h) => h.contains('date'));
        int dayIdx = headers.indexWhere((h) => h.contains('day'));
        int covIdx = headers.indexWhere((h) => h.contains('coverage'));

        if (nameIdx == -1) nameIdx = 0;
        if (roleIdx == -1) roleIdx = 1;
        if (phoneIdx == -1) phoneIdx = 2;
        if (statusIdx == -1) statusIdx = 3;
        if (updateIdx == -1) updateIdx = 4;
        if (deptIdx == -1) deptIdx = 5;
        if (dateIdx == -1) dateIdx = 6;
        if (dayIdx == -1) dayIdx = 7;
        if (covIdx == -1) covIdx = 8;

        int count = 0;
        for (var i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.length < 2) continue;
          String getVal(int idx) => (idx >= 0 && idx < row.length) ? row[idx].toString().trim() : "";
          
          String rawName = getVal(nameIdx);
          String rawDept = getVal(deptIdx);

          if (rawName.isNotEmpty) {
             if (rawDept.isEmpty) rawDept = departments[_tabController.index];
             String normalizedDept = _normalizeDeptName(rawDept);
             DataManager.addDoctor(normalizedDept, rawName);

             try {
                var doc = DataManager.doctors.lastWhere((d) => d.name == rawName && d.department == normalizedDept);
                String r = getVal(roleIdx); if(r.isNotEmpty) doc.role = r;
                String p = getVal(phoneIdx); if(p.isNotEmpty) doc.phone = p;
                String s = getVal(statusIdx); if(s.isNotEmpty) doc.status = s;
                String u = getVal(updateIdx); if(u.isNotEmpty) doc.lastUpdate = u;
                String dt = getVal(dateIdx); if(dt.isNotEmpty) doc.date = dt;
                String dy = getVal(dayIdx); if(dy.isNotEmpty) doc.day = dy;
                String c = getVal(covIdx); if(c.isNotEmpty) doc.coverage = c;
             } catch (e) {/*ignore*/}
             count++;
          }
        }
        setState(() {});
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Added $count records"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red));
    }
  }

  void _downloadCSV() {
    try {
      if (DataManager.doctors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No data to export"), backgroundColor: Colors.orange));
        return;
      }
      List<List<dynamic>> rows = [];
      rows.add(["Name", "Role", "Phone", "Status", "Last Update", "Department", "Date", "Day", "Coverage"]);
      for (var doc in DataManager.doctors) {
        rows.add([doc.name, doc.role, doc.phone, doc.status, doc.lastUpdate, doc.department, doc.date, doc.day, doc.coverage]);
      }
      String csvData = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode('\uFEFF$csvData'); 
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "Roster_Export.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Roster downloaded successfully"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Export Error: $e"), backgroundColor: Colors.red));
    }
  }

  void _showManualAddDialog() {
    final _formKey = GlobalKey<FormState>();
    String selectedDept = departments[_tabController.index];
    TextEditingController nameCtrl = TextEditingController();
    TextEditingController roleCtrl = TextEditingController();
    TextEditingController phoneCtrl = TextEditingController();
    TextEditingController statusCtrl = TextEditingController(text: "On Duty");
    TextEditingController dateCtrl = TextEditingController();
    TextEditingController dayCtrl = TextEditingController();
    TextEditingController covCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Doctor/Staff"),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDept,
                  items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => selectedDept = val!,
                  decoration: const InputDecoration(labelText: "Department", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name *", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                // ✅ تعديل هنا: خيارات جاهزة للوقت
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Shift Coverage", border: OutlineInputBorder()),
                  hint: const Text("Select Time Range"),
                  items: const [
                    DropdownMenuItem(value: "07:30 AM - 07:30 PM", child: Text("Day (7:30 AM - 7:30 PM)")),
                    DropdownMenuItem(value: "07:30 PM - 07:30 AM", child: Text("Night (7:30 PM - 7:30 AM)")),
                    DropdownMenuItem(value: "08:00 AM - 04:00 PM", child: Text("Morning (8:00 AM - 4:00 PM)")),
                    DropdownMenuItem(value: "Custom", child: Text("Custom Time...")),
                  ],
                  onChanged: (val) {
                    if (val != "Custom") covCtrl.text = val!;
                    else covCtrl.clear();
                  },
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: covCtrl, 
                  decoration: const InputDecoration(labelText: "Time Range (Text)", hintText: "e.g. 09:00 AM - 05:00 PM", border: OutlineInputBorder())
                ),
                const SizedBox(height: 10),
                TextFormField(controller: roleCtrl, decoration: const InputDecoration(labelText: "Role", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                TextFormField(controller: statusCtrl, decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: dateCtrl, decoration: const InputDecoration(labelText: "Date", border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextFormField(controller: dayCtrl, decoration: const InputDecoration(labelText: "Day", border: OutlineInputBorder())),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  DataManager.addDoctor(selectedDept, nameCtrl.text);
                  try {
                    var doc = DataManager.doctors.lastWhere((d) => d.name == nameCtrl.text && d.department == selectedDept);
                    doc.role = roleCtrl.text;
                    doc.phone = phoneCtrl.text;
                    doc.status = statusCtrl.text;
                    doc.date = dateCtrl.text;
                    doc.day = dayCtrl.text;
                    doc.coverage = covCtrl.text; // سيأخذ النص المكتوب (07:30 AM - ...)
                    doc.lastUpdate = DateTime.now().toString().split(' ')[0];
                  } catch (e) {
                     print("Error updating new doc: $e");
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Added successfully"), backgroundColor: Colors.green));
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // ✏️ تعديل الخلية
  void _editCell(Doctor doc, String fieldName, String currentValue) {
    TextEditingController ctrl = TextEditingController(text: currentValue);
    showDialog(context: context, builder: (c) => AlertDialog(
      title: Text("Edit $fieldName"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ إضافة أزرار مساعدة للوقت
          if (fieldName == 'Coverage') ...[
             Wrap(
               spacing: 5,
               children: [
                 ActionChip(label: const Text("Day"), onPressed: () => ctrl.text = "07:30 AM - 07:30 PM"),
                 ActionChip(label: const Text("Night"), onPressed: () => ctrl.text = "07:30 PM - 07:30 AM"),
                 ActionChip(label: const Text("Office"), onPressed: () => ctrl.text = "08:00 AM - 04:00 PM"),
               ],
             ),
             const SizedBox(height: 10),
          ],
          TextField(
            controller: ctrl, 
            autofocus: true,
            decoration: InputDecoration(border: const OutlineInputBorder(), hintText: "Enter new $fieldName"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
        ElevatedButton(onPressed: () {
          setState(() {
            if (fieldName == 'Name') doc.name = ctrl.text;
            if (fieldName == 'Role') doc.role = ctrl.text;
            if (fieldName == 'Phone') doc.phone = ctrl.text;
            if (fieldName == 'Coverage') doc.coverage = ctrl.text;
            if (fieldName == 'Date') doc.date = ctrl.text;
            if (fieldName == 'Day') doc.day = ctrl.text;
            if (fieldName == 'Status') doc.status = ctrl.text;
          });
          Navigator.pop(c);
        }, child: const Text("Save"))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hospital Roster System"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _uploadCSV, tooltip: "Import CSV"),
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadCSV, tooltip: "Export CSV"),
        ],
        bottom: TabBar(controller: _tabController, tabs: departments.map((d) => Tab(text: d.toUpperCase())).toList()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showManualAddDialog,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        tooltip: "Add Manual Entry",
      ),
      body: TabBarView(
        controller: _tabController,
        children: departments.map((dept) => _buildDeptSheet(dept)).toList(),
      ),
    );
  }

  Widget _buildDeptSheet(String dept) {
    List<Doctor> docs = DataManager.getByDept(dept);
    if (docs.isEmpty) return Center(child: Text("No doctors in $dept", style: const TextStyle(color: Colors.grey)));

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Phone')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Last Update')),
            DataColumn(label: Text('Dept')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Day')),
            DataColumn(label: Text('Coverage (Time)')), // ✅ تعديل الاسم هنا
          ],
          rows: docs.map((doc) => DataRow(cells: [
            DataCell(Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)), onTap: () => _editCell(doc, 'Name', doc.name)),
            DataCell(Text(doc.role), onTap: () => _editCell(doc, 'Role', doc.role)),
            DataCell(Text(doc.phone), onTap: () => _editCell(doc, 'Phone', doc.phone)),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: doc.status.toLowerCase().contains('on') ? Colors.green.shade50 : Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(doc.status, style: TextStyle(color: doc.status.toLowerCase().contains('on') ? Colors.green : Colors.black)),
              ),
              onTap: () => _editCell(doc, 'Status', doc.status)
            ),
            DataCell(Text(doc.lastUpdate)), 
            DataCell(Text(doc.department)),
            DataCell(Text(doc.date), onTap: () => _editCell(doc, 'Date', doc.date)),
            DataCell(Text(doc.day), onTap: () => _editCell(doc, 'Day', doc.day)),
            DataCell(Text(doc.coverage), onTap: () => _editCell(doc, 'Coverage', doc.coverage)),
          ])).toList(),
        ),
      ),
    );
  }
}