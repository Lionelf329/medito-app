import 'package:flutter_matomo/flutter_matomo.dart';

class Tracking {
  static const String SCREEN_LOADED = "screen loaded";
  static const String FOLDER_TAPPED = "folder tapped";
  static const String FILE_TAPPED = "file tapped";
  static const String PLAYER_TAPPED = "player tapped";
  static const String READ_MORE_TAPPED = "read more tapped";
  static const String BREADCRUMB = "breadcrumb";

  static const String AUDIO_PLAY = "audio started";
  static const String AUDIO_REWIND = "audio rewind";
  static const String AUDIO_FF = "audio forward";
  static const String AUDIO_RESUME = "audio reumed";
  static const String AUDIO_PAUSED = "audio paused";
  static const String AUDIO_COMPLETED = "audio completed";

  static const String AUDIO_OPENED = "audio opened.";
  static const String FOLDER_OPENED = "folder opened.";
  static const String TEXT_ONLY_OPENED = "text only opened.";
  static const String AUDIO_AND_TEXT_OPENED = "audio and text file opened.";
  static const String CURRENTLY_SELECTED_FILE = "current file.";

  static const String BREADCRUMB_TAPPED = "breadcrumb tapped.";
  static const String FINDER = "finder widget.";
  static const String HOME = "home page.";
  static const String APP_CLOSED = "app closed.";
  static const String BACK_PRESSED = "back pressed.";

  static Future<void> initialiseTracker() async {
    await FlutterMatomo.initializeTracker(
        'https://medito.app/analytics/piwik.php', 1);
  }

  static Future<void> trackScreen(String screenName, String action) async {
    await FlutterMatomo.trackScreenWithName(screenName, action);
  }

  // like "LoginWidget", "Login button", "Clicked"
  static Future<void> trackEvent(
      String widgetName, String eventName, String action) async {
    await FlutterMatomo.trackEventWithName(widgetName, eventName, action);
  }
}