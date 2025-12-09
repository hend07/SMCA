import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  final String? apiKey;
  final bool mockMode;
  final bool debug;

  // ✅ نستخدم الموديل الذي تريده
  static const String _modelName = "gemma-3-27b-it";

  AIService({this.apiKey, this.debug = false})
      : mockMode = (apiKey == null || apiKey.trim().isEmpty);

  Future<Map<String, dynamic>> sendChat(List<Map<String, String>> messages) async {
    if (mockMode) return {'content': "Mock Mode: No Key."};

    final key = apiKey!.trim();
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$key');

    final StringBuffer fullPrompt = StringBuffer();
    
    // 🔥 تحديث التعليمات لتشمل الإضافة والتعديل 🔥
    fullPrompt.writeln("""
    You are a smart hospital roster assistant. 
    Current Date: ${DateTime.now().toString().split(' ')[0]}.
    
    CRITICAL RULES (Output JSON ONLY for actions):

    1. ✅ ADDING NEW DOCTOR:
       If user says "Add Ali to ER" or "New doctor in ICU is Sara" (Adding to existing team):
       RETURN JSON: {"function_call": {"name": "add_doctor", "arguments": {"department": "ER", "name": "Ali"}}}

    2. 🔄 REPLACING/CHANGING DOCTOR:
       If user says "Change ER to Ali" or "Replace Sara with Mona" or "Update ER doctor to Ali" (Removing old, putting new):
       RETURN JSON: {"function_call": {"name": "replace_doctor", "arguments": {"department": "ER", "name": "Ali"}}}
       
    3. ❓ ASKING INFO:
       If user asks "Who is in ICU?":
       RETURN JSON: {"function_call": {"name": "get_roster", "arguments": {"department": "ICU"}}}
       
    4. Otherwise, reply as a helpful assistant in English.
    
    CONVERSATION:
    """);

    for (var msg in messages) {
      if (msg['role'] != 'system' && msg['role'] != 'function') {
        fullPrompt.writeln("${msg['role'] == 'user' ? 'User' : 'Model'}: ${msg['content']}");
      }
    }
    fullPrompt.writeln("Model:"); 

    final body = {
      "contents": [{"parts": [{"text": fullPrompt.toString()}]}],
      "generationConfig": {"temperature": 0.1} // دقة عالية
    };

    if (debug) print('🚀 Connecting to $_modelName...');

    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (resp.statusCode != 200) {
        if (debug) print('❌ AI Error: ${resp.body}');
        return {'content': "AI Error (${resp.statusCode}): ${resp.body}"};
      }

      final jsonResp = jsonDecode(utf8.decode(resp.bodyBytes));
      String? textResponse = jsonResp['candidates']?[0]?['content']?['parts']?[0]?['text'];
      
      if (textResponse == null) return {'content': "No response from AI."};

      // تنظيف النص
      textResponse = textResponse.trim().replaceAll('```json', '').replaceAll('```', '').trim();

      // محاولة اكتشاف JSON
      if (textResponse.startsWith('{') && textResponse.contains('function_call')) {
        try {
          final parsed = jsonDecode(textResponse);
          if (parsed['function_call'] != null) {
            return {'content': null, 'function_call': parsed['function_call']};
          }
        } catch (e) {
          if (debug) print('JSON Parse Error: $e');
        }
      }
      return {'content': textResponse};

    } catch (e) {
      return {'content': "Exception: $e"};
    }
  }
}