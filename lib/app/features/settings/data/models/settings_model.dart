class AppSettings {
  final int id;
  final String senderName;
  final String senderEmail;
  final String emailPassword;
  final String smtpHost;
  final int smtpPort;
  final String emailTemplate;
  final String emailSubject;
  final String whatsappTemplate;
  final String targetPosition;
  final String experienceYears;
  final String skills;
  final String location;
  final String defaultCountryCode;
  final bool autoAttachDefaultCv;
  final String waApiKey;
  final String waPhoneId;
  final String waBusinessId;

  const AppSettings({
    this.id = 1,
    required this.senderName,
    required this.senderEmail,
    required this.emailPassword,
    required this.smtpHost,
    required this.smtpPort,
    required this.emailTemplate,
    required this.emailSubject,
    required this.whatsappTemplate,
    this.targetPosition = 'Flutter Developer',
    this.experienceYears = '3',
    this.skills = 'Flutter, Dart, Firebase, REST APIs',
    this.location = '',
    this.defaultCountryCode = '',
    this.autoAttachDefaultCv = true,
    this.waApiKey = '',
    this.waPhoneId = '',
    this.waBusinessId = '',
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int,
      senderName: map['sender_name'] as String? ?? '',
      senderEmail: map['sender_email'] as String? ?? '',
      emailPassword: map['email_password'] as String? ?? '',
      smtpHost: map['smtp_host'] as String? ?? 'smtp.gmail.com',
      smtpPort: map['smtp_port'] as int? ?? 587,
      emailTemplate: map['email_template'] as String? ?? '',
      emailSubject: map['email_subject'] as String? ?? '',
      whatsappTemplate: map['whatsapp_template'] as String? ?? '',
      targetPosition: map['target_position'] as String? ?? 'Flutter Developer',
      experienceYears: map['experience_years'] as String? ?? '3',
      skills: map['skills'] as String? ?? 'Flutter, Dart, Firebase, REST APIs',
      location: map['location'] as String? ?? '',
      defaultCountryCode: map['default_country_code'] as String? ?? '',
      autoAttachDefaultCv: (map['auto_attach_default_cv'] as int?) != 0,
      waApiKey: map['wa_api_key'] as String? ?? '',
      waPhoneId: map['wa_phone_id'] as String? ?? '',
      waBusinessId: map['wa_business_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_name': senderName,
      'sender_email': senderEmail,
      'email_password': emailPassword,
      'smtp_host': smtpHost,
      'smtp_port': smtpPort,
      'email_template': emailTemplate,
      'email_subject': emailSubject,
      'whatsapp_template': whatsappTemplate,
      'target_position': targetPosition,
      'experience_years': experienceYears,
      'skills': skills,
      'location': location,
      'default_country_code': defaultCountryCode,
      'auto_attach_default_cv': autoAttachDefaultCv ? 1 : 0,
      'wa_api_key': waApiKey,
      'wa_phone_id': waPhoneId,
      'wa_business_id': waBusinessId,
    };
  }

  String renderTemplate(String template, {String? company, String? position}) {
    final resolvedCompany = company == null || company.trim().isEmpty
        ? 'your company'
        : company.trim();
    final resolvedPosition = position == null || position.trim().isEmpty
        ? targetPosition
        : position.trim();

    return template
        .replaceAll('{name}', senderName)
        .replaceAll('{email}', senderEmail)
        .replaceAll('{position}', resolvedPosition)
        .replaceAll('{company}', resolvedCompany)
        .replaceAll('{experience}', experienceYears)
        .replaceAll('{skills}', skills)
        .replaceAll('{location}', location);
  }

  AppSettings copyWith({
    String? senderName,
    String? senderEmail,
    String? emailPassword,
    String? smtpHost,
    int? smtpPort,
    String? emailTemplate,
    String? emailSubject,
    String? whatsappTemplate,
    String? targetPosition,
    String? experienceYears,
    String? skills,
    String? location,
    String? defaultCountryCode,
    bool? autoAttachDefaultCv,
    String? waApiKey,
    String? waPhoneId,
    String? waBusinessId,
  }) {
    return AppSettings(
      id: id,
      senderName: senderName ?? this.senderName,
      senderEmail: senderEmail ?? this.senderEmail,
      emailPassword: emailPassword ?? this.emailPassword,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      emailTemplate: emailTemplate ?? this.emailTemplate,
      emailSubject: emailSubject ?? this.emailSubject,
      whatsappTemplate: whatsappTemplate ?? this.whatsappTemplate,
      targetPosition: targetPosition ?? this.targetPosition,
      experienceYears: experienceYears ?? this.experienceYears,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
      autoAttachDefaultCv: autoAttachDefaultCv ?? this.autoAttachDefaultCv,
      waApiKey: waApiKey ?? this.waApiKey,
      waPhoneId: waPhoneId ?? this.waPhoneId,
      waBusinessId: waBusinessId ?? this.waBusinessId,
    );
  }
}
