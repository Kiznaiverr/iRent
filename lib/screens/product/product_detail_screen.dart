import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import '../../providers/iphone_provider.dart';
import '../../models/iphone_model.dart';
import '../order/order_form_screen.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int iphoneId;

  const ProductDetailScreen({super.key, required this.iphoneId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(iphoneProvider.notifier).getIPhoneById(widget.iphoneId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final iphoneState = ref.watch(iphoneProvider);
    final iphone = iphoneState.selectedIPhone;

    if (iphoneState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail iPhone')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (iphone == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail iPhone')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'iPhone tidak ditemukan',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail iPhone')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(iphone),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceSection(iphone),
                  const SizedBox(height: 16),
                  _buildStockSection(iphone),
                  const SizedBox(height: 24),
                  _buildSpecsSection(iphone),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(iphone),
    );
  }

  Widget _buildImageCarousel(IPhoneModel iphone) {
    final images = iphone.images.isNotEmpty
        ? iphone.images
        : ['https://via.placeholder.com/400x400?text=No+Image'];

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            viewportFraction: 1.0,
            enableInfiniteScroll: images.length > 1,
            onPageChanged: (index, reason) {
              setState(() => _currentImageIndex = index);
            },
          ),
          items: images.map((imageUrl) {
            return CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.phone_iphone, size: 64)),
              ),
            );
          }).toList(),
        ),
        if (images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == entry.key
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(IPhoneModel iphone) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          iphone.name,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${formatter.format(iphone.pricePerDay)} / hari',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockSection(IPhoneModel iphone) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iphone.isAvailable ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: iphone.isAvailable ? Colors.green : Colors.red,
        ),
      ),
      child: Row(
        children: [
          Icon(
            iphone.isAvailable ? Icons.check_circle : Icons.cancel,
            color: iphone.isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  iphone.isAvailable ? 'Tersedia' : 'Stok Habis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iphone.isAvailable
                        ? Colors.green[900]
                        : Colors.red[900],
                  ),
                ),
                Text(
                  'Stok: ${iphone.stock} unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: iphone.isAvailable
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsSection(IPhoneModel iphone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spesifikasi',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(iphone.specs, style: const TextStyle(height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(IPhoneModel iphone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: iphone.isAvailable
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderFormScreen(iphone: iphone),
                    ),
                  ).then((result) {
                    // Jika result adalah 'orders', berarti order berhasil dibuat
                    if (result == 'orders' && mounted) {
                      // Navigate ke home screen dengan tab orders
                      Navigator.of(
                        context,
                      ).pushReplacementNamed('/home', arguments: {'tab': 1});
                    }
                  });
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            iphone.isAvailable ? 'Sewa Sekarang' : 'Stok Habis',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // ref.read(iphoneProvider.notifier).clearSelected(); // Removed to prevent dispose error
    super.dispose();
  }
}
