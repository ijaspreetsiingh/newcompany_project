import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  final VoidCallback? onBackPressed;
  const SearchAppBar({super.key, this.backButton = true, this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    /// nest. style : clean white bar, black back arrow, hatrline bottom border
    return ResponsiveHelper.isDesktop(context) ? const WebMenuBar() :  AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 0.6,
                  color: Theme.of(context).primaryColorLight.withValues(alpha: Get.isDarkMode ? 0.4 : 1))),
        ),
        child: const SearchWidget(),
      ),
      titleSpacing: 0,
      /// backButton false = tab mode (bottom nav ke andar) - back button nahi dikhega
      leading: backButton!
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios,),
              color: Theme.of(context).textTheme.bodyLarge!.color,
              onPressed: () {
                Get.find<AllSearchController>().clearSearchController(shouldUpdate: false);
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  Navigator.pop(context);
                }
              } ,
            )
          : const SizedBox.shrink(),
    );
  }
  @override
  Size get preferredSize => Size(Dimensions.webMaxWidth, ResponsiveHelper.isDesktop(Get.context) ? Dimensions.preferredSizeWhenDesktop : Dimensions.preferredSize );
}

