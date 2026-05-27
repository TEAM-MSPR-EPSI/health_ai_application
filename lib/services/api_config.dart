import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _hotspotGatewayBaseUrl = 'http://192.168.137.1:5000';

  static String? _baseUrl;
  static bool _isPhysicalMobileDevice = false;

  static String get _storageKey {
    if (kIsWeb) return 'api_base_url_web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _isPhysicalMobileDevice ? 'api_base_url_android_physical' : 'api_base_url_android_emulator';
      case TargetPlatform.iOS:
        return _isPhysicalMobileDevice ? 'api_base_url_ios_physical' : 'api_base_url_ios_simulator';
      default:
        return 'api_base_url_desktop';
    }
  }

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _isPhysicalMobileDevice ? _hotspotGatewayBaseUrl : 'http://10.0.2.2:5000';
      case TargetPlatform.iOS:
        return _isPhysicalMobileDevice ? _hotspotGatewayBaseUrl : 'http://localhost:5000';
      default:
        return 'http://localhost:5000';
    }
  }

  static String get baseUrl => _baseUrl ?? (_overrideBaseUrl.isNotEmpty ? _overrideBaseUrl : defaultBaseUrl);

  static String normalizeBaseUrl(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.isEmpty) return defaultBaseUrl;

    final candidate = trimmed.contains('://') ? trimmed : 'http://$trimmed';
    final parsed = Uri.tryParse(candidate);
    if (parsed == null || parsed.host.isEmpty) {
      throw FormatException('URL API invalide. Exemple attendu: http://192.168.1.20:5000');
    }

    final normalizedPort = parsed.hasPort && parsed.port > 0 ? parsed.port : 5000;
    final normalizedPath = parsed.path == '/' ? '' : parsed.path;
    final uri = Uri(
      scheme: parsed.scheme,
      userInfo: parsed.userInfo,
      host: parsed.host,
      port: normalizedPort,
      path: normalizedPath,
      query: parsed.query,
      fragment: parsed.fragment,
    );
    return uri.toString().replaceAll(RegExp(r'/+$'), '');
  }

  static Uri buildApiUri(String path) {
    return buildApiUriFrom(baseUrl, path);
  }

  static Uri buildWebAppUri(String path, {int port = 4200}) {
    final parsed = Uri.tryParse(baseUrl);
    if (parsed == null || parsed.scheme.isEmpty || parsed.host.isEmpty) {
      throw FormatException('URL API invalide: $baseUrl');
    }

    return Uri(
      scheme: parsed.scheme,
      host: parsed.host,
      port: port,
      path: path.startsWith('/') ? path : '/$path',
    );
  }

  static Uri buildApiUriFrom(String base, String path) {
    final parsed = Uri.tryParse(base);
    if (parsed == null || parsed.scheme.isEmpty || parsed.host.isEmpty) {
      throw FormatException('URL API invalide: $base');
    }

    return parsed.resolve(path.startsWith('/') ? path : '/$path');
  }

  static Future<void> init() async {
    if (_overrideBaseUrl.isNotEmpty) {
      _baseUrl = _overrideBaseUrl;
      return;
    }

    await _detectPhysicalMobileDevice();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    if (stored != null && stored.trim().isNotEmpty) {
      if (_isPhysicalMobileDevice && _looksLikeLoopbackOrEmulator(stored)) {
        _baseUrl = defaultBaseUrl;
        await prefs.setString(_storageKey, _baseUrl!);
      } else if (!_isPhysicalMobileDevice && _looksLikePhysicalMobileGateway(stored)) {
        _baseUrl = defaultBaseUrl;
        await prefs.setString(_storageKey, _baseUrl!);
      } else {
        _baseUrl = stored;
      }
      return;
    }

    _baseUrl = defaultBaseUrl;
    if (_isPhysicalMobileDevice) {
      await prefs.setString(_storageKey, _baseUrl!);
    }
  }

  static Future<void> setBaseUrl(String value) async {
    final normalized = normalizeBaseUrl(value);
    _baseUrl = normalized.isEmpty ? defaultBaseUrl : normalized;
    if (_overrideBaseUrl.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, _baseUrl!);
  }

  static String get baseUrlHint => defaultBaseUrl;

  static Future<void> _detectPhysicalMobileDevice() async {
    if (kIsWeb) {
      _isPhysicalMobileDevice = false;
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      _isPhysicalMobileDevice = androidInfo.isPhysicalDevice;
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      _isPhysicalMobileDevice = iosInfo.isPhysicalDevice;
      return;
    }

    _isPhysicalMobileDevice = false;
  }

  static bool _looksLikeLoopbackOrEmulator(String value) {
    final parsed = Uri.tryParse(value.startsWith('http') ? value : 'http://$value');
    final host = parsed?.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }

  static bool _looksLikePhysicalMobileGateway(String value) {
    final parsed = Uri.tryParse(value.startsWith('http') ? value : 'http://$value');
    final host = parsed?.host.toLowerCase();
    if (host == null) {
      return false;
    }

    return host.startsWith('192.168.') || host.startsWith('10.') || host.startsWith('172.16.') || host.startsWith('172.17.') || host.startsWith('172.18.') || host.startsWith('172.19.') || host.startsWith('172.20.') || host.startsWith('172.21.') || host.startsWith('172.22.') || host.startsWith('172.23.') || host.startsWith('172.24.') || host.startsWith('172.25.') || host.startsWith('172.26.') || host.startsWith('172.27.') || host.startsWith('172.28.') || host.startsWith('172.29.') || host.startsWith('172.30.') || host.startsWith('172.31.');
  }
}
