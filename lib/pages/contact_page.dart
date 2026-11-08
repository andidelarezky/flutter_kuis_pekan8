import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/contact_cubit.dart';
import '../models/contact_model.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();

  // Form tambah dan edit kontak
  Future<void> _showContactDialog({
    Contact? contact,
  }) async {
    final nameController = TextEditingController(
      text: contact?.name ?? '',
    );

    final phoneController = TextEditingController(
      text: contact?.phone ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFDCE9F7),
                child: Icon(
                  Icons.person_add_alt_1,
                  color: Color(0xFF0759A5),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                contact == null
                    ? 'Tambah Kontak Baru'
                    : 'Edit Kontak',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    hintText: 'Contoh: Dela',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Contoh: 08162956522',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Nomor telepon tidak boleh kosong';
                    }

                    if (!RegExp(r'^[0-9+ -]+$')
                        .hasMatch(value.trim())) {
                      return 'Nomor telepon tidak valid';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      final newContact = Contact(
        id: contact?.id,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (contact == null) {
        await context.read<ContactCubit>().addContact(
          newContact,
        );
      } else {
        await context.read<ContactCubit>().editContact(
          newContact,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              contact == null
                  ? 'Kontak berhasil ditambahkan'
                  : 'Kontak berhasil diperbarui',
            ),
          ),
        );
      }
    }

    nameController.dispose();
    phoneController.dispose();
  }

  // Konfirmasi hapus kontak
  Future<void> _deleteContact(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kontak'),
          content: Text(
            'Apakah kamu yakin ingin menghapus ${contact.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await context.read<ContactCubit>().removeContact(
        contact.id!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kontak berhasil dihapus'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF0759A5),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kontak Telepon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Dengan SQLite & Cubit',
              style: TextStyle(fontSize: 11),
            ),
          ],
        ),
        actions: [
          BlocBuilder<ContactCubit, List<Contact>>(
            builder: (context, contacts) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${contacts.length} Kontak',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // Daftar kontak
      body: BlocBuilder<ContactCubit, List<Contact>>(
        builder: (context, contacts) {
          if (contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contact_phone,
                    size: 75,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Belum ada kontak tersimpan.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + di bawah untuk menambahkan\nkontak baru.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFDCE9F7),
                    child: Text(
                      contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF0759A5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(contact.phone),
                      ],
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 2,
                    children: [
                      IconButton(
                        onPressed: () {
                          _showContactDialog(
                            contact: contact,
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _deleteContact(contact);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // Tombol tambah kontak
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showContactDialog();
        },
        backgroundColor: const Color(0xFF0759A5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kontak'),
      ),
    );
  }
}