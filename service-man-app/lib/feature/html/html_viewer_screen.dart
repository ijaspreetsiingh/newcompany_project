import 'package:demandium_serviceman/common/widgets/no_data_screen.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType? type;
  final String? pageKey;
  final String? pageTitle;
  const HtmlViewerScreen({super.key, this.type, this.pageKey, this.pageTitle});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: GetBuilder<HtmlViewController>(
        initState: (state) {
          Get.find<HtmlViewController>().getPagesContent(widget.pageKey ?? widget.type?.value ?? '');
        },
        builder: (htmlViewController) {
          String? data;
          String? image;

          if (htmlViewController.pageDetailsModel != null) {
            data = htmlViewController.pageDetailsModel?.content;
            image = htmlViewController.pageDetailsModel?.image;
            if (data != null) {
              data = data.replaceAll('href=', 'target="_blank" href=');
            }
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: CustomAppBar(
              title: htmlViewController.pageDetailsModel?.title ?? widget.pageTitle ?? widget.type?.value.tr ?? '',
            ),
            body: (htmlViewController.pageDetailsModel != null)
                ? (data != null)
                    ? SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (image != null && image.isNotEmpty)
                              Container(
                                width: double.infinity,
                                height: 160,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CustomImage(
                                  fit: BoxFit.cover,
                                  image: image,
                                  placeholder: Images.businessPagePlaceholder,
                                ),
                              ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: HtmlWidget(
                                data,
                                textStyle: robotoRegular.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                                  height: 1.6,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : NoDataScreen(text: 'no_data_found'.tr)
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
