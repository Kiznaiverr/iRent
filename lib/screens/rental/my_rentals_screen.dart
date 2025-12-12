import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/rental_provider.dart';
import '../../models/rental_model.dart';
import '../../widgets/rental/index.dart';

class MyRentalsScreen extends ConsumerStatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  ConsumerState<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends ConsumerState<MyRentalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rentalProvider.notifier).getUserRentals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentalState = ref.watch(rentalProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          RentalAppBar(),

          // Content
          if (rentalState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rentalState.rentals.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B9FE8).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.devices_outlined,
                        size: 80,
                        color: const Color(0xFF6B9FE8).withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum ada rental aktif',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rental iPhone Anda akan muncul di sini',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final rental = rentalState.rentals[index];
                  return RentalCard(
                    rental: rental,
                    onTap: () => _showRentalDetails(rental),
                  );
                }, childCount: rentalState.rentals.length),
              ),
            ),
        ],
      ),
    );
  }

  void _showRentalDetails(RentalModel rental) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    DateTime? safeParseDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }

    final startDate = safeParseDate(rental.startDate);
    final endDate = safeParseDate(rental.endDate);
    final returnDate = safeParseDate(rental.returnDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Detail Rental',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 24),
                    RentalDetailRow(
                      icon: Icons.phone_iphone_rounded,
                      label: 'iPhone',
                      value: rental.iphone?.name ?? '-',
                    ),
                    RentalDetailRow(
                      icon: Icons.info_outline_rounded,
                      label: 'Status',
                      value: rental.statusLabel,
                    ),
                    RentalDetailRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Tanggal Mulai',
                      value: startDate != null
                          ? dateFormat.format(startDate)
                          : rental.startDate,
                    ),
                    RentalDetailRow(
                      icon: Icons.event_rounded,
                      label: 'Tanggal Selesai',
                      value: endDate != null
                          ? dateFormat.format(endDate)
                          : rental.endDate,
                    ),
                    if (returnDate != null)
                      RentalDetailRow(
                        icon: Icons.event_available_rounded,
                        label: 'Tanggal Pengembalian',
                        value: dateFormat.format(returnDate),
                      ),
                    if (rental.penalty > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red[50]!, Colors.red[100]!],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  color: Colors.red[700],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Total Denda',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[900],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatter.format(rental.penalty),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.red[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (rental.isOverdue)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.red[700],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Rental Anda telah melewati batas waktu. Segera kembalikan untuk menghindari denda tambahan.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (rental.isActive)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B9FE8).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFF6B9FE8,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF6B9FE8),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Pastikan mengembalikan iPhone dalam kondisi baik sesuai tenggat waktu.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
