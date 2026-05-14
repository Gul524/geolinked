import 'package:geolinked/utils/app_exports.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String routeName = '/privacy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for GeoLinked',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last Updated: May 11, 2026',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Information We Collect',
              'GeoLinked collects location data to enable radius-based community features. We also collect your name and email during registration.',
            ),
            _buildSection(
              context,
              '2. How We Use Your Location',
              'Your location is used to show you nearby alerts (Asks and Broadcasts). If you enable background tracking, we periodically sync your position to ensure you receive notifications for the right area.',
            ),
            _buildSection(
              context,
              '3. Data Sharing',
              'We do not sell your personal data. Your location is only shared with the community when you explicitly post an Ask or Broadcast.',
            ),
            _buildSection(
              context,
              '4. Data Retention & Deletion',
              'We keep your data as long as your account is active. You can delete your account and all associated data at any time from the Profile settings.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 GeoLinked Team',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(height: 1.5, fontSize: 15),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
