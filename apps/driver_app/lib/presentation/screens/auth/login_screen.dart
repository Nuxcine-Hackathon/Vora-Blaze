import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:ride_on_driver/core/utils/translate.dart';
import 'package:ride_on_driver/presentation/screens/Auth/signup_screen.dart';
import 'package:ride_on_driver/presentation/screens/onboarding/language_select_screen.dart';
import '../../../core/extensions/workspace.dart';
import '../../../core/utils/common_widget.dart';
import '../../../core/utils/theme/project_color.dart';
import '../../../core/utils/theme/theme_style.dart';
import '../../cubits/auth/login_cubit.dart';
import '../../cubits/auth/user_authenticate_cubit.dart';
import '../../cubits/logout_cubit.dart';
import '../../widgets/brand_companion.dart';
import '../../widgets/custom_text_form_field.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController textEditingLoginControllerPhoneNumber =
      TextEditingController();

  bool isChecked = false;

  final _formKey = GlobalKey<FormState>();

  String selectedCountryCode = "+237";
  String defaultCountry = "CM";

  @override
  void initState() {
    isNumeric=false;
    context.read<SetCountryCubit>().clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (v) async {},
      child: Scaffold(
          bottomSheet: isNumeric==true&& Platform.isIOS?KeyboardDoneButton(
            onTap: () {
              setState(() {
                isNumeric = false;
              });
            },
          ):null,
          resizeToAvoidBottomInset: true,
          backgroundColor: BrandColors.darkBg,
          body: MultiBlocListener(
              listeners: [
                BlocListener<AuthLoginCubit, AuthLoginState>(
                    listener: (context, state) {
                  if (state is LoginLoading) {
                    Widgets.showLoader(context);
                  } else if (state is LoginSuccess) {
                    Widgets.hideLoder(context);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OtpScreen(
                                  number: textEditingLoginControllerPhoneNumber
                                      .text,
                                  countryCode:
                                      state.loginModel.data?.phoneCountry ??
                                          "+237",
                                  defaultCountry:
                                      state.loginModel.data?.defaultCountry ??
                                          "CM",
                                  routeString: "Login",
                                  otpValue: state.loginModel.data!.resetToken!,
                                )));
                    context.read<AuthLoginCubit>().resetState();
                  } else if (state is LoginFailure) {
                    Widgets.hideLoder(context);

                    showErrorToastMessage(state.error);
                  }
                })
              ],
              child: Stack(
                children: [
                  Positioned(
                      left: 0,
                      top: 0,
                      child: SvgPicture.asset("assets/images/EllipseTop.svg",)),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: Dimensions.containerWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeLarge,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(children: [
                                  const SizedBox(height: 96),
                                  commonlyUserLogo(),
                                  const SizedBox(height: 8),
                                  const VoraWordmark(fontSize: 28, opacity: 0.95),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Text("Bienvenue sur VORA",
                                      style: heading1(context).copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      )),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Text("Connecte-toi pour continuer",
                                      style: regular2(context).copyWith(
                                          color: BrandColors.muted)),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  BlocBuilder<SetCountryCubit, SetCountryState>(
                                      builder: (context, state) {
                                    return IntelPhoneFieldRefs(
                                      onTap: (){
                                        isNumeric=true;
                                        setState(() {

                                        });
                                      },
                                      key: ValueKey(state.countryCode),
                                      defultcountry: state.countryCode,
                                      textEditingControllerCommons:
                                          textEditingLoginControllerPhoneNumber,
                                      oncountryChanged: (number) {
                                        context.read<SetCountryCubit>().reset();
                                        textEditingLoginControllerPhoneNumber
                                            .clear();

                                       context
                                            .read<SetCountryCubit>()
                                            .setCountry(
                                                dialCode: "+${number.dialCode}",
                                                countryCode: number.code);
                                      },
                                      hintText: "Phone no".translate(context),
                                      onChanged: (value) {
                                        return null;
                                      },
                                      validator: (phoneNumber) {
                                        if (phoneNumber == null ||
                                            phoneNumber.number.isEmpty) {
                                          return "Please enter your phone number"
                                              .translate(context);
                                        }
                                        int expectedLength = phoneLengths[
                                                phoneNumber.countryISOCode] ??
                                            10;
                                        if (phoneNumber.number.length !=
                                            expectedLength) {
                                          return "${"Phone number must be".translate(context)} $expectedLength ${"digits".translate(context)}";
                                        }
                                        return null;
                                      },
                                    );
                                  }),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  CustomsButtons(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          if (textEditingLoginControllerPhoneNumber
                                              .text.isEmpty) {
                                            showErrorToastMessage(
                                                "please enter the phone number"
                                                    .translate(context));
                                            return;
                                          }
                                          context.read<AuthLoginCubit>().login(
                                              context: context,
                                              phoneCountry: context
                                                      .read<SetCountryCubit>()
                                                      .state
                                                      .dialCode
                                                      .startsWith("+")
                                                  ? context
                                                      .read<SetCountryCubit>()
                                                      .state
                                                      .dialCode
                                                  : "+${context.read<SetCountryCubit>().state.dialCode}",
                                              phoneNumber:
                                                  textEditingLoginControllerPhoneNumber
                                                      .text);
                                        }
                                        clearData(context);
                                      },
                                      textColor: Colors.white,
                                      text: "Recevoir le code",
                                      backgroundColor: BrandColors.primary),
                                  const SizedBox(
                                    height: 40,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Pas encore de compte ?",
                                        style: regular3(context)
                                            .copyWith(color: BrandColors.muted),
                                      ),
                                      const SizedBox(width: 5),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => const SignUp()));
                                        },
                                        child: Text(
                                          "Créer un compte",
                                          style: heading1(context).copyWith(
                                            color: themeColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  const SizedBox(height: 380)
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
Positioned(
                  top: 70,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      languageButton(onTap: (){

                        goTo(const SelectLanguageScreen(isBack: true,));
                      },),
                    ],
                  )),
                  Positioned(
                    bottom: -40,
                    left: 0,
                    child: IgnorePointer(
                      child: SvgPicture.asset("assets/images/vector_bottom.svg",
                          colorFilter: ColorFilter.mode(themeColor, BlendMode.srcIn),),
                    ),
                  ),
                ],
              ))),
    );
  }
}
