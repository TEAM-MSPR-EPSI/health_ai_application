import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health_ai_application/controllers/auth_controller.dart';
import 'package:health_ai_application/controllers/feed_controller.dart';
import 'package:health_ai_application/models/user_profile.dart';
import 'package:health_ai_application/widgets/avatar_badge.dart';
import 'package:health_ai_application/widgets/post_card.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = Get.find<AuthController>();
  final FeedController _feedController = Get.find<FeedController>();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authController.token.value != null) {
        _refreshMyPostsSafely();
      }
    });
  }

  Future<void> _refreshMyPostsSafely() async {
    try {
      await _feedController.loadMyPosts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de charger vos publications: $error')),
      );
    }
  }

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
                  final navigator = Navigator.of(context);
                  navigator.pop(
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

  Future<void> _changeAvatar() async {
    final profile = _authController.currentUser.value;
    if (profile == null) return;

    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Ajouter une photo'),
                onTap: () => Navigator.pop(context, 'photo'),
              ),
              ListTile(
                leading: const Icon(Icons.emoji_emotions),
                title: const Text('Choisir un emoji'),
                onTap: () => Navigator.pop(context, 'emoji'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Supprimer l’avatar'),
                onTap: () => Navigator.pop(context, 'clear'),
              ),
            ],
          ),
        );
      },
    );

    if (choice == 'photo') {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      await _authController.updateAvatar(image: file);
      return;
    }

    if (choice == 'emoji') {
      final emoji = await _pickEmojiAvatar();
      if (emoji == null) return;
      await _authController.updateAvatar(emoji: emoji);
      return;
    }

    if (choice == 'clear') {
      await _authController.updateAvatar(emoji: '', image: null);
    }
  }

  Future<String?> _pickEmojiAvatar() {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        const emojis = ['😀', '😎', '💪', '🌿', '❤️', '🏃', '🧠', '🥗'];
        return SafeArea(
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            padding: const EdgeInsets.all(16),
            children: [
              for (final item in emojis)
                InkWell(
                  onTap: () => Navigator.pop(context, item),
                  child: Center(child: Text(item, style: const TextStyle(fontSize: 32))),
                ),
            ],
          ),
        );
      },
    );
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
          body: RefreshIndicator(
            onRefresh: _feedController.loadMyPosts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AvatarBadge(
                          radius: 34,
                          fallbackLabel: profile.displayName,
                          imageUrl: profile.avatarUrl,
                          emoji: profile.avatarEmoji,
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
                        FilledButton.icon(
                          onPressed: _changeAvatar,
                          icon: const Icon(Icons.account_circle_outlined),
                          label: const Text('Changer la photo / emoji'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _editProfile(profile),
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier le profil'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () {
                    final warning = _authController.bootstrapError.value;
                    if (warning == null || warning.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        warning,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    );
                  },
                ),
                const Text('Mes publications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Obx(
                  () {
                    if (_feedController.myPosts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text('Aucune publication pour le moment.'),
                      );
                    }

                    return Column(
                      children: _feedController.myPosts.map((post) => PostCard(post: post)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


