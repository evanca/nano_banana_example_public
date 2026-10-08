import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/fotoautomat/fotoautomat.dart';
import '../shared/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key, required this.createBooth});

  final BoothCubit Function() createBooth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Berlin Fotoautomat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: BlocProvider(create: (_) => createBooth(), child: const BoothPage()),
    );
  }
}
