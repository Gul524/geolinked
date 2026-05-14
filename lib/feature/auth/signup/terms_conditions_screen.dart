import 'package:geolinked/utils/app_exports.dart';

class TermsConditionsScreen extends StatelessWidget {
  static const String routeName = '/term&condition';

  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: '1. Platform Purpose'),
            _SectionText(
              text:
                  'GeoLinked is a community-driven platform designed solely for information sharing and connecting users based on their geographical location. It is intended to help people ask questions and share updates about their surroundings.',
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: '2. User Responsibility & Disclaimer'),
            _SectionText(
              text:
                  'All information, comments, and broadcasts shared on this platform are provided by third-party users. The platform and its owners do not verify the accuracy of the information provided.',
            ),
            _SectionText(
              text:
                  'YOU ARE SOLELY RESPONSIBLE FOR CROSS-CHECKING ANY INFORMATION RECEIVED THROUGH THIS APP. Do not rely on community updates for critical safety, financial, or legal decisions without independent verification.',
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: '3. Limitation of Liability'),
            _SectionText(
              text:
                  'TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE APP OWNER AND DEVELOPERS SHALL NOT BE HELD RESPONSIBLE OR LIABLE FOR:',
            ),
            _BulletPoint(
              text:
                  'Incorrect, misleading, or outdated comments or broadcasts.',
            ),
            _BulletPoint(
              text: 'Fraudulent activities or fake news shared by users.',
            ),
            _BulletPoint(
              text:
                  'Any physical, financial, or emotional harm resulting from the use of information found on the app.',
            ),
            _BulletPoint(
              text:
                  'Any disputes arising between users connecting via the platform.',
            ),
            const SizedBox(height: 20),
            _SectionHeader(title: '4. Prohibited Behavior'),
            _SectionText(
              text:
                  'Users are strictly prohibited from sharing fake news, engaging in harassment, or using the platform for illegal activities. We reserve the right to ban any user found violating these terms.',
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('I Understand and Agree'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _SectionText extends StatelessWidget {
  const _SectionText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
