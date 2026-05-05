import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:swift_apply/app/features/settings/data/models/settings_model.dart';
import 'package:url_launcher/url_launcher.dart';

@lazySingleton
class EmailService {
  Future<bool> sendEmail({
    required AppSettings settings,
    required String toEmail,
    required String? cvPath,
    String? customSubject,
    String? customBody,
    String? company,
    String? position,
  }) async {
    final renderedSubject = settings.renderTemplate(
      customSubject ?? settings.emailSubject,
      company: company,
      position: position,
    );
    final body = settings.renderTemplate(
      customBody ?? settings.emailTemplate,
      company: company,
      position: position,
    );

    // Fallback if SMTP not configured
    if (settings.senderEmail.isEmpty || settings.emailPassword.isEmpty) {
      final uri = Uri(
        scheme: 'mailto',
        path: toEmail,
        query: 'subject=${Uri.encodeComponent(renderedSubject)}&body=${Uri.encodeComponent(body)}',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      }
      throw Exception('Could not launch email client.');
    }

    final smtpServer = SmtpServer(
      settings.smtpHost,
      port: settings.smtpPort,
      username: settings.senderEmail,
      password: settings.emailPassword,
      ssl: settings.smtpPort == 465,
      allowInsecure: false,
    );

    final message = Message()
      ..from = Address(settings.senderEmail, settings.senderName)
      ..recipients.add(toEmail)
      ..subject = renderedSubject
      ..text = body;

    if (cvPath != null && cvPath.isNotEmpty) {
      final file = File(cvPath);
      if (await file.exists()) {
        message.attachments.add(FileAttachment(file));
      }
    }

    try {
      await send(message, smtpServer);
      return true;
    } on MailerException catch (e) {
      throw Exception('Email failed: ${e.message}');
    }
  }
}
