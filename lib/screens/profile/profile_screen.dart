import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile/index.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile saat pertama kali masuk
    Future.microtask(() => ref.read(authProvider.notifier).getProfile());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    debugPrint(
      'ProfileScreen - User: ${user.name}, phoneVerified: ${user.phoneVerified}, isActive: ${user.isActive}, penalty: ${user.penalty}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () => ref.read(authProvider.notifier).getProfile(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Custom App Bar with Profile Header
            ProfileHeader(
              user: user,
              onEditProfile: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              onChangePhoto: () => _showPhotoOptions(context, ref),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Status Warnings
                    StatusWarnings(
                      user: user,
                      onVerifyPhone: () {
                        Navigator.pushNamed(context, '/verify-phone');
                      },
                    ),
                    if (user.penalty > 0 ||
                        !user.isActive ||
                        (user.phoneVerified != null && !user.phoneVerified!))
                      const SizedBox(height: 16),

                    // Account Information Card
                    AccountInfoCard(user: user),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pilih Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 20),
                PhotoOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Ambil Foto',
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                    if (image != null) {
                      await ref
                          .read(authProvider.notifier)
                          .uploadProfilePhoto(image.path);
                    }
                  },
                ),
                PhotoOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Pilih dari Galeri',
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                      maxWidth: 1024,
                      maxHeight: 1024,
                    );
                    if (image != null) {
                      await ref
                          .read(authProvider.notifier)
                          .uploadProfilePhoto(image.path);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
