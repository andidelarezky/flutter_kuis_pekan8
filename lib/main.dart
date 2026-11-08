import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/contact_cubit.dart';
import 'database/database_helper.dart';
import 'pages/contact_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database
  await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactCubit()..loadContacts(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kontak Telepon',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0759A5),
          ),
        ),
        home: const ContactPage(),
      ),
    );
  }
}