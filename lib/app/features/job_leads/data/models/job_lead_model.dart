class JobLead {
  const JobLead({
    this.id,
    required this.company,
    required this.position,
    this.location = '',
    this.salary = '',
    this.sourceUrl = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.rawText = '',
    this.notes = '',
    this.status = JobLeadStatus.saved,
    this.priority = JobLeadPriority.medium,
    this.followUpAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String company;
  final String position;
  final String location;
  final String salary;
  final String sourceUrl;
  final String contactEmail;
  final String contactPhone;
  final String rawText;
  final String notes;
  final JobLeadStatus status;
  final JobLeadPriority priority;
  final DateTime? followUpAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory JobLead.fromMap(Map<String, dynamic> map) {
    return JobLead(
      id: map['id'] as int?,
      company: map['company'] as String? ?? '',
      position: map['position'] as String? ?? '',
      location: map['location'] as String? ?? '',
      salary: map['salary'] as String? ?? '',
      sourceUrl: map['source_url'] as String? ?? '',
      contactEmail: map['contact_email'] as String? ?? '',
      contactPhone: map['contact_phone'] as String? ?? '',
      rawText: map['raw_text'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      status: JobLeadStatus.fromValue(map['status'] as String?),
      priority: JobLeadPriority.fromValue(map['priority'] as String?),
      followUpAt: map['follow_up_at'] == null
          ? null
          : DateTime.tryParse(map['follow_up_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'company': company,
      'position': position,
      'location': location,
      'salary': salary,
      'source_url': sourceUrl,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'raw_text': rawText,
      'notes': notes,
      'status': status.value,
      'priority': priority.value,
      'follow_up_at': followUpAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  JobLead copyWith({
    int? id,
    String? company,
    String? position,
    String? location,
    String? salary,
    String? sourceUrl,
    String? contactEmail,
    String? contactPhone,
    String? rawText,
    String? notes,
    JobLeadStatus? status,
    JobLeadPriority? priority,
    DateTime? followUpAt,
    bool clearFollowUp = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JobLead(
      id: id ?? this.id,
      company: company ?? this.company,
      position: position ?? this.position,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      rawText: rawText ?? this.rawText,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      followUpAt: clearFollowUp ? null : followUpAt ?? this.followUpAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get hasContact => contactEmail.isNotEmpty || contactPhone.isNotEmpty;
  bool get isFollowUpDue {
    final date = followUpAt;
    if (date == null) return false;
    return !date.isAfter(DateTime.now());
  }
}

enum JobLeadStatus {
  saved('saved', 'Saved'),
  applied('applied', 'Applied'),
  followUp('follow_up', 'Follow-up'),
  interview('interview', 'Interview'),
  rejected('rejected', 'Rejected'),
  offer('offer', 'Offer');

  const JobLeadStatus(this.value, this.label);

  final String value;
  final String label;

  static JobLeadStatus fromValue(String? value) {
    return JobLeadStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => JobLeadStatus.saved,
    );
  }
}

enum JobLeadPriority {
  low('low', 'Low'),
  medium('medium', 'Medium'),
  high('high', 'High');

  const JobLeadPriority(this.value, this.label);

  final String value;
  final String label;

  static JobLeadPriority fromValue(String? value) {
    return JobLeadPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => JobLeadPriority.medium,
    );
  }
}
