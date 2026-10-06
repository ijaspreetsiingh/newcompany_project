import 'package:demandium_serviceman/utils/core_export.dart';

class LanguageWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  const LanguageWidget({super.key,
    required this.languageModel,
    required this.localizationController,
    required this.index,
  }) ;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = localizationController.selectedIndex == index;

    return GestureDetector(
      onTap: () {
        localizationController.setSelectIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? context.kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusMd),
          border: Border.all(
            color: isSelected ? context.kPrimary : context.kInputBorder,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              (languageModel.languageCode ?? '').toUpperCase(),
              style: robotoBold.copyWith(
                fontSize: 20,
                color: isSelected ? context.kPrimaryForeground : context.kForeground,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              languageModel.languageName ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(
                fontSize: 14,
                color: isSelected ? context.kPrimaryForeground : context.kForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
