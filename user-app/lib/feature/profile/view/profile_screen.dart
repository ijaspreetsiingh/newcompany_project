import 'package:jdds/common/design_system/nest_screens_kit.dart';
import 'package:jdds/common/widgets/custom_pop_widget.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:jdds/common/widgets/address_selection_drawer.dart';

/// nest. Profile screen (reference: designnew ProfileScreen)
/// profile-editor · form-field×3 · Save changes · extra menu-card
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo(reload: false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _prefill(UserController userController) {
    if (_prefilled) return;
    final userInfo = userController.userInfoModel;
    if (userInfo == null && Get.find<AuthController>().isLoggedIn()) return;

    _prefilled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nameController.text =
          '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();
      _phoneController.text = userInfo?.phone ?? '';
      _emailController.text = userInfo?.email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final bool pickedAddress =
        Get.find<LocationController>().getUserAddress() != null;

    return CustomPopWidget(
      child: Scaffold(
        backgroundColor: NestInk.background,
        drawer: ResponsiveHelper.isDesktop(context)
            ? const AddressSelectionDrawer()
            : null,
        endDrawer:
            ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
        appBar: CustomAppBar(
          title: 'profile'.tr,
          bgColor: NestInk.background,
          isBackButtonExist: true,
          onBackPressed: () {
            if (Navigator.canPop(context)) {
              Get.back();
            } else {
              Get.offAllNamed(RouteHelper.getMainRoute("home"));
            }
          },
        ),
        body: GetBuilder<UserController>(
          builder: (userController) {
            if (userController.userInfoModel == null && isLoggedIn) {
              return const Center(child: CircularProgressIndicator());
            }

            _prefill(userController);

            return FooterBaseView(
              isScrollView: true,
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: NestScreenBody(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// reference `.profile-editor`
                          _ProfileEditor(userController: userController),
                          NestField(
                            label: 'full_name'.tr,
                            controller: _nameController,
                            hint: 'first_name'.tr,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter your full name';
                              }
                              return FormValidation()
                                  .isValidFirstName(value.trim());
                            },
                          ),
                          NestField(
                            label: 'phone_number'.tr,
                            controller: _phoneController,
                            hint: 'enter_phone_number'.tr,
                            keyboardType: TextInputType.phone,
                            readOnly: userController.userInfoModel
                                    ?.isPhoneVerified ==
                                1,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'enter_phone_number'.tr;
                              }
                              return FormValidation().isValidPhone(
                                _fullPhone(value.trim()),
                                fromAuthPage: true,
                              );
                            },
                          ),
                          NestField(
                            label: 'email_address'.tr,
                            controller: _emailController,
                            hint: 'email'.tr,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                FormValidation().isValidEmail(value),
                          ),

                          const SizedBox(height: 4),
                          GetBuilder<UserController>(
                            builder: (loadingController) => NestPillButton(
                              label: 'save_changes'.tr,
                              onTap: loadingController.isLoading
                                  ? null
                                  : () => _save(userController),
                            ),
                          ),

                          /// extra actions (kept from app, nest. styled)
                          if (isLoggedIn) ...[
                            const SizedBox(height: 30),
                            NestMenuCard(
                              children: [
                                NestMenuRow(
                                  icon: Icons.location_on_outlined,
                                  title: 'my_address'.tr,
                                  onTap: () => Get.toNamed(
                                    RouteHelper.getAddressRoute(
                                        'fromProfileScreen'),
                                  ),
                                ),
                                NestMenuRow(
                                  icon: Icons.notifications_none_rounded,
                                  title: 'notifications'.tr,
                                  onTap: () => Get.toNamed(pickedAddress
                                      ? RouteHelper.getNotificationRoute()
                                      : RouteHelper.getPickMapRoute(
                                          RouteHelper.notification,
                                          true,
                                          'false',
                                          null,
                                          null)),
                                ),
                                NestMenuRow(
                                  icon: Icons.lightbulb_outline_rounded,
                                  title: 'suggest_new_service'.tr,
                                  onTap: () => Get.toNamed(
                                    pickedAddress
                                        ? RouteHelper
                                            .getNewSuggestedServiceScreen()
                                        : RouteHelper.getPickMapRoute(
                                            RouteHelper.suggestService,
                                            true,
                                            'false',
                                            null,
                                            null),
                                  ),
                                ),
                                NestMenuRow(
                                  icon: Icons.delete_outline_rounded,
                                  title: 'delete_account'.tr,
                                  titleColor: NestInk.danger,
                                  onTap: () => Get.dialog(
                                    ConfirmationDialog(
                                      icon: Images.deleteProfile,
                                      title:
                                          'are_you_sure_to_delete_your_account'
                                              .tr,
                                      description:
                                          'it_will_remove_your_all_information'
                                              .tr,
                                      yesButtonText: 'delete',
                                      noButtonText: 'cancel',
                                      onYesPressed: () =>
                                          userController.removeUser(),
                                    ),
                                    useSafeArea: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _fullPhone(String value) {
    if (value.startsWith('+')) return value;
    return '${Get.find<UserController>().countryDialCode}$value';
  }

  void _save(UserController userController) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final List<String> nameParts = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    final String phone = userController.userInfoModel?.isPhoneVerified == 1
        ? userController.userInfoModel?.phone ?? ''
        : _fullPhone(_phoneController.text.trim());

    userController.updateUserProfile(
      userInfoModel: UserInfoModel(
        fName: nameParts.isEmpty ? '' : nameParts.first,
        lName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        email: _emailController.text.trim(),
        phone: phone,
      ),
    );
  }
}

/// reference `.profile-editor` — avatar large + Change photo
class _ProfileEditor extends StatelessWidget {
  final UserController userController;
  const _ProfileEditor({required this.userController});

  @override
  Widget build(BuildContext context) {
    final userInfo = userController.userInfoModel;
    final String fullName =
        '${userInfo?.fName ?? ''} ${userInfo?.lName ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 30),
      child: Column(
        children: [
          GetBuilder<UserController>(
            builder: (controller) {
              final bool hasPicked = controller.pickedProfileImageFile != null;
              final Widget avatar;

              if (hasPicked) {
                avatar = ClipOval(
                  child: kIsWeb
                      ? Image.network(
                          controller.pickedProfileImageFile!.path,
                          height: 86,
                          width: 86,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(controller.pickedProfileImageFile!.path),
                          height: 86,
                          width: 86,
                          fit: BoxFit.cover,
                        ),
                );
              } else if ((userInfo?.imageFullPath ?? '').isNotEmpty) {
                avatar = ClipOval(
                  child: CustomImage(
                    image: userInfo!.imageFullPath!,
                    height: 86,
                    width: 86,
                    fit: BoxFit.cover,
                    placeholder: Images.userPlaceHolder,
                  ),
                );
              } else {
                avatar = Container(
                  height: 86,
                  width: 86,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NestInk.primary,
                  ),
                  child: Text(
                    _initialsOf(fullName),
                    style: NestInk.display(
                      size: 20,
                      weight: FontWeight.w800,
                      color: NestInk.background,
                    ),
                  ),
                );
              }

              return avatar;
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => userController.pickProfileImage(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'change_photo'.tr,
              style: NestInk.display(size: 10, weight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  String _initialsOf(String name) {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
