import 'package:flutter/material.dart';

class OrderFilterChip extends StatelessWidget {
  final String currentFilter;
  final String currentSort;
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;

  const OrderFilterChip({
    super.key,
    required this.currentFilter,
    required this.currentSort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            // Filter Status
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_list_rounded,
                        color: Color(0xFFFF9800),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getFilterLabel(currentFilter),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: onFilterChanged,
                  itemBuilder: (context) => [
                    _buildMenuItem('all', 'Semua'),
                    _buildMenuItem('pre_ordered', 'Pre-Ordered'),
                    _buildMenuItem('approved', 'Approved'),
                    _buildMenuItem('completed', 'Completed'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Sort
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sort_rounded,
                        color: Color(0xFFFF9800),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentSort == 'newest' ? 'Terbaru' : 'Terlama',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: onSortChanged,
                  itemBuilder: (context) => [
                    _buildMenuItem('newest', 'Terbaru'),
                    _buildMenuItem('oldest', 'Terlama'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label) {
    return PopupMenuItem(value: value, child: Text(label));
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'pre_ordered':
        return 'Pre-Ordered';
      case 'approved':
        return 'Approved';
      case 'completed':
        return 'Completed';
      default:
        return 'Semua';
    }
  }
}
