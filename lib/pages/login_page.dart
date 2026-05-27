import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/services/api_config.dart';
import 'package:health_ai_application/services/local_network_detector.dart';
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
      builder: (context) {
        var isDetecting = false;
        final presets = <Map<String, String>>[
          {'label': 'Android emulator', 'value': 'http://10.0.2.2:5000'},
          {'label': 'iOS simulator / web / desktop', 'value': 'http://localhost:5000'},
          {'label': 'Exemple LAN', 'value': 'http://192.168.1.20:5000'},
        ];

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
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
                    'Connexion au backend Docker',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Android emulator: ${ApiConfig.defaultBaseUrl}\nTéléphone physique: utilise l\'IP LAN de ton PC, par exemple http://192.168.1.20:5000',
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
                    'La détection automatique scanne le sous-réseau Wi-Fi actif et propose le backend qui répond sur le port 5000.',
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, ApiConfig.defaultBaseUrl),
                        child: const Text('Par défaut'),
                      ),
                      const SizedBox(width: 8),
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
                                        content: Text('Aucun backend détecté sur le réseau local. Vérifie que le PC et le téléphone sont sur le même hotspot et que le port 5000 est ouvert.'),
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
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          try {
                            final normalized = await _probeBaseUrl(controller.text);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('API joignable depuis l’appareil sur : $normalized')),
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
                      const SizedBox(width: 8),
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
      SnackBar(content: Text('API configurée sur ${ApiConfig.baseUrl}')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion reussie.')),
      );
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
        title: const Text('Connexion'),
        actions: [
          IconButton(
            onPressed: _editServerUrl,
            icon: const Icon(Icons.settings_ethernet),
            tooltip: 'Configurer le backend',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Connectez-vous pour accéder à l'application",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Text(
              'Backend: ${ApiConfig.baseUrl}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
            ),
            const SizedBox(height: 24),
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
    );
  }
}
