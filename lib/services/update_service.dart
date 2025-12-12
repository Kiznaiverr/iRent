import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:version/version.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class UpdateService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/Kiznaiverr/iRent/releases/latest';

  /// Get current app version
  static Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    debugPrint('Current app version: $version');
    return version;
  }

  /// Fetch latest version from GitHub releases
  static Future<String?> getLatestVersion() async {
    try {
      debugPrint('Checking for latest version from GitHub...');
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tagName = data['tag_name'] as String?;
        if (tagName != null) {
          // Remove 'v' prefix if present and handle beta versions
          final cleanVersion = tagName.startsWith('v')
              ? tagName.substring(1)
              : tagName;
          debugPrint('Latest version from GitHub: $cleanVersion');
          return cleanVersion;
        }
      } else {
        debugPrint(
          'Failed to fetch latest version. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching latest version: $e');
    }
    return null;
  }

  /// Check if update is available
  static Future<bool> isUpdateAvailable() async {
    final currentVersion = await getCurrentVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == null) {
      debugPrint('Could not determine latest version');
      return false;
    }

    try {
      final isUpdate =
          Version.parse(latestVersion) > Version.parse(currentVersion);
      debugPrint(
        'Update available: $isUpdate (Current: $currentVersion, Latest: $latestVersion)',
      );
      return isUpdate;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }

  /// Get download URL for APK
  static Future<String?> getDownloadUrl(String version) async {
    try {
      debugPrint('Getting download URL for version: $version');
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final assets = data['assets'] as List?;
        if (assets != null) {
          for (var asset in assets) {
            final name = asset['name'] as String?;
            if (name != null && name.endsWith('.apk')) {
              final url = asset['browser_download_url'] as String?;
              debugPrint('Download URL found: $url');
              return url;
            }
          }
        }
        debugPrint('No APK asset found in release');
      } else {
        debugPrint(
          'Failed to get release info. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting download URL: $e');
    }
    return null;
  }

  /// Get release notes
  static Future<String?> getReleaseNotes() async {
    try {
      debugPrint('Getting release notes...');
      final response = await http.get(Uri.parse(_githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notes = data['body'] as String?;
        if (notes != null && notes.isNotEmpty) {
          debugPrint('Release notes found (${notes.length} characters)');
        } else {
          debugPrint('No release notes found');
        }
        return notes;
      } else {
        debugPrint(
          'Failed to get release notes. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error getting release notes: $e');
    }
    return null;
  }
}
