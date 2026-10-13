import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'bloc/keranjang_bloc.dart';
import 'cubit/keranjang_cubit.dart';
import 'pages/versi_bloc.dart';
import 'pages/versi_cubit.dart';
import 'pages/versi_provider.dart';
import 'provider/keranjang_provider.dart';

void main() => runApp(const AplikasiKantin());

class AplikasiKantin extends StatelessWidget {
  const AplikasiKantin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kantin Kampus',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HalamanPilihVersi(),
    );
  }
}

// Halaman awal: pilih mau mencoba versi Provider, Cubit, atau BLoC.
class HalamanPilihVersi extends StatelessWidget {
  const HalamanPilihVersi({super.key});

  void _buka(BuildContext context, Widget halaman) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => halaman));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kantin Kampus - Modul 5')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton(
              // ChangeNotifierProvider menyediakan KeranjangProvider untuk semua widget di bawahnya.
              onPressed: () => _buka(
                context,
                ChangeNotifierProvider(
                  create: (_) => KeranjangProvider(),
                  child: const KantinProvider(),
                ),
              ),
              child: const Text('Versi Provider'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              // BlocProvider menyediakan KeranjangCubit untuk semua widget di bawahnya.
              onPressed: () => _buka(
                context,
                BlocProvider(
                  create: (_) => KeranjangCubit(),
                  child: const KantinCubit(),
                ),
              ),
              child: const Text('Versi Cubit'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _buka(
                context,
                BlocProvider(
                  create: (_) => KeranjangBloc(),
                  child: const KantinBloc(),
                ),
              ),
              child: const Text('Versi BLoC'),
            ),
          ],
        ),
      ),
    );
  }
}
