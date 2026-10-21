import 'dart:async';

import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _textEditingController =
      TextEditingController();
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final date = DateTime.now();
      debugPrint('${date.minute} : ${date.second}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая задача'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Введите название задачи',
                ),
                onSubmitted: (_) => _onSaveTap(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _onSaveTap,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveTap() {
    final task = _textEditingController.text.trim();
    if (task.isEmpty) return;

    Navigator.of(context).pop(task);
  }

  @override
  void dispose() {
    _timer.cancel();
    _textEditingController.dispose();
    super.dispose();
  }
}
