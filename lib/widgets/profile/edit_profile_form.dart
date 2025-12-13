import 'package:flutter/material.dart';
import 'custom_text_field.dart';
import 'save_button.dart';

class EditProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nikController;
  final bool isLoading;
  final VoidCallback onSave;

  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.nikController,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: nameController,
            labelText: 'Nama Lengkap',
            prefixIcon: Icons.person,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Nama tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: usernameController,
            labelText: 'Username',
            prefixIcon: Icons.account_circle,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Username tidak boleh kosong' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: emailController,
            labelText: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: phoneController,
            labelText: 'Nomor Telepon',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty ?? true
                ? 'Nomor telepon tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: nikController,
            labelText: 'NIK (16 digit)',
            prefixIcon: Icons.badge,
            keyboardType: TextInputType.number,
            maxLength: 16,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'NIK tidak boleh kosong';
              }
              if (value.length != 16) {
                return 'NIK harus 16 digit';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SaveButton(isLoading: isLoading, onPressed: onSave),
        ],
      ),
    );
  }
}
