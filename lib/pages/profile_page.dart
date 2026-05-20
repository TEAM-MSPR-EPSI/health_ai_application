import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = Get.find<AuthController>();

  Future<void> _editProfile(UserProfile profile) async {
    final firstNameController = TextEditingController(text: profile.firstName);
    final lastNameController = TextEditingController(text: profile.lastName);
    final usernameController = TextEditingController(text: profile.username);
    final phoneController = TextEditingController(text: profile.phone);
    final cityController = TextEditingController(text: profile.city ?? '');
    final countryController = TextEditingController(text: profile.country ?? '');

    final updated = await showModalBottomSheet<UserProfile>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Modifier le profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Prenom')),
              const SizedBox(height: 12),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 12),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Pseudo')),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telephone')),
              const SizedBox(height: 12),
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'Ville')),
              const SizedBox(height: 12),
              TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Pays')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    profile.copyWith(
                      firstName: firstNameController.text.trim(),
                      lastName: lastNameController.text.trim(),
                      username: usernameController.text.trim(),
                      phone: phoneController.text.trim(),
                      city: cityController.text.trim(),
                      country: countryController.text.trim(),
                    ),
                  );
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        );
      },
    );

    if (updated != null) {
      try {
        await _authController.updateProfile(updated);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final profile = _authController.currentUser.value;
        if (profile == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mon compte'),
            actions: [
              IconButton(
                onPressed: _authController.logout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          profile.displayName.isNotEmpty ? profile.displayName[0] : 'U',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(profile.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('@${profile.username}', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      Text(profile.email, textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text('Tel: ${profile.phone}', textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text('Ville: ${profile.city ?? '-'} | Pays: ${profile.country ?? '-'}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => _editProfile(profile),
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier le profil'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


