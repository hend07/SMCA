import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_alert_app/data/manager.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  // ✅ دالة حفظ الملف (تعمل على الايفون والاندرويد)
  Future<void> downloadLogs(String content) async {
    try {
      // 1. تحديد مكان الحفظ المؤقت في الايفون
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/logs_report.csv';
      final file = File(path);

      // 2. كتابة البيانات داخل الملف
      await file.writeAsString(content);

      // 3. مشاركة الملف ليتمكن المستخدم من حفظه أو إرساله
      await Share.shareXFiles([XFile(path)], text: 'سجلات النظام');
    } catch (e) {
      print("Error saving logs: $e");
    }
  }

  // ✅ دالة التصدير المعدلة للويب
  Future<void> _exportLogs(BuildContext context) async {
    try {
      if (DataManager.logs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No records to export")));
        return;
      }

      String csvData = "Date,Code,Location,Duration,Team_Count,Vitals\n";
      for (var log in DataManager.logs) {
        csvData += "${log.date},${log.code},${log.room},${log.duration},${log.teamCount},${log.vitals}\n";
      }

      // ✅ طريقة التحميل للموبايل (Mobile Download)
      final bytes = utf8.encode(csvData);
      try {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/Medical_Logs_Archive.csv');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(file.path)], text: 'Medical Logs Report');
      } catch (e) {
        print('Error saving file: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logs downloaded successfully 📥"), backgroundColor: Colors.green)
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Archives"),
        actions: [
          IconButton(
            onPressed: () => _exportLogs(context),
            icon: const Icon(Icons.download),
            tooltip: "Download Logs",
          )
        ],
      ),
      body: DataManager.logs.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[300]),
                const Text("No records found", style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            itemCount: DataManager.logs.length,
            itemBuilder: (context, index) {
              final log = DataManager.logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.history_edu, color: Colors.blue),
                  ),
                  title: Text(log.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  subtitle: Text("${log.date} | 📍 ${log.room}"),
                  trailing: Text("⏱ ${log.duration}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.monitor_heart, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text("Vitals: ${log.vitals}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}