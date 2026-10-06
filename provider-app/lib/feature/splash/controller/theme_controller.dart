import 'package:get/get.dart';
import 'package:demandium_provider/common/widgets/ink_widgets.dart';
import 'package:demandium_provider/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final SharedPreferences sharedPreferences;
  ThemeController({required this.sharedPreferences}) {
    _loadCurrentTheme();
  }

  bool _darkTheme = false;
  bool get darkTheme => _darkTheme;

  void toggleTheme() {
    _darkTheme = !_darkTheme;
    _apply();
    sharedPreferences.setBool(AppConstants.theme, _darkTheme);
    update();
  }

  void _loadCurrentTheme() async {
    _darkTheme = sharedPreferences.getBool(AppConstants.theme) ?? false;
    _apply();
    update();
  }

  /// Keeps the shared Ink palette (used by most screens) in sync with the
  /// active [ThemeData]. `MyApp` rebuilds the whole tree on `update()`, so
  /// every open page reads the new palette values.
  void _apply() {
    InkColors.setDarkMode(_darkTheme);
  }
}
