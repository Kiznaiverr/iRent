import 'package:flutter/material.dart';
import 'add_testimonial_dialog.dart';

class AddTestimonialButton extends StatelessWidget {
  const AddTestimonialButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B9FE8), Color(0xFF8AB4F8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B9FE8).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddTestimonialDialog(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text(
          'Tulis Testimonial',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showAddTestimonialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTestimonialDialog(),
    );
  }
}
