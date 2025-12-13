import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/rental_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/rental_model.dart';
import '../../models/overdue_rental_model.dart';
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
    final authState = ref.watch(authProvider);

    // Get overdue rentals from user penalty info
    final overdueRentals = authState.user?.penaltyInfo?.overdueRentals ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          RentalAppBar(),

          // Overdue Rentals Section (if any)
          if (overdueRentals.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rental Terlambat (${overdueRentals.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Perlu segera dikembalikan untuk menghindari denda tambahan',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

          if (overdueRentals.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final overdue = overdueRentals[index];
                  return OverdueRentalCard(
                    overdue: overdue,
                    onTap: () => _showOverdueDetails(overdue),
                  );
                }, childCount: overdueRentals.length),
              ),
            ),

          // Active Rentals Section Header (if both overdue and active exist)
          if (overdueRentals.isNotEmpty && rentalState.rentals.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green[700],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rental Aktif (${rentalState.rentals.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rental yang sedang berlangsung',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

          // Content
          if (rentalState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rentalState.rentals.isEmpty && overdueRentals.isEmpty)
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

  void _showOverdueDetails(OverdueRental overdue) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rental Terlambat',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              Text(
                                overdue.iphoneName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Rental ini telah melewati batas waktu pengembalian. Segera kembalikan untuk menghindari denda tambahan.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detail Information
                    const Text(
                      'Detail Rental',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rental Details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          RentalDetailRow(
                            icon: Icons.confirmation_number,
                            label: 'ID Rental',
                            value: overdue.rentalId.toString(),
                          ),
                          const SizedBox(height: 12),
                          RentalDetailRow(
                            icon: Icons.phone_iphone,
                            label: 'iPhone',
                            value: overdue.iphoneName,
                          ),
                          const SizedBox(height: 12),
                          RentalDetailRow(
                            icon: Icons.receipt_long,
                            label: 'Kode Order',
                            value: overdue.orderCode,
                          ),
                          const SizedBox(height: 12),
                          RentalDetailRow(
                            icon: Icons.calendar_view_day,
                            label: 'Hari Terlambat',
                            value: '${overdue.daysOverdue} hari',
                          ),
                          const SizedBox(height: 12),
                          RentalDetailRow(
                            icon: Icons.attach_money,
                            label: 'Denda per Hari',
                            value: formatter.format(overdue.dailyPenalty),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Penalty Information
                    const Text(
                      'Informasi Denda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
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
                                formatter.format(overdue.penaltyAmount),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Denda akan terus bertambah setiap hari keterlambatan hingga iPhone dikembalikan.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Admin handled message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pengembalian iPhone ditangani oleh admin. Silakan hubungi admin untuk proses pengembalian.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
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
