import 'package:flutter/material.dart';
import 'package:flutter_application_10/Utilis/app_SnackBar.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая задача')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Введите название задачи',
                ),
                onSubmitted: (_) => _onSaveTap(),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSaving ? null : _onSaveTap,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveTap() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final title = saveTask();
      await showAppSnackBar(
        text: "Задача сохранена",
        backgroundColor: Colors.green,
        icon: Icons.check_box,
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.of(context).pop(title);
    } catch (error) {
      await showAppSnackBar(
        text: error.toString(),
        backgroundColor: Colors.red,
        icon: Icons.close_rounded,
      );
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String saveTask() {
    final title = _textEditingController.text.trim();

    if (title.isEmpty) {
      throw TaskTextException(message: "Текст не может быть пустым");
    } else if (title.length < 3) {
      throw TaskTextException(
        message: "Текст должен содержать хотя бы 3 символа",
      );
    }

    return title;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}

class TaskTextException implements Exception {
  String message;

  TaskTextException({required this.message});

  @override
  String toString() {
    return message;
  }
}
