import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/iphone_provider.dart';
import '../order/my_orders_screen.dart';
import '../rental/my_rentals_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../widgets/home/index.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const HomeScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'iPhone 15',
    'iPhone 14',
    'iPhone 13',
    'iPhone 12',
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    Future.microtask(() {
      ref.read(iphoneProvider.notifier).getActiveIPhones();
      // Load profile saat home screen dibuka
      ref.read(authProvider.notifier).getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (!authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If user profile is still loading, show loading indicator
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('iRent'),
        actions: [
          if (user.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      drawer: CustomDrawer(
        user: user,
        currentIndex: _currentIndex,
        onNavigate: (index) => setState(() => _currentIndex = index),
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MyOrdersScreen();
      case 2:
        return const MyRentalsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final iphoneState = ref.watch(iphoneProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Filter iPhones based on search and category
    final filteredIPhones = iphoneState.iphones.where((iphone) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          iphone.name.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'All' ||
          iphone.name.contains(_selectedCategory.replaceAll('iPhone ', ''));
      return matchesSearch && matchesCategory;
    }).toList();

    // Get featured iPhones (first 5 available)
    final featuredIPhones = iphoneState.iphones.take(5).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(iphoneProvider.notifier).getActiveIPhones(),
      child: CustomScrollView(
        slivers: [
          // Hero Header
          HeroHeader(userName: user?.name ?? 'User'),

          // Search Bar
          SearchBarWidget(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
          ),

          // Category Filter
          CategoryFilter(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) =>
                setState(() => _selectedCategory = category),
          ),

          // Featured Carousel
          FeaturedCarousel(featuredIPhones: featuredIPhones),

          // Section Title
          SectionTitle(
            title: 'Semua iPhone',
            subtitle: '${filteredIPhones.length} produk',
          ),

          // Loading State
          if (iphoneState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          // Empty State
          else if (filteredIPhones.isEmpty)
            EmptyState(
              icon:
                  _searchController.text.isNotEmpty ||
                      _selectedCategory != 'All'
                  ? 'search'
                  : 'phone',
              title:
                  _searchController.text.isNotEmpty ||
                      _selectedCategory != 'All'
                  ? 'Tidak ada iPhone ditemukan'
                  : 'Belum ada iPhone tersedia',
              subtitle:
                  _searchController.text.isNotEmpty ||
                      _selectedCategory != 'All'
                  ? 'Coba kata kunci atau filter lain'
                  : 'iPhone akan segera tersedia',
            )
          // Product Grid
          else
            ProductGrid(products: filteredIPhones),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}
