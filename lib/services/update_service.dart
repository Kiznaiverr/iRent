import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/Kiznaiverr/iRent/releases/latest';

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Fetch latest version from GitHub releases
  static Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tagName = data['tag_name'] as String?;
        if (tagName != null) {
          // Remove 'v' prefix if present and handle beta versions
          return tagName.startsWith('v') ? tagName.substring(1) : tagName;
        }
      }
    } catch (e) {
      // Error fetching latest version
    }
    return null;
  }

  /// Check if update is available
  static Future<bool> isUpdateAvailable() async {
    final currentVersion = await getCurrentVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == null) return false;

    try {
      return Version.parse(latestVersion) > Version.parse(currentVersion);
    } catch (e) {
      // Error comparing versions
      return false;
    }
  }

  /// Get download URL for APK
  static Future<String?> getDownloadUrl(String version) async {
    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assets = data['assets'] as List?;
        if (assets != null) {
          for (var asset in assets) {
            final name = asset['name'] as String?;
            if (name != null && name.endsWith('.apk')) {
              return asset['browser_download_url'] as String?;
            }
          }
        }
      }
    } catch (e) {
      // Error getting download URL
      return null;
    }
    return null;
  }

  /// Get release notes
  static Future<String?> getReleaseNotes() async {
    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['body'] as String?;
      }
    } catch (e) {
      // Error getting release notes
      return null;
    }
    return null;
  }
}
