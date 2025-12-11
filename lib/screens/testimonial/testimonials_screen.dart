import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/testimonial_provider.dart';

class TestimonialsScreen extends ConsumerStatefulWidget {
  const TestimonialsScreen({super.key});

  @override
  ConsumerState<TestimonialsScreen> createState() =>
      _TestimonialsScreenState();
}

class _TestimonialsScreenState extends ConsumerState<TestimonialsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(testimonialProvider.notifier).getTestimonials();
    });
  }

  @override
  Widget build(BuildContext context) {
    final testimonialState = ref.watch(testimonialProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF6B9FE8),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Testimonial',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6B9FE8).withValues(alpha: 0.05),
                      const Color(0xFF8AB4F8).withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6B9FE8).withValues(alpha: 0.15),
                              const Color(0xFF8AB4F8).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.rate_review_rounded,
                          size: 40,
                          color: Color(0xFF6B9FE8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          testimonialState.isLoading
              ? SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : testimonialState.testimonials.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.star_outline_rounded,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Belum ada testimonial',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jadilah yang pertama memberikan ulasan',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final testimonial =
                                testimonialState.testimonials[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User Info
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF6B9FE8)
                                                .withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                          gradient: testimonial.profile ==
                                                      null ||
                                                  testimonial.profile!.isEmpty
                                              ? LinearGradient(
                                                  colors: [
                                                    const Color(0xFF6B9FE8)
                                                        .withValues(alpha: 0.8),
                                                    const Color(0xFF8AB4F8)
                                                        .withValues(alpha: 0.8),
                                                  ],
                                                )
                                              : null,
                                        ),
                                        child: testimonial.profile != null &&
                                                testimonial.profile!.isNotEmpty
                                            ? CircleAvatar(
                                                radius: 28,
                                                backgroundImage: NetworkImage(
                                                  testimonial.profile!,
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 28,
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: Text(
                                                  testimonial
                                                          .userName.isNotEmpty
                                                      ? testimonial.userName[0]
                                                          .toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              testimonial.userName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    const Color(0xFFFFA726)
                                                        .withValues(alpha: 0.15),
                                                    const Color(0xFFFFB74D)
                                                        .withValues(alpha: 0.1),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ...List.generate(5, (i) {
                                                    return Icon(
                                                      i < testimonial.rating
                                                          ? Icons.star_rounded
                                                          : Icons
                                                              .star_outline_rounded,
                                                      size: 16,
                                                      color: i <
                                                              testimonial.rating
                                                          ? const Color(
                                                              0xFFFFA726)
                                                          : Colors.grey[400],
                                                    );
                                                  }),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${testimonial.rating}.0',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFFFFA726),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      testimonial.content,
                                      style: const TextStyle(
                                        height: 1.6,
                                        fontSize: 14,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: testimonialState.testimonials.length,
                        ),
                      ),
                    ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6B9FE8),
              Color(0xFF8AB4F8),
            ],
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
          onPressed: () => _showAddTestimonialDialog(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.edit_rounded, color: Colors.white),
          label: const Text(
            'Tulis Testimonial',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTestimonialDialog() {
    final messageController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6B9FE8).withValues(alpha: 0.15),
                          const Color(0xFF8AB4F8).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rate_review_rounded,
                      color: Color(0xFF6B9FE8),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Tulis Testimonial',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rating',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFA726).withValues(alpha: 0.1),
                            const Color(0xFFFFB74D).withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFFFA726),
                              size: 36,
                            ),
                            onPressed: () {
                              setState(() => rating = index + 1);
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Pesan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tulis pengalaman Anda...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF6B9FE8),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6B9FE8),
                        Color(0xFF8AB4F8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (messageController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.warning_rounded,
                                    color: Colors.white),
                                SizedBox(width: 12),
                                Expanded(
                                    child: Text('Pesan tidak boleh kosong')),
                              ],
                            ),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                        return;
                      }

                      final success = await ref
                          .read(testimonialProvider.notifier)
                          .createTestimonial(
                            rating: rating,
                            message: messageController.text.trim(),
                          );

                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kirim',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
