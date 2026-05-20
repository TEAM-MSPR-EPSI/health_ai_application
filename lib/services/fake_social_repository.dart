import 'package:health_ai_application/models/post.dart';
import 'package:health_ai_application/models/user_profile.dart';

class FakeSocialRepository {
  FakeSocialRepository._();
  static final FakeSocialRepository instance = FakeSocialRepository._();

  UserProfile _profile = const UserProfile(
    name: 'Alex Martin',
    username: '@alexfit',
    bio: 'Passionne de sport, nutrition et progression au quotidien.',
  );

  final List<Post> _posts = [
    Post(
      id: '1',
      authorName: 'HealthAI',
      authorHandle: '@healthai',
      content: 'Bienvenue sur la base Flutter de la MSPR 3. Ici tu pourras afficher un fil, publier et modifier ton profil.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
    ),
    Post(
      id: '2',
      authorName: 'Alex Martin',
      authorHandle: '@alexfit',
      content: 'Objectif de la semaine : reprendre un rythme regulier entre nutrition, sport et suivi perso.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  UserProfile get profile => _profile;
  List<Post> getPosts() => List.unmodifiable(_posts.reversed);

  void addPost(String content) {
    _posts.add(
      Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: _profile.name,
        authorHandle: _profile.username,
        content: content,
        createdAt: DateTime.now(),
      ),
    );
  }

  void updateProfile(UserProfile updatedProfile) {
    _profile = updatedProfile;
  }
}


