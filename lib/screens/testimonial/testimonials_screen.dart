import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/testimonial/index.dart';
import '../../providers/testimonial_provider.dart';

class TestimonialsScreen extends ConsumerStatefulWidget {
  const TestimonialsScreen({super.key});

  @override
  ConsumerState<TestimonialsScreen> createState() => _TestimonialsScreenState();
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
          const TestimonialAppBar(),

          // Content
          testimonialState.isLoading
              ? SliverFillRemaining(
                  child: Container(
                    padding: const EdgeInsets.all(48),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                )
              : testimonialState.testimonials.isEmpty
              ? const TestimonialEmptyState()
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final testimonial = testimonialState.testimonials[index];
                      return TestimonialCard(testimonial: testimonial);
                    }, childCount: testimonialState.testimonials.length),
                  ),
                ),
        ],
      ),
      floatingActionButton: const AddTestimonialButton(),
    );
  }
}
