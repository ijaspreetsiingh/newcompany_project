import 'package:get/get.dart';
import 'package:jassdbx_serviceman/utils/core_export.dart';

class EditProfileGeneralInfo extends StatelessWidget {
  const EditProfileGeneralInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: GetBuilder<UserController>(
          builder: (userController) {
            return userController.contents == null
                ? const ProfileInfoShimmer()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatar(context, userController),
                      const SizedBox(height: 20),
                      _fieldLabel(context, "full_name".tr, requiredMark: true),
                      Row(
                        children: [
                          Expanded(
                            child: _readOnlyField(
                              context,
                              userController.userInfo.firstName ?? "",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _readOnlyField(
                              context,
                              userController.userInfo.lastName ?? "",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(context, "email".tr, requiredMark: true),
                      CustomTextFormField(
                        isShowSuffixIcon: true,
                        controller: userController.emailController,
                        hintText: "enter_email_address".tr,
                        isShowBorder: true,
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(
                        context,
                        "select_identity_type".tr,
                        requiredMark: true,
                      ),
                      _readOnlyField(
                        context,
                        userController.userInfo.identificationType != null
                            ? userController.userInfo.identificationType
                                .toString()
                                .tr
                            : '',
                      ),
                      const SizedBox(height: 20),
                      _fieldLabel(
                        context,
                        "identity_number".tr,
                        requiredMark: true,
                      ),
                      _readOnlyField(
                        context,
                        userController.userInfo.identificationNumber ?? "",
                      ),
                      if (userController.userInfo.identificationImageFullPath !=
                              null &&
                          userController
                              .userInfo.identificationImageFullPath!
                              .isNotEmpty) ...[
                        const SizedBox(height: 20),
                        GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                ResponsiveHelper.isTab(context) ? 2 : 1,
                            crossAxisSpacing: Dimensions.paddingSizeSmall,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            mainAxisExtent: 200,
                          ),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Get.to(
                                  ImageDetailScreen(
                                    imageList: userController
                                            .userInfo
                                            .identificationImageFullPath ??
                                        [],
                                    index: index,
                                    appbarTitle:
                                        'identification_image'.tr,
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CustomImage(
                                  fit: BoxFit.fill,
                                  image: userController.userInfo
                                      .identificationImageFullPath![index],
                                ),
                              ),
                            );
                          },
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: userController
                              .userInfo.identificationImageFullPath!.length,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _saveButton(
                        context,
                        isLoading: userController.isLoading,
                        onPressed: () =>
                            _updateProfile(context, userController),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, UserController userController) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            userController.pickedFile == null
                ? UserAvatar(
                    large: true,
                    imageUrl: userController.userInfo.profileImageFullPath,
                    name: userController.userInfo.firstName ?? "",
                  )
                : Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.kCard, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.file(
                        File(userController.pickedFile!.path),
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            Positioned(
              right: 2,
              bottom: 2,
              child: InkWell(
                onTap: () => userController.pickImage(),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.kPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.kBackground, width: 3),
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: context.kPrimaryForeground,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(
    BuildContext context,
    String title, {
    bool requiredMark = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: title,
              style: robotoMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.kForeground,
              ),
            ),
            if (requiredMark)
              TextSpan(
                text: ' *',
                style: robotoMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.kDestructive,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyField(BuildContext context, String text) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: context.kCard,
        borderRadius: BorderRadius.circular(kRadiusMd),
        border: Border.all(color: context.kInputBorder, width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(
          fontSize: 14,
          color: context.kForeground,
        ),
      ),
    );
  }

  Widget _saveButton(
    BuildContext context, {
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.kPrimary,
          borderRadius: BorderRadius.circular(kRadiusMd),
        ),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: context.kPrimaryForeground,
          ),
        ),
      );
    }
    return KButton(label: "save".tr, height: 48, onTap: onPressed);
  }

  void _updateProfile(BuildContext context, UserController profileController) {
    if (profileController.emailController!.text.isEmpty) {
      showCustomSnackBar(
        "enter_email_address".tr,
        type: ToasterMessageType.info,
      );
    } else {
      profileController.updateProfile();
    }
  }
}
