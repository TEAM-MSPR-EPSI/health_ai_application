import 'dart:convert';
import 'dart:io';

Future<String?> detectLocalBackendUrl({int port = 5000}) async {
  try {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );

    final prefixes = <String>[];
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (address.type != InternetAddressType.IPv4) {
          continue;
        }

        final parts = address.address.split('.');
        if (parts.length != 4) {
          continue;
        }

        final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
        if (!prefixes.contains(prefix)) {
          prefixes.add(prefix);
        }
      }
    }

    if (prefixes.isEmpty) {
      return null;
    }

    const preferredHosts = [
      1,
      2,
      10,
      20,
      21,
      30,
      40,
      50,
      60,
      70,
      80,
      90,
      100,
      101,
      102,
      110,
      120,
      123,
      128,
      129,
      130,
      150,
      160,
      168,
      200,
      254,
    ];

    for (final prefix in prefixes) {
      final candidates = preferredHosts.map((host) => '$prefix.$host').toList();
      final match = await _findFirstReachableHost(candidates, port: port);
      if (match != null) {
        return match;
      }
    }

    return null;
  } catch (_) {
    return null;
  }
}

Future<String?> _findFirstReachableHost(
  List<String> hosts, {
  required int port,
}) async {
  const batchSize = 16;
  for (var index = 0; index < hosts.length; index += batchSize) {
    final batch = hosts.skip(index).take(batchSize).toList();
    final results = await Future.wait(
      batch.map((host) => _probeHost(host, port: port)),
    );

    final foundIndex = results.indexWhere((result) => result != null);
    if (foundIndex != -1) {
      return results[foundIndex];
    }
  }

  return null;
}

Future<String?> _probeHost(String host, {required int port}) async {
  HttpClient? client;
  try {
    client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 500)
      ..idleTimeout = const Duration(seconds: 1);

    final request = await client.postUrl(Uri.parse('http://$host:$port/api/auth/login'));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode('{"email":"probe@health.ai","password":"probe"}'));
    final response = await request.close().timeout(const Duration(milliseconds: 800));
    final body = await utf8.decodeStream(response);

    if (response.statusCode == 401 && body.contains('error')) {
      return 'http://$host:$port';
    }
  } catch (_) {
    return null;
  } finally {
    client?.close(force: true);
  }

  return null;
}
