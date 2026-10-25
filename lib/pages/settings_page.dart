import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<SettingsCubit, bool>(
        builder: (context, isDarkTheme) => SwitchListTile(
          title: const Text('Тёмная тема'),
          value: isDarkTheme,
          onChanged: context.read<SettingsCubit>().setDarkTheme,
        ),
      ),
    );
  }
}
