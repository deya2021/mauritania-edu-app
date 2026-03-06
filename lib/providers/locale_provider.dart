import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _locale;
  
  LocaleProvider(this._prefs) 
      : _locale = Locale(_prefs.getString('locale') ?? 'ar');
  
  Locale get locale => _locale;
  
  bool get isRTL => _locale.languageCode == 'ar';
  
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    await _prefs.setString('locale', languageCode);
    notifyListeners();
  }
  
  void detectSystemLocale(BuildContext context) {
    final systemLocale = Localizations.localeOf(context);
    if (systemLocale.languageCode == 'ar' || systemLocale.languageCode == 'fr') {
      if (_prefs.getString('locale') == null) {
        _locale = systemLocale;
        _prefs.setString('locale', systemLocale.languageCode);
        notifyListeners();
      }
    }
  }
}
