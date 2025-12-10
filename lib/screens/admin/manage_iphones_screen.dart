import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/admin_provider.dart';
import '../../models/iphone_model.dart';

class ManageIphonesScreen extends ConsumerStatefulWidget {
  const ManageIphonesScreen({super.key});

  @override
  ConsumerState<ManageIphonesScreen> createState() =>
      _ManageIphonesScreenState();
}

class _ManageIphonesScreenState extends ConsumerState<ManageIphonesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllIPhones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola iPhone')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).getAllIPhones(),
        child: adminState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminState.iphones.isEmpty
            ? const Center(child: Text('Belum ada produk iPhone'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: adminState.iphones.length,
                itemBuilder: (context, index) {
                  final iphone = adminState.iphones[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        ListTile(
                          leading: iphone.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    iphone.images.first,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        const Icon(Icons.phone_iphone),
                                  ),
                                )
                              : const Icon(Icons.phone_iphone),
                          title: Text(iphone.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rp ${iphone.pricePerDay}/hari'),
                              Text('Stock: ${iphone.stock}'),
                              Text(
                                iphone.status.toUpperCase(),
                                style: TextStyle(
                                  color: iphone.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditDialog(iphone);
                              } else if (value == 'stock') {
                                _showAddStockDialog(iphone);
                              } else if (value == 'toggle_status') {
                                _toggleStatus(iphone);
                              } else if (value == 'delete') {
                                _confirmDelete(iphone);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'stock',
                                child: Row(
                                  children: [
                                    Icon(Icons.add_box, size: 20),
                                    SizedBox(width: 8),
                                    Text('Tambah Stock'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle_status',
                                child: Row(
                                  children: [
                                    const Icon(Icons.toggle_on, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      iphone.isAvailable
                                          ? 'Nonaktifkan'
                                          : 'Aktifkan',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah iPhone'),
      ),
    );
  }

  void _showCreateDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final specsController = TextEditingController();
    List<File> selectedImages = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah iPhone'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama iPhone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga per Hari',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stock',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: specsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Spesifikasi (pisahkan dengan koma)',
                        border: OutlineInputBorder(),
                        hintText: '128GB, 6.1", A15 Bionic',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final images = await picker.pickMultiImage();
                        if (images.isNotEmpty) {
                          setState(() {
                            selectedImages = images
                                .map((img) => File(img.path))
                                .toList();
                          });
                        }
                      },
                      icon: const Icon(Icons.image),
                      label: Text(
                        selectedImages.isEmpty
                            ? 'Pilih Gambar'
                            : '${selectedImages.length} gambar dipilih',
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
                    if (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        stockController.text.isEmpty ||
                        selectedImages.isEmpty) {
                      Fluttertoast.showToast(
                        msg: 'Lengkapi semua field dan pilih gambar',
                      );
                      return;
                    }

                    final specs = specsController.text
                        .split(',')
                        .map((s) => s.trim())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    final success = await ref
                        .read(adminProvider.notifier)
                        .createIPhone(
                          name: nameController.text,
                          pricePerDay: int.parse(
                            priceController.text,
                          ).toDouble(),
                          stock: int.parse(stockController.text),
                          specs: specs.join(', '),
                          imagePath: selectedImages.isNotEmpty
                              ? selectedImages.first.path
                              : null,
                        );

                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDialog(IPhoneModel iphone) {
    final nameController = TextEditingController(text: iphone.name);
    final priceController = TextEditingController(
      text: iphone.pricePerDay.toString(),
    );
    final specsController = TextEditingController(text: iphone.specs);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit iPhone'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama iPhone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Hari',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: specsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Spesifikasi (pisahkan dengan koma)',
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
                final specs = specsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final success = await ref
                    .read(adminProvider.notifier)
                    .updateIPhone(iphone.id, {
                      'name': nameController.text,
                      'price_per_day': int.parse(priceController.text),
                      'specs': specs.join(', '),
                    });

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAddStockDialog(IPhoneModel iphone) {
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Stock ${iphone.name}'),
          content: TextField(
            controller: stockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Stock',
              border: const OutlineInputBorder(),
              helperText: 'Stock saat ini: ${iphone.stock}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (stockController.text.isEmpty) {
                  return;
                }

                final success = await ref
                    .read(adminProvider.notifier)
                    .addStock(iphone.id, int.parse(stockController.text));

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _toggleStatus(IPhoneModel iphone) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${iphone.isAvailable ? 'Nonaktifkan' : 'Aktifkan'} ${iphone.name}',
          ),
          content: Text(
            'Apakah Anda yakin ingin ${iphone.isAvailable ? 'menonaktifkan' : 'mengaktifkan'} produk ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(adminProvider.notifier)
                    .updateIPhone(iphone.id, {
                      'status': iphone.isAvailable ? 'inactive' : 'active',
                    });

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(iphone.isAvailable ? 'Nonaktifkan' : 'Aktifkan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(IPhoneModel iphone) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus iPhone'),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${iphone.name}? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(adminProvider.notifier)
                    .deleteIPhone(iphone.id);

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
