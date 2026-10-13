import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';
import 'package:jdds/common/design_system/nest_screens_kit.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String? phone;
  final String? email;
  final String? tempToken;
  final String? userName;
  final String? redtrectUrl;
  const UpdateProfileScreen({super.key, this.phone, this.email, this.tempToken, this.userName, this.redtrectUrl});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailPhoneController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _phoneEmailFocus = FocusNode();

  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setUserName();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopWidget(
      onPopInvoked: ()=> _existFromApp(),
      child: Scaffold(
        backgroundColor: NestInk.background,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        drawer: ResponsiveHelper.isDesktop(context) ? const AddressSelectionDrawer() : null,
        endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        body: SafeArea(
          child: FooterBaseView(
            isCenter: true,
            child: WebShadowWrap(
              child: Center(
                child: GetBuilder<AuthController>(builder: (authController) {
                  return Form(
                    autovalidateMode: ResponsiveHelper.isDesktop(context) ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                    key: formKey,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.webMaxWidth / 3.5 :
                        ResponsiveHelper.isTab(context) ? Dimensions.webMaxWidth / 5.5 : Dimensions.paddingSizeLarge,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!ResponsiveHelper.isDesktop(context))
                            IconButton(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              icon: Icon(Icons.arrow_back_rounded, color: NestInk.primary, size: 24),
                              onPressed: () {
                                Navigator.pop(context);
                                _socialLogout();
                              },
                            ),

                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Text(
                            'complete_your_profile'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 26,
                              color: NestInk.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'just_one_step_away'.tr,
                            style: robotoRegular.copyWith(
                              fontSize: 15,
                              color: NestInk.mutedText,
                            ),
                          ),
                          const SizedBox(height: 32),

                          CustomTextField(
                            title: 'first_name'.tr,
                            hintText: 'first_name'.tr,
                            controller: firstNameController,
                            inputType: TextInputType.name,
                            focusNode: _firstNameFocus,
                            nextFocus: _lastNameFocus,
                            capitalization: TextCapitalization.words,
                            onValidate: (String? value){
                              return FormValidation().isValidFirstName(value!);
                            },
                          ),

                          const SizedBox(height: Dimensions.paddingSizeTextFieldGap),
                          CustomTextField(
                            title: 'last_name'.tr,
                            hintText: 'last_name'.tr,
                            focusNode: _lastNameFocus,
                            nextFocus: _phoneEmailFocus,
                            controller: lastNameController,
                            inputType: TextInputType.name,
                            capitalization: TextCapitalization.words,
                            onValidate: (String? value){
                              return FormValidation().isValidLastName(value!);
                            },
                          ),

                          const SizedBox(height: Dimensions.paddingSizeTextFieldGap),

                          CustomTextField(
                            onCountryChanged: (CountryCode countryCode) {
                              authController.countryDialCode = countryCode.dialCode!;
                            },
                            countryDialCode: (widget.email !="") ? authController.countryDialCode : null,
                            title: 'email_address'.tr,
                            hintText: (widget.email !="") ? "please_enter_phone_number".tr :'enter_email_address'.tr,
                            inputType: TextInputType.emailAddress,
                            focusNode: _phoneEmailFocus,
                            controller: emailPhoneController,
                            onValidate: (String? value){
                              if(widget.email != "" && PhoneVerificationHelper.getValidPhoneNumber(authController.countryDialCode+ emailPhoneController.text.trim(), withCountryCode: true) == ""){
                                return "enter_valid_phone_number".tr;
                              }else if(widget.email == ""){
                                return null;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          CustomButton(
                            buttonText: "done".tr,
                            backgroundColor: NestInk.primary,
                            onPressed: (){
                              _updateProfileAndNavigate(authController);
                            },
                            isLoading: authController.isLoading,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeTextFieldGap * 2),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _setUserName (){
    if(widget.userName  !=null && widget.userName !=""){
      String fullName = widget.userName!.trim();
      List<String> nameParts = fullName.split(' ');

      if (nameParts.length == 1) {
        firstNameController.text = nameParts.first;
        lastNameController.text = "";
      }else{
        firstNameController.text = nameParts.first;
        lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
  }

  void _socialLogout(){
    Get.find<AuthController>().googleLogout();
    Get.find<AuthController>().signOutWithFacebook();
  }

  Future<bool> _existFromApp() async{
    if (_canExit) {
      if (GetPlatform.isAndroid) {
        SystemNavigator.pop();
      } else if (GetPlatform.isIOS) {
        SystemNavigator.pop();
      } else {
        _socialLogout();
        Navigator.pushNamed(context, RouteHelper.getinitialRoute());
      }
      return Future.value(false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('back_press_again_to_exit'.tr, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(Get.context!).colorScheme.primary,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      ));
      _canExit = true;
      Timer(const Duration(seconds: 2), () {
        _canExit = false;
      });
      return Future.value(false);
    }
  }

  Future<void> _updateProfileAndNavigate (AuthController authController) async {

    if(formKey.currentState!.validate()){
      final String firstName = firstNameController.text.toString();
      final String lastName = lastNameController.text.toString();
      final String email = emailPhoneController.text.trim();
      String phone = PhoneVerificationHelper.getValidPhoneNumber(authController.countryDialCode+ emailPhoneController.text.trim(), withCountryCode: true);

     if(widget.tempToken != ""){
       await authController.registerWithSocialMedia(
         firstName: firstName,
         lastName: lastName,
         email: widget.email,
         phone: phone,
         redtrectUrl: widget.redtrectUrl,
       );

     }else{
       await authController.updateNewUserProfileAndLogin(
         firstName: firstName,
         lastName: lastName,
         email: email,
         phone: widget.phone,
         redtrectUrl: widget.redtrectUrl,
       );
     }

    }
  }
}


