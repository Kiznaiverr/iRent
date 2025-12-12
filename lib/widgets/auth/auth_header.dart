import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

/// Auth header with gradient background and branding
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;
  final Widget? leading;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 260,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: height,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: leading,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        background: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).primaryGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [Theme.of(context).cardShadow],
                  ),
                  child: Icon(
                    Icons.phone_iphone_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(title, style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
