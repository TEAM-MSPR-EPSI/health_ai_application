import 'package:flutter/material.dart';
import 'package:health_ai_application/models/user_profile.dart';
import 'package:health_ai_application/services/fake_social_repository.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserProfile profile;

  @override
  void initState() {
    super.initState();
    profile = FakeSocialRepository.instance.profile;
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: profile.name);
    final usernameController = TextEditingController(text: profile.username);
    final bioController = TextEditingController(text: profile.bio);

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
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom')),
              const SizedBox(height: 12),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Pseudo')),
              const SizedBox(height: 12),
              TextField(controller: bioController, maxLines: 3, decoration: const InputDecoration(labelText: 'Bio')),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    UserProfile(
                      name: nameController.text.trim(),
                      username: usernameController.text.trim(),
                      bio: bioController.text.trim(),
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
      FakeSocialRepository.instance.updateProfile(updated);
      setState(() => profile = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon compte')),
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
                      profile.name.isNotEmpty ? profile.name[0] : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(profile.username, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 12),
                  Text(profile.bio, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _editProfile,
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
  }
}


