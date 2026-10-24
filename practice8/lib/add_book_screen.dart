import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _pages.dispose();
    _year.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _save() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    final book = Book(
      title: _title.text.trim(),
      author: _author.text.trim(),
      pages: int.parse(_pages.text.trim()),
      year: int.tryParse(_year.text.trim()),
    );

    _unfocus();
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add book')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) => _unfocus(),
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'Title is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _author,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) => _unfocus(),
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Enter an author';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pages,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onTapOutside: (_) => _unfocus(),
                decoration: const InputDecoration(labelText: 'Pages'),
                validator: (value) {
                  final n = int.tryParse((value ?? '').trim());
                  if (n == null || n <= 0) {
                    return 'A whole number above 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _year,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                onTapOutside: (_) => _unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Year',
                  helperText: 'Optional',
                ),
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) {
                    return null;
                  }

                  final n = int.tryParse(text);
                  final currentYear = DateTime.now().year;
                  if (n == null || n < 1450 || n > currentYear) {
                    return 'Enter a year from 1450 to $currentYear';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
