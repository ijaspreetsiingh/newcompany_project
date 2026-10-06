import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  String _initialsOf(String source) {
    final List<String> parts = source.trim().split(RegExp(r'\s+')).where((String part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((String part) => part[0].toUpperCase()).join();
  }

  String _maskedAccountNumber(String value) {
    final String raw = value.replaceAll(RegExp(r'\s+'), '');
    if (raw.length <= 4) return raw;

    final String hidden = 'X' * (raw.length - 4);
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < hidden.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(hidden[i]);
    }
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(raw.substring(raw.length - 4));
    return buffer.toString();
  }

  Widget _fieldsCard(List<Widget> rows) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      if (i != 0) children.add( SizedBox(height: 1, child: ColoredBox(color: InkColors.border)));
      children.add(rows[i]);
    }
    return InkCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<UserProfileController>(
          initState: (_) async {
            Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
            Get.find<BankInfoController>().getBankInfoData();
            Get.find<UserProfileController>().getProviderInfo(reload: true);
            Get.find<TransactionController>().getWithdrawMethods();
          },
          builder: (userController) {
            if (userController.providerModel == null) {
              return Center(child: CircularProgressIndicator(color: InkColors.foreground));
            }

            final providerInfo = userController.providerModel?.content?.providerInfo;
            final owner = providerInfo?.owner;

            final String ownerName = "${owner?.firstName ?? ''} ${owner?.lastName ?? ''}".trim();
            final String companyName = providerInfo?.companyName ?? '';
            final String phone = owner?.phone ?? '';
            final String email = owner?.email ?? '';
            final String identityType = owner?.identificationType ?? '';
            final String identityNumber = owner?.identificationNumber ?? '';
            final int documentCount = owner?.identificationImageFullPath?.length ?? 0;
            final bool isVerified = (providerInfo?.isApproved ?? 0) == 1;
            final String heroTitle = companyName.isNotEmpty ? companyName : (ownerName.isNotEmpty ? ownerName : 'my_profile'.tr);

            final List<Widget> profileFields = <Widget>[
              if (ownerName.isNotEmpty) _ProfileField(label: "Full name", value: ownerName),
              if (phone.isNotEmpty) _ProfileField(label: 'phone_number'.tr, value: phone),
              if (email.isNotEmpty) _ProfileField(label: 'email'.tr, value: email),
            ];

            final List<Widget> businessFields = <Widget>[
              if (companyName.isNotEmpty) _ProfileField(label: "Company", value: companyName),
              if (identityNumber.isNotEmpty)
                _ProfileField(
                  label: 'identity_number'.tr,
                  value: identityType.isNotEmpty ? '$identityType · $identityNumber' : identityNumber,
                ),
              if (userController.myZone.isNotEmpty) _ProfileField(label: "Operating zone", value: userController.myZone),
              if (documentCount > 0)
                _ProfileField(
                  label: "Documents",
                  value: "$documentCount ${'files'.tr} — ${isVerified ? 'approved'.tr : 'pending'.tr}",
                ),
            ];

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  InkTopBar(
                    title: 'profile'.tr,
                    onBack: () => Get.back(),
                    right: Row(mainAxisSize: MainAxisSize.min, children: [
                      GetBuilder<ThemeController>(
                        builder: (themeController) {
                          return InkIconButton(
                            icon: themeController.darkTheme ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            onTap: () => themeController.toggleTheme(),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.to(() => const ProfileInformationScreen()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: InkColors.card,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: InkColors.border),
                          ),
                          child: Text(
                            'edit'.tr,
                            style:  TextStyle(
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: InkColors.foreground,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkSurface(
                      child: Row(children: [
                        Container(
                          height: 64,
                          width: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _initialsOf(ownerName.isNotEmpty ? ownerName : companyName),
                            style: const TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 20,
                              height: 1,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Text(
                              heroTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 18,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: Colors.white,
                              ),
                            ),
                            if (ownerName.isNotEmpty && companyName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                ownerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Colors.white.withValues(alpha: 0.66),
                                ),
                              ),
                            ],
                            if (isVerified) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Text(
                                  "Verified partner",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ]),
                        ),
                      ]),
                    ),
                  ),

                  if (profileFields.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    InkSection(title: 'profile_information'.tr, child: _fieldsCard(profileFields)),
                  ],

                  if (businessFields.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    InkSection(title: 'business_information'.tr, child: _fieldsCard(businessFields)),
                  ],

                  const SizedBox(height: 24),
                  InkSection(
                    title: 'bank_information'.tr,
                    child: GetBuilder<BankInfoController>(
                      builder: (bankInfoController) {
                        final bankInfo = bankInfoController.bankInfoModel?.content;
                        final String bankName = bankInfo?.bankName ?? '';
                        final String branchName = bankInfo?.branchName ?? '';
                        final String accountNumber = bankInfo?.accNo ?? '';
                        final String routingNumber = bankInfo?.routingNumber ?? '';

                        final List<Widget> bankRows = <Widget>[
                          if (bankName.isNotEmpty)
                            _ProfileField(
                              label: 'bank_name'.tr,
                              value: branchName.isNotEmpty ? '$bankName — $branchName' : bankName,
                            ),
                          if (accountNumber.isNotEmpty)
                            _ProfileField(label: 'account_number'.tr, value: _maskedAccountNumber(accountNumber)),
                          if (routingNumber.isNotEmpty) _ProfileField(label: 'routing_number'.tr, value: routingNumber),
                        ];

                        if (bankRows.isEmpty) {
                          return InkCard(
                            padding: EdgeInsets.zero,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Get.toNamed(RouteHelper.bankInfo),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                child: Row(children: [
                                  Expanded(
                                    child: Text(
                                      'bank_information'.tr,
                                      style:  TextStyle(
                                        fontSize: 14,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
                                        color: InkColors.foreground,
                                      ),
                                    ),
                                  ),
                                   Icon(Icons.chevron_right_rounded, size: 18, color: InkColors.mutedForeground),
                                ]),
                              ),
                            ),
                          );
                        }

                        return InkCard(
                          padding: EdgeInsets.zero,
                          onTap: () => Get.toNamed(RouteHelper.bankInfo),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (int i = 0; i < bankRows.length; i++) ...[
                                  if (i != 0)  SizedBox(height: 1, child: ColoredBox(color: InkColors.border)),
                                  bankRows[i],
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkPrimaryButton(
                      label: "View account & earnings",
                      onTap: () => Get.to(() => const AccountInformation()),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        '${'app_version'.tr} ${AppConstants.appVersion}',
                        style:  TextStyle(fontSize: 12, height: 1.3, color: InkColors.mutedForeground),
                      ),
                    ),
                  ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        InkEyebrow(label),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(
            fontSize: 13.5,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: InkColors.foreground,
          ),
        ),
      ]),
    );
  }
}
