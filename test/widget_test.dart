import 'package:flutter_test/flutter_test.dart';
import 'package:swift_apply/app/features/cv/data/models/cv_file_model.dart';
import 'package:swift_apply/app/features/job_leads/presentation/providers/job_lead_provider.dart';

void main() {
  test('CvFile serializes database values', () {
    final addedAt = DateTime(2026, 5, 5, 10, 30);
    final cv = CvFile(
      id: 1,
      name: 'Flutter CV',
      path: '/tmp/flutter-cv.pdf',
      addedAt: addedAt,
      isDefault: true,
    );

    final restored = CvFile.fromMap(cv.toMap());

    expect(restored.id, 1);
    expect(restored.name, 'Flutter CV');
    expect(restored.path, '/tmp/flutter-cv.pdf');
    expect(restored.addedAt, addedAt);
    expect(restored.isDefault, isTrue);
  });

  test('JobLead parser extracts LinkedIn style shared job text', () {
    final lead = JobLeadProvider.parseJobText(
      'Senior Flutter Developer at Acme Apps\n'
      'Dubai, UAE\n'
      'https://www.linkedin.com/jobs/view/123456\n'
      'Contact hr@acme.test',
      fallbackPosition: 'Flutter Developer',
    );

    expect(lead.position, 'Senior Flutter Developer');
    expect(lead.company, 'Acme Apps');
    expect(lead.contactEmail, 'hr@acme.test');
    expect(lead.sourceUrl, contains('linkedin.com/jobs/view'));
  });

  test('JobLead parser extracts Indeed style labeled job text', () {
    final lead = JobLeadProvider.parseJobText(
      'Job title: Mobile Engineer\n'
      'Company: Bright Tech\n'
      'Location: Remote\n'
      'AED 12,000 - 18,000\n'
      'https://ae.indeed.com/viewjob?jk=abc',
      fallbackPosition: 'Flutter Developer',
    );

    expect(lead.position, 'Mobile Engineer');
    expect(lead.company, 'Bright Tech');
    expect(lead.location, 'Remote');
    expect(lead.salary, 'AED 12,000 - 18,000');
    expect(lead.sourceUrl, contains('indeed.com/viewjob'));
  });
}
