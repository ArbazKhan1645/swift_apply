class JobHistory {
  final int? id;
  final String recipient;
  final String type; // 'email' | 'whatsapp'
  final String? cvName;
  final DateTime sentAt;
  final String status; // 'sent' | 'failed'
  final String? note;

  const JobHistory({
    this.id,
    required this.recipient,
    required this.type,
    this.cvName,
    required this.sentAt,
    this.status = 'sent',
    this.note,
  });

  factory JobHistory.fromMap(Map<String, dynamic> map) {
    return JobHistory(
      id: map['id'] as int?,
      recipient: map['recipient'] as String,
      type: map['type'] as String,
      cvName: map['cv_name'] as String?,
      sentAt: DateTime.parse(map['sent_at'] as String),
      status: map['status'] as String? ?? 'sent',
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'recipient': recipient,
      'type': type,
      'cv_name': cvName,
      'sent_at': sentAt.toIso8601String(),
      'status': status,
      'note': note,
    };
  }

  bool get isEmail => type == 'email';
  bool get isWhatsApp => type == 'whatsapp';
}
