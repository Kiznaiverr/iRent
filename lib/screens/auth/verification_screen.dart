import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isSendingOtp = false;
  bool _isVerifying = false;
  bool _otpSent = false;
  int _countdown = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserPhone();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _loadUserPhone() async {
    final authState = ref.read(authProvider);
    if (authState.user?.phone != null) {
      _phoneController.text = authState.user!.phone;
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nomor telepon tidak boleh kosong');
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .sendVerificationCode();
      if (success) {
        setState(() {
          _otpSent = true;
          _countdown = 60;
        });
        _startCountdown();
      } else {
        setState(() => _errorMessage = 'Gagal mengirim kode verifikasi');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Kode verifikasi harus 6 digit');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(authProvider.notifier).verifyCode(otp);
      if (success) {
        if (mounted) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nomor telepon berhasil diverifikasi!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        setState(() => _errorMessage = 'Kode verifikasi salah');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }

    // Auto verify when all fields are filled
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Verifikasi Nomor Telepon'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Header Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_android_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Verifikasi Nomor Telepon',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                _otpSent
                    ? 'Masukkan kode verifikasi yang dikirim ke WhatsApp'
                    : 'Kami akan mengirim kode verifikasi ke nomor WhatsApp Anda',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF718096),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Phone Input (only show if not sent yet)
              if (!_otpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: '081234567890',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),

                const SizedBox(height: 24),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSendingOtp ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSendingOtp
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Kirim Kode Verifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],

              // OTP Input (only show after OTP sent)
              if (_otpSent) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 45,
                      height: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Countdown and Resend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _countdown > 0
                          ? 'Kirim ulang dalam $_countdown detik'
                          : 'Tidak menerima kode?',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 14,
                      ),
                    ),
                    if (_countdown == 0) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _sendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Kirim Ulang',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
