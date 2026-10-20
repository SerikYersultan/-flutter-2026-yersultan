import 'package:flutter/foundation.dart';

import 'models/exchange_session.dart';
import 'models/profile.dart';

abstract final class Routes {
  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArguments {
  const DetailArguments({
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onRequestProfile,
    this.onDeleted,
  });

  final ExchangeSession session;
  final Profile profile;
  final ValueChanged<ExchangeSession> onChanged;
  final VoidCallback onRequestProfile;
  final ValueChanged<String>? onDeleted;
}

class FormArguments {
  const FormArguments({this.session});

  final ExchangeSession? session;
}
