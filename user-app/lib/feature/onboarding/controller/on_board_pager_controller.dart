import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class OnBoardController extends GetxController implements GetxService{
  int pageIndex = 0;
  final PageController pageController = PageController();

  List<Map<String, dynamic>> onBoardPagerData = [
    {
      "text": "Professional\nHome Cleaning\nServices",
      "subTitle": "Get your home sparkling clean with verified and trusted cleaning experts.",
      "image": "assets/img/1.png",
      "primaryColor": const Color(0xFFF57C21),
      "gradientColors": const [
        Color(0xFFFCE4D6),
        Color(0xFFFFF3E0),
        Color(0xFFFFE0B2),
      ],
      "orbColors": const [
        Color(0xFFFFAB91),
        Color(0xFFFFCC80),
        Color(0xFFC5E1A5),
        Color(0xFFF48FB1),
        Color(0xFFFFF176),
      ],
      "badgeText": "Trusted\nProfessionals",
      "badgeIcon": Icons.auto_awesome,
    },
    {
      "text": "Book Your\nService in\nMinutes",
      "subTitle": "Choose your service, pick a time that works for you, and we'll handle the rest.",
      "image": "assets/img/2.png",
      "primaryColor": const Color(0xFF1976D2),
      "gradientColors": const [
        Color(0xFFE0F7FA),
        Color(0xFFE3F2FD),
        Color(0xFFBBDEFB),
      ],
      "orbColors": const [
        Color(0xFF80DEEA),
        Color(0xFF81D4FA),
        Color(0xFFB2DFDB),
        Color(0xFFCE93D8),
        Color(0xFFFFF176),
      ],
      "badgeText": "Fast & Easy\nBooking",
      "badgeIcon": Icons.flash_on_rounded,
    },
    {
      "text": "Safe, Trusted\n& Reliable",
      "subTitle": "Verified professionals, secure payments and 24/7 support — for your complete peace of mind.",
      "image": "assets/img/3.png",
      "primaryColor": const Color(0xFF7B1FA2),
      "gradientColors": const [
        Color(0xFFF3E5F5),
        Color(0xFFEDE7F6),
        Color(0xFFE1BEE7),
      ],
      "orbColors": const [
        Color(0xFFCE93D8),
        Color(0xFFB39DDB),
        Color(0xFF90CAF9),
        Color(0xFFF48FB1),
        Color(0xFFFFF176),
      ],
      "badgeText": "Safe & Secure",
      "badgeIcon": Icons.verified_user_rounded,
    }
  ];

  void onPageChanged(int index){
    pageIndex = index;
    update();
  }

}
