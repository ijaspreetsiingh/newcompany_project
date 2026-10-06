import 'package:demandium_serviceman/utils/core_export.dart';

class NotificationDialog extends StatelessWidget{
  final String imageUrl;
  final String? title;
  final String? subTitle;
  const NotificationDialog({super.key, required this.imageUrl,this.title,this.subTitle}) ;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: context.kCard,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(kRadiusLg)),
        side: BorderSide(color: context.kBorder, width: 1),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      title: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: robotoBold.copyWith(
                  fontSize: 18,
                  color: context.kForeground,
                ),
              ),
            )
          else
            const Spacer(),
          KIconButton(
            icon: Icons.close_rounded,
            iconSize: 18,
            color: context.kMutedForeground,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kRadiusMd),
                color: context.kMuted,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(kRadiusMd),
                child: FadeInImage.assetNetwork(
                  placeholder: Images.placeholder, image: imageUrl, fit: BoxFit.contain,
                  imageErrorBuilder: (c, o, s) => Image.asset(
                    Images.placeholder, height: MediaQuery.of(context).size.width - 130,
                    width: MediaQuery.of(context).size.width, fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            if (subTitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subTitle!,
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: context.kMutedForeground,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
