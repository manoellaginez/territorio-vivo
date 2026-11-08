String fmt(double v, {int decimals = 1}) =>
    v.toStringAsFixed(decimals).replaceAll('.', ',');

String _two(int n) => n.toString().padLeft(2, '0');

String fmtDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

String fmtDateTime(DateTime d) => '${fmtDate(d)} ${_two(d.hour)}:${_two(d.minute)}';
