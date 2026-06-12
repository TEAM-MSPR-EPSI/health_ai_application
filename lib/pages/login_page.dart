import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/pages/main_navigation_page.dart';
import 'package:health_ai_application/services/api_config.dart';
import 'package:health_ai_application/services/local_network_detector.dart';
import 'package:health_ai_application/widgets/app_logo.dart';
import 'package:health_ai_application/widgets/frosted_surface.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  Future<String> _probeBaseUrl(String rawValue) async {
    final normalized = ApiConfig.normalizeBaseUrl(rawValue);
    final uri = ApiConfig.buildApiUriFrom(normalized, '/api/auth/login');
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: '{"email":"probe@health.ai","password":"probe"}',
        )
        .timeout(const Duration(seconds: 4));

    if (response.statusCode == 401 && response.body.contains('error')) {
      return normalized;
    }
    throw Exception(
      'Le serveur répond mais ce n’est pas l’API attendue (HTTP ${response.statusCode}).',
    );
  }

  Future<void> _editServerUrl() async {
    final controller = TextEditingController(text: ApiConfig.baseUrl);
    final updated = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        var isDetecting = false;
        final presets = <Map<String, String>>[
          {'label': 'Android emulator', 'value': 'http://10.0.2.2:5000'},
          {'label': 'iOS simulator / web / desktop', 'value': 'http://localhost:5000'},
          {'label': 'Exemple LAN', 'value': 'http://192.168.1.20:5000'},
        ];

        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Configuration du serveur API',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez l\'adresse joignable depuis l\'appareil courant. Sur téléphone physique, utilisez l\'IP locale du PC ou le point d\'accès partagé.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final preset in presets)
                        ActionChip(
                          label: Text(preset['label']!),
                          onPressed: () => controller.text = preset['value']!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'La détection automatique recherche un backend HealthAI disponible sur le réseau actif.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'URL du service API',
                      hintText: 'http://192.168.1.20:5000',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, ApiConfig.defaultBaseUrl),
                        child: const Text('Valeur recommandée'),
                      ),
                      TextButton(
                        onPressed: isDetecting
                            ? null
                            : () async {
                                setState(() => isDetecting = true);
                                try {
                                  final detected = await detectLocalBackendUrl(port: 5000);
                                  if (!context.mounted) return;
                                  setState(() => isDetecting = false);

                                  if (detected == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Aucun backend n\'a été détecté sur le réseau local. Vérifiez que le PC et l\'appareil sont sur le même réseau et que le port 5000 est accessible.'),
                                      ),
                                    );
                                    return;
                                  }

                                  controller.text = detected;
                                  Navigator.pop(context, detected);
                                } catch (error) {
                                  if (!context.mounted) return;
                                  setState(() => isDetecting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                        child: isDetecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Détecter'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            final normalized = await _probeBaseUrl(controller.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Serveur API joignable sur : $normalized')),
                            );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                        child: const Text('Tester'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, controller.text.trim()),
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    controller.dispose();
    if (updated == null || updated.trim().isEmpty) return;
    try {
      final normalized = ApiConfig.normalizeBaseUrl(updated);
      await _probeBaseUrl(normalized);
      await ApiConfig.setBaseUrl(normalized);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL non validée: ${error.toString()}')),
      );
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Serveur API enregistré : ${ApiConfig.baseUrl}')),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    try {
      await _authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Get.back();
      } else {
        Get.offAll(() => const MainNavigationPage());
      }
    } catch (error) {
      if (!mounted) return;
      final warning = _authController.bootstrapError.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(warning ?? error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: const Center(child: AppLogo(size: 34)),
        title: const Text('Accès à HealthAI'),
        actions: [
          IconButton(
            onPressed: _editServerUrl,
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Configurer le backend',
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackdrop()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    const Center(child: AppLogo(size: 80)),
                    const SizedBox(height: 24),
                    FrostedSurface(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Accédez à votre espace HealthAI',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connectez-vous pour consulter votre fil, vos publications et votre profil.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Serveur actif : ${ApiConfig.baseUrl}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Adresse e-mail'),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Mot de passe'),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => FilledButton(
                              onPressed: _authController.isLoading.value ? null : _submit,
                              child: _authController.isLoading.value
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Text('Se connecter'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
