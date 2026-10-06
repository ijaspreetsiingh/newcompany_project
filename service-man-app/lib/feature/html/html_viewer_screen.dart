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
  void _onBackPressed(BuildContext context) {
    if (Navigator.canPop(context)) {
      Get.back();
    } else {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
  }

  String _cssColor(Color color) {
    final int argb = color.toARGB32();
    return '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: GetBuilder<HtmlViewController>(
        initState: (state) {
          Get.find<HtmlViewController>()
              .getPagesContent(widget.pageKey ?? widget.type?.value ?? '');
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

          final String pageTitle =
              htmlViewController.pageDetailsModel?.title ??
                  widget.pageTitle ??
                  widget.type?.value.tr ??
                  '';

          final String headingColor = _cssColor(context.kForeground);

          return Scaffold(
            backgroundColor: context.kBackground,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  bottom: false,
                  child: PageHeader(
                    title: pageTitle,
                    subtitle: 'support'.tr,
                    onBack: () => _onBackPressed(context),
                  ),
                ),
                Expanded(
                  child: htmlViewController.pageDetailsModel == null
                      ? const Center(child: CircularProgressIndicator())
                      : (data == null)
                          ? NoDataScreen(text: 'no_data_found'.tr)
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                  Dimensions.paddingSizeLarge,
                                  Dimensions.paddingSizeLarge,
                                  Dimensions.paddingSizeLarge,
                                  32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 144,
                                    decoration: BoxDecoration(
                                      color: context.kPrimary,
                                      borderRadius:
                                          BorderRadius.circular(kRadiusMd),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      size: 44,
                                      color: context.kPrimaryForeground,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    pageTitle,
                                    style: robotoBold.copyWith(
                                      fontSize: 20,
                                      color: context.kForeground,
                                    ),
                                  ),
                                  if (image != null && image.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      height: 175,
                                      decoration: BoxDecoration(
                                        color: context.kMuted,
                                        borderRadius:
                                            BorderRadius.circular(kRadiusMd),
                                        border: Border.all(
                                            color: context.kBorder, width: 1),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CustomImage(
                                        fit: BoxFit.cover,
                                        image: image,
                                        placeholder:
                                            Images.businessPagePlaceholder,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  HtmlWidget(
                                    data,
                                    textStyle: robotoRegular.copyWith(
                                      fontSize: 14,
                                      height: 2,
                                      color: context.kMutedForeground,
                                    ),
                                    customStylesBuilder: (element) {
                                      final String? tag = element.localName;
                                      if (tag == 'h1' ||
                                          tag == 'h2' ||
                                          tag == 'h3' ||
                                          tag == 'h4' ||
                                          tag == 'h5' ||
                                          tag == 'h6') {
                                        return {
                                          'color': headingColor,
                                          'font-weight': 'bold',
                                        };
                                      }
                                      if (tag == 'a') {
                                        return {
                                          'color': headingColor,
                                          'text-decoration': 'underline',
                                        };
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
