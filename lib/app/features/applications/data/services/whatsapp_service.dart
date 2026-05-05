import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:swift_apply/app/features/settings/data/models/settings_model.dart';
import 'package:url_launcher/url_launcher.dart';

@lazySingleton
class WhatsAppService {
  Future<bool> openWhatsApp({
    required AppSettings settings,
    required String phoneNumber,
    String? customMessage,
    String? company,
    String? position,
  }) async {
    final message = settings.renderTemplate(
      customMessage ?? settings.whatsappTemplate,
      company: company,
      position: position,
    );

    // Normalize phone number
    String phone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!phone.startsWith('+')) {
      final code = settings.defaultCountryCode.trim();
      if (code.isNotEmpty) {
        final normalizedCode = code.startsWith('+') ? code : '+$code';
        phone = '$normalizedCode$phone';
      } else {
        phone = '+$phone';
      }
    }
    
    // Remove the '+' for the API call but keep it for wa.me if needed
    final apiPhone = phone.replaceAll('+', '');

    // Option A: Direct API if configured
    if (settings.waApiKey.isNotEmpty &&
        settings.waPhoneId.isNotEmpty &&
        settings.waBusinessId.isNotEmpty) {
      return _sendViaApi(settings, apiPhone, message);
    }

    // Option B: URL Launcher Fallback
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$apiPhone?text=$encoded');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    } else {
      throw Exception('WhatsApp not installed or number is invalid.');
    }
  }

  Future<bool> _sendViaApi(
    AppSettings settings,
    String phone,
    String message,
  ) async {
    final url = Uri.parse(
      'https://graph.facebook.com/v21.0/${settings.waPhoneId}/messages',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${settings.waApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'messaging_product': 'whatsapp',
        'recipient_type': 'individual',
        'to': phone,
        'type': 'text',
        'text': {'body': message},
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final data = jsonDecode(response.body);
      final error = data['error']?['message'] ?? 'Unknown API error';
      throw Exception('WhatsApp API failed: $error');
    }
  }

  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return cleaned.length >= 7 && RegExp(r'^\d+$').hasMatch(cleaned);
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }
}
