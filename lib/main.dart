import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

// Retry is off by default; the one provider that needs it opts in.
void main() => runApp(ProviderScope(retry: (_, _) => null, child: const App()));
