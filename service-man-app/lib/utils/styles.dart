import 'package:demandium_serviceman/utils/core_export.dart';

const robotoLight = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w300,
);

const robotoRegular = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
);

TextStyle robotoRegularLow = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeSmall,
);


const robotoMedium = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
);

TextStyle robotoMediumLow = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeSmall,
);


TextStyle robotoMediumHigh = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeLarge,
);



const robotoBold = TextStyle(
  fontFamily: 'Roboto',
  fontWeight: FontWeight.w700,
);


List<BoxShadow>? shadow =  [BoxShadow(offset: const Offset(0, 8), blurRadius: 24, color: Colors.black.withValues(alpha:0.08),)];

List<BoxShadow>? lightShadow = [const BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x14000000),)];
