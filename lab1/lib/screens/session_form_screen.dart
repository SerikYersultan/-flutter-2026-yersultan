import 'package:flutter/material.dart';

import '../models/exchange_language.dart';
import '../models/exchange_session.dart';
import '../utils/format.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, this.session});

  final ExchangeSession? session;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late final ExchangeSession _initial;
  late final TextEditingController _titleController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;

  late ExchangeLanguage _language;
  late bool _online;
  late DateTime _date;
  late TimeOfDay _time;

  bool get _editing => widget.session != null;

  DateTime get _when => DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

  @override
  void initState() {
    super.initState();
    _initial = widget.session ?? ExchangeSession.empty();
    _titleController = TextEditingController(text: _initial.title);
    _placeController = TextEditingController(text: _initial.place);
    _limitController = TextEditingController(text: '${_initial.limit}');
    _descriptionController = TextEditingController(
      text: _initial.description ?? '',
    );
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _language = _initial.language;
    _online = _initial.online;
    _date = DateUtils.dateOnly(_initial.when);
    _time = TimeOfDay.fromDateTime(_initial.when);
    _syncDateText();
  }

  void _syncDateText() {
    _dateController.text = '${_date.day} '
        '${formatDateTime(_date).split(',').first.split(' ').last} '
        '${_date.year}';
    _timeController.text = '${_time.hour.toString().padLeft(2, '0')}:'
        '${_time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _placeController,
      _limitController,
      _descriptionController,
      _dateController,
      _timeController,
    ]) {
      controller.dispose();
    }
    for (final focus in [
      _titleFocus,
      _placeFocus,
      _limitFocus,
      _descriptionFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    return title.length < 3 || title.length > 60 ? 'Use 3–60 characters' : null;
  }

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();
    if (place.isEmpty) {
      return _online ? 'Enter a meeting link' : 'Enter a meeting place';
    }
    if (_online && !place.contains('://')) {
      return 'The link must contain ://';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse((value ?? '').trim());
    if (limit == null || limit < 1 || limit > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    if (_editing && limit < _initial.count) {
      return 'At least ${_initial.count} places are required';
    }
    return null;
  }

  String? _validateSchedule(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Required';
    }
    if (!_editing && !_when.isAfter(DateTime.now())) {
      return 'Choose a future date and time';
    }
    return null;
  }

  Future<void> _pickDate() async {
    _dismissKeyboard();
    final today = DateUtils.dateOnly(DateTime.now());
    final firstDate = _date.isBefore(today) ? _date : today;
    final futureBound = DateTime(today.year + 10, 12, 31);
    final lastDate = _date.isAfter(futureBound) ? _date : futureBound;
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _date = selected;
      _syncDateText();
    });
  }

  Future<void> _pickTime() async {
    _dismissKeyboard();
    final selected = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (!mounted || selected == null) {
      return;
    }
    setState(() {
      _time = selected;
      _syncDateText();
    });
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }
    _dismissKeyboard();

    final description = _descriptionController.text.trim();
    final result = _initial.copyWith(
      id: _editing
          ? _initial.id
          : 'session-${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      language: _language,
      when: _when,
      limit: int.parse(_limitController.text.trim()),
      online: _online,
      place: _placeController.text.trim(),
      description: description,
      clearDescription: description.isEmpty,
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit session' : 'New session'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                focusNode: _titleFocus,
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onTapOutside: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(labelText: 'Title'),
                validator: _validateTitle,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ExchangeLanguage>(
                initialValue: _language,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Language'),
                items: [
                  for (final language in ExchangeLanguage.values)
                    DropdownMenuItem(
                      value: language,
                      child: Text(language.label),
                    ),
                ],
                validator: (value) =>
                    value == null ? 'Choose a language' : null,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _language = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Online meeting'),
                value: _online,
                onChanged: (value) {
                  setState(() {
                    _online = value ?? false;
                  });
                },
              ),
              TextFormField(
                controller: _placeController,
                focusNode: _placeFocus,
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                onTapOutside: (_) => _dismissKeyboard(),
                decoration: InputDecoration(
                  labelText: _online ? 'Meeting link' : 'Meeting place',
                ),
                validator: _validatePlace,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _limitController,
                focusNode: _limitFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: (_) => _dismissKeyboard(),
                decoration:
                    const InputDecoration(labelText: 'Participant limit'),
                validator: _validateLimit,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _pickDate,
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: _validateSchedule,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                onTap: _pickTime,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.schedule),
                ),
                validator: _validateSchedule,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                focusNode: _descriptionFocus,
                minLines: 2,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _dismissKeyboard(),
                onTapOutside: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('save-session'),
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
