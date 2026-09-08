import 'package:flutter/material.dart';

import '../../services/data_store.dart';

/// Palette officielle VORA — alignée sur la maquette (fond sombre auth,
/// fond crème réservation, orange action, rose accent, vert succès, rouge SOS).
class BrandColors {
  static const Color primary = Color(0xFFFF6D00);
  static const Color primaryPressed = Color(0xFFC85400);
  static const Color secondary = Color(0xFFE91E63);
  static const Color darkBg = Color(0xFF14141F);
  static const Color success = Color(0xFF00C853);
  static const Color sos = Color(0xFFD50000);
  static const Color lightBg = Color(0xFFFFF8F3);
  static const Color muted = Color(0xFF8A8A99);
  static const Color ink = Color(0xFF14141F);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDE3D8);
  static const Color disabledBg = Color(0xFFE2E2E6);
  static const Color disabledText = Color(0xFFA8A8B3);
  static const Color selectedBg = Color(0xFFFDEFF4);
  static const Color navActiveBg = Color(0xFFFFE3CC);
  static const Color navIdleBg = Color(0xFFF1EEE9);

  /// Alias historiques : les écrans existants continuent d'utiliser ces noms.
  static const Color navy = ink;
  static const Color blue = primary;
  static const Color green = success;
  static const Color navySoft = lightBg;
  static const Color blueSoft = navActiveBg;
  static const Color greenSoft = Color(0xFFE3F8EC);

  static const LinearGradient wordmark = LinearGradient(
    colors: [
      Color(0xFFE91E63),
      Color(0xFFFF3D3D),
      Color(0xFFFF6D00),
      Color(0xFFFFC400),
    ],
    stops: [0.0, 0.35, 0.68, 1.0],
  );
}

Color contrastOnBrand(Color background, [Color? requested]) {
  final isBrandFill = background == BrandColors.primary ||
      background == BrandColors.primaryPressed ||
      background == BrandColors.secondary ||
      background == BrandColors.success ||
      background == BrandColors.sos ||
      background == BrandColors.darkBg ||
      background == BrandColors.ink ||
      background == BrandColors.blue ||
      background == BrandColors.navy ||
      background == BrandColors.green;
  if (isBrandFill &&
      (requested == null ||
          requested == BrandColors.ink ||
          requested == BrandColors.navy ||
          requested == Colors.black)) {
    return const Color(0xFFFFFFFF);
  }
  return requested ?? BrandColors.ink;
}

Color themeColor = BrandColors.blue;
Color themeColor2 = BrandColors.green;
Color whiteColor = const Color(0xffFFFFFF);
Color blackColor = BrandColors.ink;
Color ginColor = BrandColors.greenSoft;
Color bgcolor = BrandColors.lightBg;
Color darkblue = BrandColors.blue;
Color yelloColor = BrandColors.blue;
Color redColor = BrandColors.sos;
Color lightgrey = BrandColors.border;
Color darkmode = BrandColors.darkBg;
Color boxcolor = const Color(0xff202427);
Color greycolor2 = BrandColors.muted;
Color greycolor22 = const Color(0xffA7AEC1);
Color perpulshadow = BrandColors.blueSoft;
Color buttonColor = BrandColors.blue;
Color blueColor = BrandColors.blue;
Color greenColor = BrandColors.green;
Color gradientColor = BrandColors.green;
Color brownColor = BrandColors.navy;
Color orangeColor = BrandColors.blue;
Color lightyello = BrandColors.navySoft;
Color redgradient = BrandColors.sos;
Color lighRedgradient = const Color.fromARGB(255, 253, 244, 244);
Color yellowShadow = BrandColors.blueSoft;
Color greentext = BrandColors.green;
Color bordercolor = BrandColors.border;
Color blackColor2 = BrandColors.navy;
Color greyColor2 = const Color.fromARGB(255, 198, 202, 215);
Color greyColor22 = const Color(0xffA7AEC1);
Color darkblue2 = BrandColors.blue;
Color yelloColor2 = BrandColors.blue;
Color redColor2 = BrandColors.sos;
Color lightgrey2 = const Color(0xffDDDDDD);
Color lightBlack = const Color(0x73000000);
Color lightBlack2 = const Color(0XFF636777);
Color onoffColor = const Color(0xffE7E7E7);
Color onoffColor2 = const Color(0xffE7E7E7);
Color fevAndSearchColor = BrandColors.lightBg;
Color lightblue = BrandColors.blueSoft;
Color greenColor2 = BrandColors.green;
Color lightGrey = const Color(0xFFbbbbbb);
Color pinnetsColor = BrandColors.navySoft;
Color darkgrey = BrandColors.lightBg;
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
Color grey3 = BrandColors.muted;
Color grey4 = const Color(0xFFBDBDBD);
Color grey6 = const Color(0xFFF7F7F7);
Color grey5 = const Color(0xFFEEEEEE);
Color bgBlue = BrandColors.navySoft;
Color strockcolor = BrandColors.navySoft;
Color fillColor = BrandColors.navy;
Color vehicalThemColor = BrandColors.green;
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
Color pC1 = BrandColors.secondary;
Color greenback = const Color(0xFF85D487);
// ignore: deprecated_member_use
Color pC2 = BrandColors.secondary.withOpacity(.8);
Color sliderbg = BrandColors.navy;
Color sliderbg2 = const Color(0xFF3C3C3C);
Color lightYellow = BrandColors.navySoft;
Color lightBlue = BrandColors.blueSoft;
Color circleBg = BrandColors.greenSoft;
Color footerBorderColor = BrandColors.border;
Color footergreycolor2 = BrandColors.muted;
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
      ? BrandColors.darkBg
      : const Color(0xFFEFEAE3);
  get getboxcolor => isDark ? boxcolor : whiteColor;
  get getlightblackColor => isDark ? boxcolor : lightBlack;
  get getInVisibleBoxColor => isDark ? grey2 : Colors.grey.shade200;
  get getwhiteblackColor => isDark ? whiteColor : blackColor;
  get getwhitegreycolor2 => isDark ? whiteColor : greycolor2;
  get getgreycolor2 => isDark ? grey5 : grey5;
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
  // ignore: deprecated_member_use
  get getCategoryBox => isDark ? ginColor : themeColor.withOpacity(.3);
  get getThemeWhiteColor => isDark ? whiteColor : themeColor;
  get getWhitePinnetsColor => isDark ? whiteColor : pinnetsColor;
  get getWhiteToDarkGeryColor => isDark ? darkmode : darkgrey;
  get getDoctorModuleColor => isDark ? darkmode : doctorthemeColor;
  get getBaseColor => isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  get getHighlightColor => isDark ? Colors.grey.shade600 : Colors.grey.shade100;
  // ignore: deprecated_member_use
  get getAppBarColor => isDark ? darkmode : lightBackColor.withOpacity(0.7);
  get getGrey1whiteColor => isDark ? whiteColor : grey1;
  get getGrey2whiteColor => isDark ? whiteColor : grey2;
  get getGrey3whiteColor => isDark ? whiteColor : grey3;
  get getGrey4whiteColor => isDark ? whiteColor : grey4;
  get getGrey5whiteColor => isDark ? whiteColor : grey5;
  get getGrey6whiteColor => isDark ? whiteColor : grey6;
  // ignore: deprecated_member_use
  get getShadowColor => isDark ? grey2.withOpacity(.1) : grey4.withOpacity(.4);
  get getBoxColor => isDark ? grey2 : grey5;
  get getThemeColor => isDark ? themeColor : themeColor;
}

late ColorNotifires notifires;
