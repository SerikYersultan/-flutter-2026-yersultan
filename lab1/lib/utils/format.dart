const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDateTime(DateTime value) {
  final month = _months[value.month - 1];
  final minutes = value.minute.toString().padLeft(2, '0');
  return '${value.day} $month, ${value.hour}:$minutes';
}
