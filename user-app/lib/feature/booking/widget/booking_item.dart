import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class BookingItem extends StatelessWidget {
  const BookingItem({super.key, required this.img, required this.title, required this.date});
  final String img;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row( crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        height: 30, width: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        ),
        child: Image.asset(img, height: 15, width: 15,
          color: Get.isDarkMode ? Theme.of(context).hintColor : Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeDefault),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(children: [
            Flexible(
              child: Text(title.tr,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall + 1,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
                ), maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(date,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall + 1,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.75),
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr,
            ),
          ]),
        ),
      ),
    ]);
  }
}

