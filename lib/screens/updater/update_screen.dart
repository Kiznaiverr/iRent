import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../services/update_service.dart';
import '../../theme/colors.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  final String latestVersion;
  final String releaseNotes;

  const UpdateScreen({
    super.key,
    required this.latestVersion,
    required this.releaseNotes,
  });

  @override
  ConsumerState<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String? _downloadPath;
  String? _taskId;

  @override
  void initState() {
    super.initState();
    // FlutterDownloader already initialized in main.dart
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    // This will be called by the downloader isolate
  }

  Future<void> _startDownload() async {
    debugPrint('Starting download process...');
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final downloadUrl = await UpdateService.getDownloadUrl(
        widget.latestVersion,
      );
      if (downloadUrl == null) {
        debugPrint('No download URL available');
        _showError('Failed to get download URL');
        return;
      }

      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        debugPrint('Could not get external storage directory');
        _showError('Failed to get storage directory');
        return;
      }

      final fileName = 'iRent-v${widget.latestVersion}.apk';
      final savePath = '${directory.path}/$fileName';
      debugPrint('Download path: $savePath');

      _taskId = await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: directory.path,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: false,
      );

      if (_taskId != null) {
        debugPrint('Download task created with ID: $_taskId');
        _downloadPath = savePath;
        _monitorDownload(_taskId!);
      } else {
        debugPrint('Failed to create download task');
      }
    } catch (e) {
      debugPrint('Download failed: $e');
      _showError('Download failed: $e');
    }
  }

  void _monitorDownload(String taskId) {
    debugPrint('Starting download monitoring for task: $taskId');
    FlutterDownloader.registerCallback((id, status, progress) {
      if (id == taskId) {
        setState(() {
          _downloadProgress = progress / 100.0;
        });

        final taskStatus = DownloadTaskStatus.values[status];
        debugPrint('Download progress: $progress% (Status: $taskStatus)');
        if (taskStatus == DownloadTaskStatus.complete) {
          debugPrint('Download completed successfully');
          _onDownloadComplete();
        } else if (taskStatus == DownloadTaskStatus.failed) {
          debugPrint('Download failed');
          _showError('Download failed');
        }
      }
    });
  }

  void _onDownloadComplete() {
    setState(() {
      _isDownloading = false;
    });

    if (_downloadPath != null) {
      _showInstallDialog();
    }
  }

  void _showInstallDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Download Complete'),
        content: const Text('APK downloaded successfully. Install now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(onPressed: _installApk, child: const Text('Install')),
        ],
      ),
    );
  }

  Future<void> _installApk() async {
    if (_downloadPath == null) {
      debugPrint('No download path available for installation');
      return;
    }

    debugPrint('Starting APK installation: $_downloadPath');
    try {
      final result = await OpenFile.open(_downloadPath!);
      debugPrint('Install result: ${result.type} - ${result.message}');
      if (result.type != ResultType.done) {
        _showError('Failed to install APK. Please check your device settings.');
      } else {
        debugPrint('APK installation initiated successfully');
      }
    } catch (e) {
      debugPrint('Installation failed: $e');
      _showError('Installation failed: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _isDownloading = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Update'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Update Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.system_update,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'New Version Available!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Version ${widget.latestVersion}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'What\'s New:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.releaseNotes.isNotEmpty
                          ? widget.releaseNotes
                          : 'No release notes available.',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Download Section
            if (_isDownloading) ...[
              const Text(
                'Downloading...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_downloadProgress * 100).toInt()}%',
                style: const TextStyle(fontSize: 14),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('Download Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Skip Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip for Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_taskId != null) {
      FlutterDownloader.cancel(taskId: _taskId!);
    }
    super.dispose();
  }
}
