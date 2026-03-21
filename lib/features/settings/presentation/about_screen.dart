import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:doggylog/features/shared/presentation/widgets/liquid_glass_card.dart';
import 'package:doggylog/features/shared/presentation/widgets/soft_backdrop.dart';
import 'package:doggylog/platform/doggylog_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const _privacyPolicyUrl =
    'https://lucky-geranium-802.notion.site/DoggyDays-Privacy-Policy-323407f7a70180fca0dcffdf87e97c92?source=copy_link';
const _contactEmail = 'baibin1989@foxmail.com';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, this.loadAppVersionInfo});

  final Future<AppVersionInfo?> Function()? loadAppVersionInfo;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  AppVersionInfo? _appVersionInfo;

  @override
  void initState() {
    super.initState();
    final loadAppVersionInfo =
        widget.loadAppVersionInfo ?? DoggylogPlatform().loadAppVersionInfo;
    loadAppVersionInfo().then((info) {
      if (info == null || !mounted) {
        return;
      }
      setState(() => _appVersionInfo = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final versionLabel = _appVersionInfo == null
        ? l10n.aboutVersionLoading
        : '${_appVersionInfo!.version} (${_appVersionInfo!.buildNumber})';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: SoftBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            LiquidGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/icon.png',
                        width: 88,
                        height: 88,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 88,
                            height: 88,
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.pets_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.aboutVersion}: $versionLabel',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            LiquidGlassCard(
              child: Column(
                children: [
                  _AboutInfoTile(
                    icon: Icons.mail_outline_rounded,
                    title: l10n.aboutContact,
                    subtitle: _contactEmail,
                    onTap: () => _handleEmailTap(context),
                  ),
                  const Divider(height: 24),
                  _AboutInfoTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.aboutPrivacyPolicy,
                    subtitle: _privacyPolicyUrl,
                    onTap: () => _launchUri(
                      context,
                      Uri.parse(_privacyPolicyUrl),
                      fallbackText: _privacyPolicyUrl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEmailTap(BuildContext context) async {
    final emailUri = Uri(scheme: 'mailto', path: _contactEmail);
    await _launchUri(context, emailUri, fallbackText: _contactEmail);
  }

  Future<void> _launchUri(
    BuildContext context,
    Uri uri, {
    required String fallbackText,
  }) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: fallbackText));
    if (!mounted) {
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.aboutCopiedFallback)));
  }
}

class _AboutInfoTile extends StatelessWidget {
  const _AboutInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
