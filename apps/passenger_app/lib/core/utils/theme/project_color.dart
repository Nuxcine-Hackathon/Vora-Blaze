// ignore_for_file: deprecated_member_use

import 'package:ride_on/core/services/data_store.dart';
import 'package:flutter/material.dart';

/// Palette officielle — source unique pour les deux apps.
/// Ne pas introduire d'autres couleurs de marque sans revue d'équipe.
class BrandColors {
  static const Color navy = Color(0xFF001341);
  static const Color blue = Color(0xFF023ACF);
  static const Color green = Color(0xFF309369);
  static const Color navySoft = Color(0xFFE8EEF6);
  static const Color blueSoft = Color(0xFFE6EDFF);
  static const Color greenSoft = Color(0xFFE6F4EE);
}

Color contrastOnBrand(Color background, [Color? requested]) {
  final isBrandFill = background == BrandColors.blue ||
      background == BrandColors.navy ||
      background == BrandColors.green;
  if (isBrandFill &&
      (requested == null ||
          requested == BrandColors.navy ||
          requested == Colors.black)) {
    return const Color(0xFFFFFFFF);
  }
  return requested ?? BrandColors.navy;
}

Color themeColor = BrandColors.blue;
Color themeColor2 = BrandColors.green;
Color whiteColor = const Color(0xffFFFFFF);
Color blackColor = BrandColors.navy;
Color ginColor = BrandColors.greenSoft;
Color bgcolor = whiteColor;
Color darkblue = BrandColors.blue;
Color yelloColor = BrandColors.blue;
Color redColor = const Color(0xffFF4747);
Color lightgrey = const Color(0xffDDDDDD);
Color darkmode = const Color(0xff111315);
Color boxcolor = const Color(0xff202427);
Color greycolor2 = const Color(0xff9e9e9e);
Color greycolor22 = const Color(0xffA7AEC1);
Color perpulshadow = BrandColors.blueSoft;
Color buttonColor = BrandColors.blue;
Color blueColor = BrandColors.blue;
Color greenColor = BrandColors.green;
Color gradientColor = BrandColors.green;
Color brownColor = BrandColors.navy;
Color orangeColor = BrandColors.blue;
Color lightyellow = BrandColors.navySoft;
Color redgradient = const Color(0xffFF6B6B);
Color yellowShadow = BrandColors.blueSoft;
Color greentext = BrandColors.green;
Color bordercolor = BrandColors.navySoft;
Color blackColor2 = BrandColors.navy;
Color greyColor2 = const Color.fromARGB(255, 198, 202, 215);
Color greyColor22 = const Color(0xffA7AEC1);
Color darkblue2 = BrandColors.blue;
Color yelloColor2 = BrandColors.blue;
Color redColor2 = const Color(0xffFF4747);
Color lightgrey2 = const Color(0xffDDDDDD);
Color lightBlack = const Color(0x73000000);
Color lightBlack2 = const Color(0XFF636777);
Color onoffColor = const Color(0xffE7E7E7);
Color onoffColor2 = const Color(0xffE7E7E7);
Color fevAndSearchColor = const Color(0xFFf7f7f7);
Color lightblue = BrandColors.blueSoft;
Color greenColor2 = BrandColors.green;
Color lightGrey = const Color(0xFFbbbbbb);
Color pinnetsColor = BrandColors.navySoft;
Color darkgrey = const Color(0xFFF6F4F4);
Color darkbox = BrandColors.green;
Color vehiclethemeColor = BrandColors.navy;
Color bookablethemeColor = greenColor2;
Color boatthemeColor = BrandColors.blue;
Color spacethemeColor = BrandColors.green;
Color parkingthemeColor = BrandColors.navy;
Color doctorthemeColor = BrandColors.blue;
Color lightBackColor = BrandColors.blueSoft;
Color baseColor = Colors.grey.shade300;
Color highlight = Colors.grey.shade100;
Color grey2 = const Color(0xFF616161);
Color grey1 = BrandColors.navy;
Color grey3 = const Color(0xFF9E9E9E);
Color grey4 = const Color(0xFFBDBDBD);
Color grey6 = const Color(0xFFF7F7F7);
Color grey5 = const Color(0xFFEEEEEE);
Color bgBlue = BrandColors.navySoft;
Color fillColor = BrandColors.navy;
Color boatThemColor = BrandColors.blue;
Color parkingThemColor = BrandColors.navy;
Color bookableThemColor = BrandColors.green;
Color spaceThemColor = BrandColors.blue;
Color bgRed = const Color(0xFFFFF5F5);
Color bgYellow = BrandColors.navySoft;
Color bgPurple = BrandColors.blueSoft;
Color acentColor = BrandColors.green;
Color appyellow = BrandColors.green;
Color appgreen = BrandColors.green;
Color pC1 = const Color(0xFFE94165);
Color greenback = const Color(0xFF85D487);
Color pC2 = const Color(0xFFE94165).withOpacity(.8);
Color sliderbg = BrandColors.navy;
Color sliderbg2 = const Color(0xFF3C3C3C);
Color lightYellow = BrandColors.navySoft;
Color lightBlue = BrandColors.blueSoft;
Color circleBg = BrandColors.greenSoft;
Color footerBorderColor = const Color(0xFFDAE1E7);
Color footergreycolor2 = const Color(0xFF7D879C);
// ignore: use_full_hex_values_for_flutter_colors
Color justmixedwhiteColor = const Color(0xff7f7f7f7);
Color greywhite = const Color(0xFF141414);
Color blackshade = const Color(0xFF1A1A1A);

class ColorNotifires with ChangeNotifier {
  bool isDark = box.get("getDarkValue") ?? false;

  set setIsDark(value) {
    isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;
  get getbgcolor => isDark ? darkmode : bgcolor;
  get getbgnextcolor => isDark
      ? const Color.fromARGB(255, 33, 26, 26)
      : const Color.fromARGB(255, 239, 237, 237);
  get getboxcolor => isDark ? boxcolor : whiteColor;
  get getlightblackColor => isDark ? boxcolor : lightBlack;
  get getInVisibleBoxColor => isDark ? grey2 : Colors.grey.shade200;
  get getwhiteblackColor => isDark ? whiteColor : blackColor;
  get getwhitegreycolor2 => isDark ? whiteColor : greycolor2;
  get getgreycolor2 => isDark ? greycolor2 : greycolor2;
  get getwhitebluecolor => isDark ? whiteColor : darkblue;
  get getblackgreycolor2 => isDark ? lightBlack2 : greycolor2;
  get getcardcolor => isDark ? darkmode : whiteColor;
  get getgreywhite => isDark ? whiteColor : greycolor2;
  get getredcolor => isDark ? redColor : redColor2;
  get getprocolor => isDark ? yelloColor : yelloColor2;
  get getblackwhiteColor => isDark ? blackColor : whiteColor;
  get getlightblack => isDark ? lightBlack2 : lightBlack2;
  get getbuttonscolor => isDark ? lightgrey : lightgrey2;
  get getbuttoncolor => isDark ? greycolor2 : onoffColor;
  get getdarkbluecolor => isDark ? darkblue : darkblue;
  get getdarkscolor => isDark ? blackColor : bgcolor;
  get getdarkwhiteColor => isDark ? whiteColor : whiteColor;
  get getblackblue => isDark ? blueColor : blackColor;
  get getfevAndSearch => isDark ? darkmode : fevAndSearchColor;
  get getlightblackwhite => isDark ? blackColor : fevAndSearchColor;
  get getswitchcolor => isDark ? blueColor : lightgrey;

  get getthemeColor => isDark ? themeColor2 : themeColor;
  get getCategoryBox => isDark ? ginColor : themeColor.withOpacity(.3);
  get getThemeWhiteColor => isDark ? whiteColor : themeColor;
  get getWhitePinnetsColor => isDark ? whiteColor : pinnetsColor;
  get getWhiteToDarkGeryColor => isDark ? darkmode : darkgrey;
  get getDoctorModuleColor => isDark ? darkmode : doctorthemeColor;
  get getBaseColor => isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  get getHighlightColor => isDark ? Colors.grey.shade600 : Colors.grey.shade100;
  get getAppBarColor => isDark ? darkmode : lightBackColor.withOpacity(0.7);
  get getGrey1whiteColor => isDark ? whiteColor : grey1;
  get getGrey2whiteColor => isDark ? whiteColor : grey2;
  get getGrey3whiteColor => isDark ? whiteColor : grey3;
  get getGrey4whiteColor => isDark ? whiteColor : grey4;
  get getGrey5whiteColor => isDark ? whiteColor : grey5;
  get getGrey6whiteColor => isDark ? whiteColor : grey6;
  get getShadowColor => isDark ? grey2.withOpacity(.1) : grey4.withOpacity(.4);
  get getBoxColor => isDark ? grey2 : grey5;
  get getThemeColor => isDark ? themeColor : themeColor;
}

late ColorNotifires notifires;
