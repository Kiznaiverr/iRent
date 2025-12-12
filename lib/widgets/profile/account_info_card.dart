import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'info_item.dart';

class AccountInfoCard extends StatelessWidget {
  final UserModel user;

  const AccountInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Akun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 20),
            InfoItem(
              icon: Icons.person_rounded,
              label: 'Username',
              value: user.username,
            ),
            if (user.email != null && user.email!.isNotEmpty)
              InfoItem(
                icon: Icons.email_rounded,
                label: 'Email',
                value: user.email!,
              ),
            InfoItem(
              icon: Icons.phone_rounded,
              label: 'Telepon',
              value: user.phone,
            ),
            InfoItem(
              icon: Icons.badge_rounded,
              label: 'NIK',
              value: user.nik,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}
