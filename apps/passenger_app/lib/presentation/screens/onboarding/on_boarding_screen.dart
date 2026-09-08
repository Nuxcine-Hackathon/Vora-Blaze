import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ride_on/app/route_settings.dart';
import 'package:ride_on/core/utils/translate.dart';
import 'package:ride_on/presentation/screens/onboarding/language_select_screen.dart';
import '../../../core/services/data_store.dart';
import '../../../core/services/vora_guide_script.dart';
import '../../../core/utils/common_widget.dart';
import '../../../core/utils/theme/project_color.dart';
import '../../../core/utils/theme/theme_style.dart';
import '../../widgets/vora_guide_avatar.dart';
import '../../cubits/auth/apple_login_cubit.dart';
import '../../cubits/auth/google_login_cubit.dart';
import '../Auth/google_update_screen.dart';
import '../Auth/signup_screen.dart';
import '../Home/item_home_screen.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  List content = [
    {
      "image": "assets/images/cuate.svg",
      "title": "More than just a ride, it's a vibe!",
      "description":
          "Book rides in seconds, track your arrival in real-time, and enjoy stress-free journeys. Choose from different ride options, all driven by professional and friendly drivers."
    },
  ];

  late PageController pageController;
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: BrandColors.darkBg,
      body: MultiBlocListener(
          listeners: [
            BlocListener<GoogleLoginCubit, GoogleLoginState>(
              listener: (context, state) {
                if (state is GoogleLoginSucess) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ItemHomeScreen()));
                } else if (state is AddPhoneNumberState) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GoogleUpdate(
                                email: state.loginModel.data?.email ?? "",
                              )));
                } else if (state is GoogleLoginFailure) {
                  showErrorToastMessage(state.error);
                }
              },
            ),
            BlocListener<AppleLoginCubit, AppleLoginState>(
              listener: (context, state) {
                if (state is AppleLoginSuccess) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ItemHomeScreen()));
                } else if (state is AddPhoneNumberAppleState) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GoogleUpdate()));
                } else if (state is AppleLoginFailure) {
                  closeLoading();
                  showErrorToastMessage(state.error);
                }
              },
            )
          ],

          child: SingleChildScrollView(
            child: Stack(
              children: [
              
                Column(
                  children: [
                
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.38,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: SvgPicture.asset(
                              "assets/images/EllipseCircle.svg",
                              height: MediaQuery.of(context).size.height * 0.38,
                              fit: BoxFit.fill,
                              colorFilter: const ColorFilter.mode(
                                BrandColors.blue,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: VoraGuideAvatar(
                              scene: VoraGuideScene.onboarding,
                              size: 148,
                              speakOnAppear: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60,vertical: 20),
                      child: Column(
                        children: [
                          Text(
                            "Plus qu'une course, un accompagnement.",
                            textAlign: TextAlign.center,
                            style: largeHeadingMedium.copyWith(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Réserve en quelques secondes, suis ton chauffeur en direct, et voyage l'esprit libre.",
                            textAlign: TextAlign.center,
                            style: smallHeadingMedium.copyWith(
                              color: BrandColors.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          CustomsButtons(
                            textColor: Colors.white,
                            text: "Explorer VORA",
                            backgroundColor: BrandColors.primary,
                            onPressed: () {
                              box.put('Firstuser', true);
                              goToWithClear(const ItemHomeScreen());
                            },
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignUp()),
                              );
                            },
                            child: Text(
                              "Créer un compte",
                              style: heading3Grey1(context).copyWith(
                                color: BrandColors.primary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            "Ou continuer avec",
                            style: regular(context).copyWith(color: BrandColors.muted),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.read<GoogleLoginCubit>().googleLogin(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: themeColor.withValues(alpha: .3),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: SvgPicture.asset("assets/images/google_icon.svg"),
                                ),
                              ),
                              if (Platform.isIOS) const SizedBox(width: 25),
                              if (Platform.isIOS)
                                InkWell(
                                  onTap: () {
                                    context.read<AppleLoginCubit>().appleLogin(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: themeColor.withValues(alpha: .3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: SvgPicture.asset("assets/images/apple_icon.svg"),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 70,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      languageButton(onTap: (){

                        goTo(const SelectLanguageScreen(isBack: true,));
                      },),
                    ],
                  )),
              ],
            ),
          )

      ),
    );
  }
}

Widget customOnboardingWidget(String image, String title, String description) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: SvgPicture.asset(image),
        ),
        const SizedBox(
          height: 20,
        ),
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: largeHeadingMedium.copyWith(fontSize: 24),
            softWrap: true,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          description,
          style: smallHeadingMedium.copyWith(
              color: notifires.getGrey2whiteColor, fontSize: 14),
          textAlign: TextAlign.start,
        )
      ],
    ),
  );
}
