import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;

import '../models.dart';
import '../data/manager.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  bool isActive = false;
  String selectedCode = ""; 
  final TextEditingController roomController = TextEditingController();
  final TextEditingController hrController = TextEditingController();
  final TextEditingController bpController = TextEditingController();

  DateTime? startTime;
  Timer? timer;
  String elapsedTime = "00:00";
  List<Doctor> responders = [];

  final Map<String, Color> _codeColors = {
    "Trauma Code": Colors.orange.shade800,
    "Code Blue": Colors.blue.shade800,
    "STEMI Code": Colors.red.shade800,
    "Stroke Code": Colors.purple.shade800,
  };

  final Map<String, IconData> _codeIcons = {
    "Trauma Code": Icons.personal_injury,
    "Code Blue": Icons.monitor_heart,
    "STEMI Code": Icons.favorite,
    "Stroke Code": Icons.psychology,
  };

  final Map<String, List<String>> _checklistsData = {
    "Trauma Code": [
      "Primary Survey (ABCDE)",
      "Secure Airway & C-Spine",
      "IV Access (2 Large Bore)",
      "FAST Scan / E-FAST",
      "Control Hemorrhage"
    ],
    "Code Blue": [
      "Check Responsiveness",
      "Start CPR / Chest Compressions",
      "Attach Defibrillator/Monitor",
      "Manage Airway / Ventilate",
      "IV/IO Access & Meds"
    ],
    "STEMI Code": [
      "ECG within 10 mins",
      "Aspirin Administered",
      "Activate Cath Lab",
      "Pain Management",
      "Oxygen if SpO2 < 90%"
    ],
    "Stroke Code": [
      "Last Known Well Time",
      "Check Blood Glucose",
      "NIHSS Assessment",
      "CT Brain Ordered",
      "Neurology Consult"
    ]
  };

  Map<String, bool> _currentChecklistState = {};
  Doctor? _selectedAdHocDoctor;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    timer?.cancel();
    roomController.dispose();
    hrController.dispose();
    bpController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // ✅ دالة إرسال SMS الجماعية
  Future<void> sendAutoSMS(List<Doctor> docs) async {
    if (docs.isEmpty) return;
    
    List<String> phones = docs.where((d) => d.phone.isNotEmpty).map((d) => d.phone.trim()).toList();
    if (phones.isEmpty) return;

=======
  // ✅ دالة إرسال SMS الجماعية (المعدلة)
  Future<void> sendAutoSMS(List<Doctor> docs) async {
    if (docs.isEmpty) return;
    
    // 1. تصفية الأرقام الفارغة وتنظيفها
    List<String> phones = docs
        .where((d) => d.phone.isNotEmpty)
        .map((d) => d.phone.trim())
        .toList();
        
    if (phones.isEmpty) return;

    // نص الرسالة
>>>>>>> fb0fa17dee6424252fb5f02226272d8d0efc1ce8
    String message = "🚨 Code: $selectedCode\nLocation: ${roomController.text}\nURGENT RESPONSE REQUIRED!";
    String encodedMessage = Uri.encodeComponent(message);

    try {
<<<<<<< HEAD
      String separator = (Theme.of(context).platform == TargetPlatform.android) ? ',' : '&'; 
      String recipients = phones.join(separator);
=======
      // 2. محاولة 1: إرسال جماعي (يعمل غالباً على أندرويد)
      // الفاصل يعتمد على النظام، سنحاول استخدام الفاصلة لأنها الأكثر شيوعاً في الموبايل
      String separator = (Theme.of(context).platform == TargetPlatform.android) ? ',' : '&'; 
      String recipients = phones.join(separator);
      
>>>>>>> fb0fa17dee6424252fb5f02226272d8d0efc1ce8
      final Uri smsUri = Uri.parse('sms:$recipients?body=$encodedMessage');
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch group SMS';
      }
    } catch (e) {
<<<<<<< HEAD
=======
      // 3. محاولة 2: إذا فشل الجماعي، نعرض قائمة للمستخدم ليختار إرسال فردي
>>>>>>> fb0fa17dee6424252fb5f02226272d8d0efc1ce8
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("⚠️ Group SMS Failed"),
            content: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
<<<<<<< HEAD
                  const Text("Tap below to notify team manually:"),
=======
                  const Text("System restricted auto-group SMS. Please notify team manually:"),
>>>>>>> fb0fa17dee6424252fb5f02226272d8d0efc1ce8
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.message, color: Colors.blue),
                          title: Text(docs[index].name),
<<<<<<< HEAD
=======
                          subtitle: Text(docs[index].phone),
>>>>>>> fb0fa17dee6424252fb5f02226272d8d0efc1ce8
                          onTap: () async {
                             final Uri singleSms = Uri.parse('sms:${docs[index].phone}?body=$encodedMessage');
                             if (await canLaunchUrl(singleSms)) await launchUrl(singleSms);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
          ),
        );
      }
    }
  }

  Future<void> makeCall(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) await launchUrl(callUri);
  }

  // 🔥🔥🔥 دالة البدء المعدلة (المنطق الجديد للوقت) 🔥🔥🔥
  void startEmergency(String codeType) {
    if (roomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("⚠️ Please specify location first"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      selectedCode = codeType;
      isActive = true;
      startTime = DateTime.now();

      // 1. تحديد الأقسام المستهدفة
      List<String> targetDepts = [];
      switch (selectedCode) {
        case "Trauma Code": targetDepts = ["Surgery", "Orthopedics", "ICU", "ER", "Radiology"]; break;
        case "Code Blue": targetDepts = ["Cardiology", "Internal Med", "ICU", "ER"]; break;
        case "STEMI Code": targetDepts = ["Cardiology", "ER", "Internal Med", "ICU"]; break;
        case "Stroke Code": targetDepts = ["Neurology", "Radiology", "Internal Med", "ICU"]; break;
        default: targetDepts = ["ER"];
      }

      final now = DateTime.now();
      final String todayDateStr = intl.DateFormat('yyyy-MM-dd').format(now);
      // فورمات لتحليل الوقت مثل "07:30 PM"
      final timeFormat = intl.DateFormat("hh:mm a"); 

      // 2. فلترة الأطباء
      responders = DataManager.doctors.where((d) {
        // أ. القسم + الحالة (Off مستبعد)
        if (!targetDepts.contains(d.department)) return false;
        if (d.status.toLowerCase().contains("off")) return false;

        // ب. مطابقة التاريخ (إذا كان الحقل ممتلئاً)
        if (d.date.isNotEmpty && d.date != todayDateStr) return false;

        // ج. مطابقة نطاق الوقت (Coverage Range)
        // نتوقع الصيغة: "07:30 AM - 07:30 PM"
        if (d.coverage.isEmpty || !d.coverage.contains("-")) return false;

        try {
          final parts = d.coverage.split('-');
          if (parts.length != 2) return false;

          String startStr = parts[0].trim(); // "07:30 AM"
          String endStr = parts[1].trim();   // "07:30 PM"

          // تحويل النصوص إلى DateTime لليوم الحالي
          DateTime tStart = timeFormat.parse(startStr);
          DateTime tEnd = timeFormat.parse(endStr);

          // تركيب الوقت على تاريخ اليوم الحالي
          DateTime startShift = DateTime(now.year, now.month, now.day, tStart.hour, tStart.minute);
          DateTime endShift = DateTime(now.year, now.month, now.day, tEnd.hour, tEnd.minute);

          // التعامل مع المناوبات الليلية (عندما يكون الانتهاء قبل البدء، مثل 7م إلى 7ص)
          if (endShift.isBefore(startShift)) {
            // المناوبة تعبر منتصف الليل
            // نكون ضمن المناوبة إذا كان الوقت الحالي بعد البداية OR قبل النهاية
            if (now.isAfter(startShift) || now.isBefore(endShift)) {
              return true;
            }
            return false;
          } else {
            // المناوبة النهارية العادية (في نفس اليوم)
            // نكون ضمن المناوبة إذا كان الوقت الحالي بين البداية والنهاية
            return now.isAfter(startShift) && now.isBefore(endShift);
          }
        } catch (e) {
          debugPrint("Error parsing coverage time for ${d.name}: $e");
          return false; // إذا كان التنسيق خطأ لا نستدعيه
        }
      }).toList();

      // إعادة تهيئة قوائم التحقق
      _currentChecklistState.clear();
      for (var item in _checklistsData[selectedCode] ?? []) {
        _currentChecklistState[item] = false;
      }
    });

    // تشغيل المؤقت
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = now.difference(startTime!);
      setState(() {
        elapsedTime = "${diff.inMinutes.toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}";
      });
    });

    // استدعاء دالة الإرسال الجماعي المعدلة
    sendAutoSMS(responders);
  }

  void stopEmergency() {
    String recordedVitals = "---";
    if (hrController.text.isNotEmpty || bpController.text.isNotEmpty) {
      recordedVitals = "HR: ${hrController.text} bpm | BP: ${bpController.text}";
    }

    DataManager.logs.add(CaseLog(
      intl.DateFormat('yyyy-MM-dd').format(DateTime.now()),
      selectedCode,
      roomController.text,
      elapsedTime,
      responders.length,
      recordedVitals,
    ));

    timer?.cancel();
    setState(() {
      isActive = false;
      elapsedTime = "00:00";
      roomController.clear();
      hrController.clear();
      bpController.clear();
      _currentChecklistState.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Code ended & Log saved")));
  }

  Widget _buildCodeButton(String codeTitle) {
    return Expanded(
      child: InkWell(
        onTap: () => startEmergency(codeTitle),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _codeColors[codeTitle]!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _codeColors[codeTitle]!, width: 2),
            boxShadow: [
              BoxShadow(
                color: _codeColors[codeTitle]!.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_codeIcons[codeTitle], size: 40, color: _codeColors[codeTitle]),
              const SizedBox(height: 10),
              Text(
                codeTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _codeColors[codeTitle],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text("Emergency Dispatch"), centerTitle: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: roomController,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Location / Room Number",
                    hintText: "e.g. ER-01",
                    prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  ),
                ),
                
                const SizedBox(height: 40),
                const Text(
                  "Select Emergency Type:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 350, 
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildCodeButton("Code Blue"),
                            _buildCodeButton("Trauma Code"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            _buildCodeButton("STEMI Code"),
                            _buildCodeButton("Stroke Code"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text("🚨 ACTIVE EMERGENCY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: _codeColors[selectedCode],
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ScaleTransition(
                  scale: _animController,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _codeColors[selectedCode],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: _codeColors[selectedCode]!.withOpacity(0.5), blurRadius: 15, spreadRadius: 2)],
                    ),
                    child: Column(
                      children: [
                        Text(selectedCode, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(elapsedTime, style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text("📍 ${roomController.text}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                        child: TabBar(
                          indicator: BoxDecoration(color: _codeColors[selectedCode], borderRadius: BorderRadius.circular(10)),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          tabs: const [Tab(text: "Team & Support"), Tab(text: "Checklist")],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: responders.isEmpty 
                                    ? const Center(child: Text("No active responders found for this time."))
                                    : ListView.builder(
                                    itemCount: responders.length,
                                    itemBuilder: (context, index) {
                                      final doc = responders[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        color: Colors.green.shade50,
                                        child: ListTile(
                                          dense: true,
                                          leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white, size: 16)),
                                          title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          subtitle: Text("${doc.role} - ${doc.department}\nTime: ${doc.coverage}"), // يظهر وقت مناوبته
                                          isThreeLine: true,
                                          trailing: IconButton(
                                            onPressed: () => makeCall(doc.phone),
                                            icon: const Icon(Icons.call, color: Colors.blue),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // ... (بقية الكود الخاص بالدعم الإضافي والتشيك ليست)
                                const Divider(thickness: 2),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.yellow.shade50,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("📢 Request Additional Support", style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: DropdownButtonFormField<Doctor>(
                                              isDense: true,
                                              value: _selectedAdHocDoctor,
                                              hint: const Text("Select Doctor/Spec"),
                                              items: DataManager.doctors.map((d) => DropdownMenuItem(value: d, child: Text("${d.name} (${d.department})", style: const TextStyle(fontSize: 12)))).toList(),
                                              onChanged: (val) => setState(() => _selectedAdHocDoctor = val),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: _selectedAdHocDoctor == null ? null : () {
                                              makeCall(_selectedAdHocDoctor!.phone);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Calling ${_selectedAdHocDoctor!.name}...")));
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                                            child: const Text("Call"),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            ListView(
                              children: [
                                ..._currentChecklistState.keys.map((key) {
                                  return CheckboxListTile(
                                    title: Text(key),
                                    value: _currentChecklistState[key],
                                    activeColor: _codeColors[selectedCode],
                                    onChanged: (val) => setState(() => _currentChecklistState[key] = val!),
                                  );
                                }),
                                const Divider(),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Record Vitals:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                                Row(
                                  children: [
                                    Expanded(child: TextField(controller: hrController, decoration: const InputDecoration(labelText: "HR", border: OutlineInputBorder(), suffixText: "bpm", filled: true, fillColor: Colors.white))),
                                    const SizedBox(width: 10),
                                    Expanded(child: TextField(controller: bpController, decoration: const InputDecoration(labelText: "BP", border: OutlineInputBorder(), suffixText: "mmHg", filled: true, fillColor: Colors.white))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: stopEmergency,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, 
                      side: const BorderSide(color: Colors.red, width: 2), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("End Code & Save Log", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
