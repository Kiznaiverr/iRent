import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/iphone_model.dart';
import '../../widgets/order/index.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  final IPhoneModel iphone;

  const OrderFormScreen({super.key, required this.iphone});

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  double get _totalPrice {
    return widget.iphone.pricePerDay * _totalDays;
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B9FE8),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Pilih tanggal mulai terlebih dahulu')),
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

    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: _startDate!.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B9FE8),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Pilih tanggal mulai dan selesai')),
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

    final dateFormat = DateFormat('yyyy-MM-dd');
    final success = await ref
        .read(orderProvider.notifier)
        .createOrder(
          iphoneId: widget.iphone.id,
          startDate: dateFormat.format(_startDate!),
          endDate: dateFormat.format(_endDate!),
        );

    if (success && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop('orders');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const OrderFormAppBar(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // iPhone Info Card
                    IPhoneInfoCard(iphone: widget.iphone),
                    const SizedBox(height: 24),

                    // Section Title
                    const SectionTitleWithLine(title: 'Pilih Periode Sewa'),
                    const SizedBox(height: 16),

                    // Date Cards
                    DatePickerCard(
                      title: 'Tanggal Mulai Sewa',
                      selectedDate: _startDate != null
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : null,
                      placeholder: 'Pilih tanggal mulai',
                      onTap: _selectStartDate,
                    ),
                    const SizedBox(height: 16),
                    DatePickerCard(
                      title: 'Tanggal Selesai Sewa',
                      selectedDate: _endDate != null
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : null,
                      placeholder: 'Pilih tanggal selesai',
                      onTap: _selectEndDate,
                      isEnabled: _startDate != null,
                    ),
                    const SizedBox(height: 24),

                    // Summary
                    if (_totalDays > 0)
                      OrderSummaryCard(
                        totalDays: _totalDays,
                        pricePerDay: widget.iphone.pricePerDay,
                        totalPrice: _totalPrice,
                      ),
                    const SizedBox(height: 24),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue[700],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pesanan akan diproses setelah admin menyetujui. Notifikasi dikirim via WhatsApp.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    OrderSubmitButton(
                      text: 'Buat Pesanan',
                      onPressed: _submitOrder,
                      isLoading: orderState.isLoading,
                      isEnabled: _startDate != null && _endDate != null,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
