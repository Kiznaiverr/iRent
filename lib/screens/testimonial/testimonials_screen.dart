import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(title: const Text('Testimonial')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(testimonialProvider.notifier).getTestimonials(),
        child: testimonialState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : testimonialState.testimonials.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada testimonial',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: testimonialState.testimonials.length,
                itemBuilder: (context, index) {
                  final testimonial = testimonialState.testimonials[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              testimonial.profile != null &&
                                      testimonial.profile!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        testimonial.profile!,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      child: Text(
                                        testimonial.userName.isNotEmpty
                                            ? testimonial.userName[0]
                                                  .toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      testimonial.userName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < testimonial.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            testimonial.content,
                            style: const TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTestimonialDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tulis Testimonial'),
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
              title: const Text('Tulis Testimonial'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() => rating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: messageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Pesan',
                        hintText: 'Tulis pengalaman Anda...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (messageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pesan tidak boleh kosong'),
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
                  child: const Text('Kirim'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
