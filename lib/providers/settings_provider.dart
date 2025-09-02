
// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
bool _biometricsEnabled = false;
bool get biometricsEnabled => _biometricsEnabled;

bool _hideBalance = true;
bool get hideBalance => _hideBalance;

Future<void> load() async {
final sp = await SharedPreferences.getInstance();
_biometricsEnabled = sp.getBool('bio_enabled') ?? false;
_hideBalance = sp.getBool('hide_balance') ?? true;
notifyListeners();
}

Future<void> toggleHideBalance() async {
_hideBalance = !_hideBalance;
final sp = await SharedPreferences.getInstance();
await sp.setBool('hide_balance', _hideBalance);
notifyListeners();
}

Future<void> setBiometrics(bool enabled) async {
_biometricsEnabled = enabled;
final sp = await SharedPreferences.getInstance();
await sp.setBool('bio_enabled', enabled);
notifyListeners();
}
}