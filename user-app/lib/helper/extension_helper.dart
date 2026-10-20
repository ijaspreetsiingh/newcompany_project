import 'package:jdds/util/core_export.dart';

extension ContextInfo on BuildContext {
  CustomThemeColors get customThemeColors =>
      theme.extension<CustomThemeColors>()!;
}
