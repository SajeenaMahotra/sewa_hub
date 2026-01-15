import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sewa_hub/app/app.dart';
import 'package:sewa_hub/core/services/hive/hive_service.dart';
import 'package:sewa_hub/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPrefs = await SharedPreferences.getInstance();

  // Create a ProviderContainer and override SharedPreferences
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
  );

  // Initialize HiveService
  await container.read(hiveServiceProvider).init();

  // Run the app with UncontrolledProviderScope 
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
