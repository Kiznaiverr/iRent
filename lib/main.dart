import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/updater/update_screen.dart';
import 'providers/auth_provider.dart';
import 'services/update_service.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'iRent - iPhone Rental',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final initialTab = args?['tab'] as int? ?? 0;
          return HomeScreen(initialTab: initialTab);
        },
        '/update': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return UpdateScreen(
            latestVersion: args?['latestVersion'] ?? '',
            releaseNotes: args?['releaseNotes'] ?? '',
          );
        },
      },
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  bool _updateChecked = false;
  String? _latestVersion;
  String? _releaseNotes;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    try {
      final isUpdateAvailable = await UpdateService.isUpdateAvailable();
      if (isUpdateAvailable) {
        _latestVersion = await UpdateService.getLatestVersion();
        _releaseNotes = await UpdateService.getReleaseNotes() ?? '';
      }
    } catch (e) {
      // Error checking for updates
    } finally {
      setState(() {
        _updateChecked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Navigate berdasarkan authentication status setelah loading selesai dan update check selesai
    if (_updateChecked && !authState.isLoading && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (_latestVersion != null && _releaseNotes != null) {
            // Ada update, navigate ke update screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => UpdateScreen(
                  latestVersion: _latestVersion!,
                  releaseNotes: _releaseNotes!,
                ),
              ),
            );
          } else {
            // Tidak ada update, lanjut ke auth navigation
            if (authState.isAuthenticated) {
              Navigator.of(context).pushReplacementNamed('/home');
            } else {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          }
        }
      });
    }

    // Tampilkan splash screen
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_iphone,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'iRent',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'iPhone Rental Service',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
