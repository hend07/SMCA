import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart'; // ✅ مكتبة CSV بدلاً من Excel
import 'dart:html' as html; 

import '../ai/service.dart';
import '../data/manager.dart'; 
import '../models.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  late AIService _ai;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final key = dotenv.env['GEMINI_API_KEY'];
    _ai = AIService(apiKey: key, debug: true);
    _addMessage("assistant", "مرحباً بك في SMCA AI Assistant! 👋 \nيمكنك رفع ملف CSV لتحديث الجدول، أو سؤالي عن أي مناوب.");
  }

  void _addMessage(String role, String content) {
    setState(() => _messages.add({"role": role, "content": content}));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }

  // ✅ دالة التعامل مع ملفات CSV
  Future<void> _handleCSVUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, 
        allowedExtensions: ['csv'], // ✅ السماح فقط بملفات CSV
        withData: true,
      );

      if (result != null) {
        setState(() => _isLoading = true);
        
        // 1. تحويل البيانات إلى نص
        final bytes = result.files.single.bytes!;
        final csvString = utf8.decode(bytes); // تحويل الـ Bytes لنص
        
        // 2. تحليل الـ CSV
        // نستخدم CsvToListConverter لتحويل النص لقائمة صفوف
        List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

        List<String> summary = [];
        int count = 0;

        // 3. قراءة الصفوف
        for (var i = 1; i < rows.length; i++) { // نبدأ من 1 لتخطي العنوان (Header)
          var row = rows[i];
          if (row.length < 2) continue;

          // نفترض أن العمود الأول هو القسم والثاني هو الاسم
          String dept = row[0].toString().trim();
          String name = row[1].toString().trim();

          if (dept.isNotEmpty && name.isNotEmpty) {
            DataManager.addDoctor(dept, name);
            summary.add("$dept: $name");
            count++;
          }
        }
        
        _addMessage('system', "✅ تم استيراد ملف CSV بنجاح! تمت إضافة $count مناوب.");
        
        // تحديث سياق الذكاء
        String examples = summary.take(5).join(", ");
        _sendMessage("تم رفع ملف CSV وتحديث النظام بـ $count سجل. أمثلة: $examples", true);
      }
    } catch (e) {
      _addMessage('system', '❌ خطأ في قراءة ملف CSV: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage([String? text, bool hidden = false]) async {
    final input = text ?? _controller.text.trim();
    if (input.isEmpty) return;

    if (!hidden) {
      _controller.clear();
      _addMessage("user", input);
    }
    setState(() => _isLoading = true);

    // سياق الجدول الحالي (CSV Format للذكاء)
    String csvContext = "Department,Name,Role,Phone,Coverage\n";
    csvContext += DataManager.doctors.map((d) => 
      "${d.department},${d.name},${d.role},${d.phone},${d.coverage}"
    ).join("\n");
    
    final contextMessage = "CONTEXT: Current Roster Data (CSV Format):\n$csvContext\n\nUser Query: $input";
    
    List<Map<String, String>> historyToSend = List.from(_messages);
    if (!hidden) historyToSend.last = {"role": "user", "content": contextMessage};

    final response = await _ai.sendChat(historyToSend);

    if (response['function_call'] != null) {
      final func = response['function_call'];
      final args = func['arguments'];
      
      if (func['name'] == 'add_doctor') {
        DataManager.addDoctor(args['department'], args['name']);
        _addMessage("function", "✅ تمت إضافة: ${args['name']} (قسم ${args['department']})");
      } 
      else if (func['name'] == 'replace_doctor') {
        DataManager.replaceDoctorInDept(args['department'], args['name']);
        _addMessage("function", "🔄 تم التعديل: مناوب ${args['department']} هو الآن ${args['name']}");
      }
      else if (func['name'] == 'get_roster') {
        final dept = args['department'];
        final docs = DataManager.doctors.where((d) => d.department.toLowerCase() == dept.toString().toLowerCase()).toList();
        
        if (docs.isEmpty) {
          _addMessage("function", "ℹ️ قسم $dept فارغ حالياً.");
        } else {
          // عرض منسق وجميل للتفاصيل
          String details = docs.map((d) => 
            "🔹 **${d.name}**\n   📞 ${d.phone} | 🕒 ${d.coverage}"
          ).join("\n\n");
          
          _addMessage("function", "📋 **مناوبو قسم $dept:**\n$details");
        }
      }
    } else {
      _addMessage("assistant", response['content'] ?? "حدث خطأ.");
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("SMCA AI Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final isSystem = msg['role'] == 'system' || msg['role'] == 'function';
                
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? const Color(0xFF25D366) // لون واتساب الأخضر
                          : (isSystem ? const Color(0xFFFFF3CD) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                        bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser && isSystem)
                           const Text(
                             "System Alert", 
                             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)
                           ),
                        Text(
                          msg['content']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if(_isLoading) 
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: LinearProgressIndicator(minHeight: 2, color: Color(0xFF25D366), backgroundColor: Colors.transparent),
             ),
          
          Container(
             padding: const EdgeInsets.all(12),
             decoration: const BoxDecoration(
               color: Colors.white,
               border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
             ),
             child: Row(children: [
               InkWell(
                  onTap: _handleCSVUpload, // ✅ استدعاء دالة CSV الجديدة
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                    child: const Icon(Icons.table_chart_rounded, color: Colors.green), // أيقونة توحي بالجدول
                  ),
               ),
               const SizedBox(width: 10),
               Expanded(
                 child: TextField(
                   controller: _controller,
                   textAlign: TextAlign.right,
                   textDirection: TextDirection.rtl,
                   decoration: InputDecoration(
                     hintText: "اسألني أو اطلب تحديث الجدول...",
                     hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                     filled: true,
                     fillColor: const Color(0xFFF5F7FB),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                   ),
                   onSubmitted: (_) => _sendMessage()
                 )
               ),
               const SizedBox(width: 8),
               InkWell(
                 onTap: () => _sendMessage(),
                 child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                 ),
               ),
             ]))
        ],
      ),
    );
  }
}