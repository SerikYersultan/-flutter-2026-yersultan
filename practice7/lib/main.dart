import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  final _emailFocus = FocusNode();

  int _passwordLength = 0;
  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _birthController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _pickBirthDate() async {
    _unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked == null) {
      return;
    }
    if (mounted == false) {
      return;
    }

    setState(() {
      _birth = picked;
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      _birthController.text = '$day.$month.${picked.year}';
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() == false) {
      return;
    }

    _unfocus();

    setState(() {
      _done = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Account created')));
  }

  void _startOver() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthController.clear();
      _passwordLength = 0;
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          name: _name.text.trim(),
          email: _email.text.trim(),
          group: _group ?? '',
          birthDate: _birthController.text,
        ),
        const SizedBox(height: 24),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: (_) => _unfocus(),
            validator: (value) {
              if ((value ?? '').trim().length < 2) {
                return 'Name is too short';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => _unfocus(),
            validator: (value) {
              final email = (value ?? '').trim();
              final atIndex = email.indexOf('@');

              if (atIndex < 0 || email.indexOf('.', atIndex + 1) < 0) {
                return 'Email looks wrong';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => _unfocus(),
            validator: (value) {
              if ((value ?? '').length < 8) {
                return 'Password is too short';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            onChanged: (value) {
              setState(() {
                _passwordLength = value.length;
              });
            },
          ),
          const SizedBox(height: 4),
          Text(
            '$_passwordLength of 8',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _agreed ? (_) => _submit() : null,
            onTapOutside: (_) => _unfocus(),
            validator: (value) {
              final confirmation = value ?? '';

              if (confirmation.isEmpty) {
                return 'Confirm your password';
              }
              if (confirmation != _password.text) {
                return 'Passwords do not match';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final group in groups)
                DropdownMenuItem(value: group, child: Text(group)),
            ],
            onChanged: (value) {
              setState(() {
                _group = value;
              });
            },
            validator: (value) {
              return value == null ? 'Choose a group' : null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _birthController,
            readOnly: true,
            onTap: _pickBirthDate,
            onTapOutside: (_) => _unfocus(),
            validator: (_) {
              return _birth == null ? 'Choose your birth date' : null;
            },
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              hintText: 'dd.mm.yyyy',
              suffixIcon: Icon(Icons.calendar_month),
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text('I agree to the rules'),
            value: _agreed,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _agreed = value ?? false;
              });
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _submit : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _done ? _buildSummary() : _buildForm(),
      ),
    );
  }
}
