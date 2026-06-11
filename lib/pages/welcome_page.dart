import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/pages/login_page.dart';
import 'package:health_ai_application/services/api_config.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _openSignup(BuildContext context) async {
    final signupUri = ApiConfig.buildWebAppUri('/welcome', port: 4200);
    final opened = await launchUrl(
      signupUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir la page d’inscription.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withValues(alpha: 0.96),
              colorScheme.primaryContainer.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: colorScheme.outlineVariant),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 170,
                          height: 170,
                          fit: BoxFit.contain,
                          semanticLabel: 'HealthAI Coach',
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'HealthAI Coach',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bouge. Mange bien. Vis mieux.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ton coach bien-être personnel pour la nutrition, le sport et la récupération.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => Get.to(() => const LoginPage()),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Se connecter'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openSignup(context),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('S’inscrire'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'En continuant, tu acceptes nos conditions d’utilisation et notre politique de confidentialité.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}