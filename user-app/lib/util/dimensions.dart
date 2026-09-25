import 'package:get/get.dart';

class Dimensions {
  static double _responsive(double mobile, double desktop) {
    final width = Get.context?.width ?? 600;
    return width >= 1300 ? desktop : mobile;
  }

  static double get fontSizeExtraSmall => _responsive(10, 14);
  static double get fontSizeSmall => _responsive(12, 13);
  static double get fontSizeDefault => _responsive(14, 16);
  static double get fontSizeLarge => _responsive(16, 18);
  static double get fontSizeExtraLarge => _responsive(18, 20);
  static double get fontSizeOverLarge => _responsive(24, 26);
  static double get fontSizeForReview => 36;

  static const double paddingSizeMini = 2.0;
  static const double paddingSizeTine = 3.0;
  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeEight = 8.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;
  static const double paddingSizeTextFieldGap = 35.0;
  static const double paddingSizeExtraMoreLarge = 40.0;
  static const double paddingForChattingButton = 60.0;
  static const double pagesBottomPadding = 100.0;
  static const double pickMapIconSize = 100.0;

  static const double logoSize = 180.0;
  static const double cartWidgetSize = 30.0;
  static const double customAppbarSize = 70.0;
  static const double preferredSizeWhenDesktop = 70.0;
  static const double preferredSize = 50.0;

  static const double addressItemHeight = 100.0;
  static const double statusButtonHeight = 30.0;
  static const double statusButtonWeight = 75.0;
  static const double imageSize = 50.0;
  static const double invoiceImageWidth = 100.0;
  static const double invoiceImageHeight = 50.0;
  static const double editIconSize = 20.0;
  static const double profileImageSize = 20.0;
  static const double homeImageSize = 130.0;
  static const double imageSizeButton = 105.0;
  static const double imageSizeLarge = 90.0;
  static const double serviceDetailsServiceImages = 70.0;
  static const double webCategorySize = 120.0;
  static const double serviceBannerSize = 200.0;
  static const double contactUsLandingImageWidth = 120.0;

  static const double radiusSmall = 5.0;
  static const double radiusDefault = 10.0;
  static const double radiusSeven = 7.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;
  static const double radiusExtraMoreLarge = 50.0;

  static const double webMaxWidth = 1200;
  static const double tabMinimumSize = 650;

  static const double searchbarSize = 40;
  static const double floatingButtonHeight = 35;
  static const double cartDialogPadding = 80;
  static const double addAddressHeight = 50;
  static const double addAddressWidth = 180;
  static const double supportLogoHeight = 242;
  static const double supportLogoWidth = 200;

  static const double webLandingTestimonialHeight = 320;
  static const double webLandingDownloadImageHeight = 500;
  static const double webLandingContactUsHeight = 190;
  static const double webLandingIconContainerHeight = 40;

  static const double featureSectionImageSize = 500;
  static const double webArrowSize = 20;
  static const double pushNotificationDialogWidth = 500;

  static const double walletTopCardHeight = 140;
  static const double currencyConvertButtonHeight = 220;
}
