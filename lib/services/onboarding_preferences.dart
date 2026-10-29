import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPreferences {
  static const String _isOnboardingViewedKey = 'isOnboardingViewed';

  static Future<bool> isViewed() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_isOnboardingViewedKey) ?? false;
  }

  static Future<void> markAsViewed() async {
    final preferences = await SharedPreferences.getInstance();
    final wasSaved = await preferences.setBool(_isOnboardingViewedKey, true);
    if (!wasSaved) {
      throw StateError('Failed to save the onboarding viewed state.');
    }
  }
}
