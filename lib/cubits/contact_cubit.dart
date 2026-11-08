import 'package:flutter_bloc/flutter_bloc.dart';

import '../database/database_helper.dart';
import '../models/contact_model.dart';

class ContactCubit extends Cubit<List<Contact>> {
  ContactCubit() : super([]);

  // Mengambil data kontak
  Future<void> loadContacts() async {
    final data =
        await DatabaseHelper.instance.getContacts();

    final contacts = data
        .map((item) => Contact.fromMap(item))
        .toList();

    emit(contacts);
  }

  // Menambahkan kontak
  Future<void> addContact(Contact contact) async {
    await DatabaseHelper.instance.insertContact(
      contact.toMap(),
    );

    await loadContacts();
  }

  // Mengedit kontak
  Future<void> editContact(Contact contact) async {
    await DatabaseHelper.instance.updateContact(
      contact.id!,
      contact.toMap(),
    );

    await loadContacts();
  }

  // Menghapus kontak
  Future<void> removeContact(int id) async {
    await DatabaseHelper.instance.deleteContact(id);

    await loadContacts();
  }
}