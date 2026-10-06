import 'package:demandium_serviceman/utils/core_export.dart';

/// Body type family used across the app (matches reference "Figtree").
const String kBodyFont = 'Figtree';

/// Display type family used across the app (matches reference "Outfit").
const String kDisplayFont = 'Outfit';

const robotoLight = TextStyle(
  fontFamily: kBodyFont,
  fontWeight: FontWeight.w300,
);

const robotoRegular = TextStyle(
  fontFamily: kBodyFont,
  fontWeight: FontWeight.w400,
);

TextStyle robotoRegularLow = TextStyle(
  fontFamily: kBodyFont,
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeSmall,
);


const robotoMedium = TextStyle(
  fontFamily: kBodyFont,
  fontWeight: FontWeight.w500,
);

TextStyle robotoMediumLow = TextStyle(
  fontFamily: kBodyFont,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeSmall,
);

TextStyle robotoMediumHigh = TextStyle(
  fontFamily: kBodyFont,
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeLarge,
);

/// Bold headings use the display family (matches reference "font-display").
const robotoBold = TextStyle(
  fontFamily: kDisplayFont,
  fontWeight: FontWeight.w700,
);

/// Extra bold display style (splash / hero numbers).
const displayExtraBold = TextStyle(
  fontFamily: kDisplayFont,
  fontWeight: FontWeight.w800,
);


List<BoxShadow>? shadow =  [BoxShadow(offset: const Offset(0, 8), blurRadius: 24, color: Colors.black.withValues(alpha:0.08),)];

List<BoxShadow>? lightShadow = [const BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x14000000),)];
