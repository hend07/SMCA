import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:html' as html; // ✅ مكتبة الويب للتحميل

import 'package:smart_alert_app/data/manager.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  // ✅ دالة التصدير المعدلة للويب
  void _exportLogs(BuildContext context) {
    try {
      if (DataManager.logs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No records to export")));
        return;
      }

      String csvData = "Date,Code,Location,Duration,Team_Count,Vitals\n";
      for (var log in DataManager.logs) {
        csvData += "${log.date},${log.code},${log.room},${log.duration},${log.teamCount},${log.vitals}\n";
      }

      // 🌐 طريقة التحميل للويب (Web Download)
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "Medical_Logs_Archive.csv")
        ..click();
      
      html.Url.revokeObjectUrl(url);

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