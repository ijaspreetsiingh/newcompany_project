import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

/// "Book for other location" — relative/friend ke liye service book karne ka
/// naya redesigned screen (tabs):
///
///  Tab 1 (Location): pehle friend ki location lo (map + search + history).
///                    Us location ke zone me cart ki service available nahi
///                    to wahi "service not available" popup (RadiusSearchDialog)
///                    jo user ke apni location par aata hai.
///  Tab 2 (Details):  zone pass hone par house/floor/contact details bharo aur
///                    save karo → history me save + Address & Schedule screen
///                    par friend location active ho jati hai.
class BookOtherLocationScreen extends StatefulWidget {
  const BookOtherLocationScreen({super.key});

  @override
  State<BookOtherLocationScreen> createState() =>
      _BookOtherLocationScreenState();
}

class _BookOtherLocationScreenState extends State<BookOtherLocationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MapController _mapController;
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();

  final TextEditingController _serviceAddressController =
      TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  final FocusNode _houseNode = FocusNode();
  final FocusNode _floorNode = FocusNode();
  final FocusNode _streetNode = FocusNode();
  final FocusNode _zipNode = FocusNode();
  final FocusNode _nameNode = FocusNode();
  final FocusNode _numberNode = FocusNode();

  LatLng? _initialPosition;
  LatLng? _currentLatLng;
  Timer? _idleTimer;

  bool _checking = false;
  bool _saving = false;
  FriendZoneCheckResult? _checkResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mapController = MapController();

    final LocationController locationController =
        Get.find<LocationController>();
    locationController.resetAddress();
    Get.find<FriendLocationController>().loadHistory();

    locationController.countryDialCode = CountryCode.fromCountryCode(
      Get.find<SplashController>().configModel.content?.countryCode ?? "BD",
    ).dialCode!;

    final AddressModel? userAddress = locationController.getUserAddress();
    _initialPosition = LatLng(
      double.tryParse(userAddress?.latitude ?? "") ??
          (Get.find<SplashController>()
                  .configModel
                  .content
                  ?.defaultLocation
                  ?.latitude ??
              23.0000),
      double.tryParse(userAddress?.longitude ?? "") ??
          (Get.find<SplashController>()
                  .configModel
                  .content
                  ?.defaultLocation
                  ?.longitude ??
              90.0000),
    );

    // Contact user ki detail se prefilled — user edit karke friend ka daal sakta.
    _contactNameController.text =
        Get.find<UserController>().userInfoModel?.fName ?? '';
    _contactNumberController.text =
        Get.find<UserController>().userInfoModel?.phone ?? '';

    // Map khulne par initial point ka reverse-geocode + zone check.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      locationController.updatePosition(_initialPosition!, false);
    });
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _tabController.dispose();
    _serviceAddressController.dispose();
    _houseController.dispose();
    _floorController.dispose();
    _streetController.dispose();
    _zipController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  AddressModel _pickedAddress(LocationController lc) {
    final AddressModel pick = lc.pickAddress;
    final String addressText =
        (pick.address != null && pick.address!.trim().isNotEmpty)
            ? pick.address!.trim()
            : _serviceAddressController.text.trim();
    return AddressModel(
      address: addressText,
      latitude: lc.pickPosition.latitude.toString(),
      longitude: lc.pickPosition.longitude.toString(),
      city: pick.city,
      country: pick.country,
      zoneId: (pick.zoneId != null && pick.zoneId!.isNotEmpty)
          ? pick.zoneId
          : (lc.zoneID.isNotEmpty ? lc.zoneID : null),
      availableServiceCountInZone: pick.availableServiceCountInZone,
      addressLabel: AddressLabel.others.name,
      addressType: AddressLabel.others.name,
    );
  }

  // ------------------------------------------------------------- tab 1 flow

  Future<void> _onNextLocation() async {
    final LocationController lc = Get.find<LocationController>();
    final FriendLocationController friendController =
        Get.find<FriendLocationController>();

    final AddressModel picked = _pickedAddress(lc);
    if (picked.latitude == null ||
        (double.tryParse(picked.latitude ?? '') ?? 0) == 0) {
      customSnackBar('search_location'.tr, type: ToasterMessageType.info);
      return;
    }

    setState(() => _checking = true);
    final FriendZoneCheckResult result =
        await friendController.validateCartAt(picked);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _checkResult = result;
    });

    if (result.isAvailable) {
      _tabController.animateTo(1);
    } else if (result.status == FriendZoneStatus.notAvailable) {
      _showServiceUnavailableDialog();
    } else {
      customSnackBar(
        'connection_to_api_server_failed'.tr,
        type: ToasterMessageType.error,
      );
    }
  }

  /// Zone / service / provider na mile — user ki location wala hi final popup.
  void _showServiceUnavailableDialog() {
    RadiusSearchDialog.showFinal(
      radius: SearchRadiusState.activeRadius ??
          SearchRadiusState.initialRadius ??
          5,
      maxRadius: SearchRadiusState.maxRadius ?? 50,
      onDismiss: () {},
      onChangeAddress: () {
        if (mounted && _tabController.index != 0) {
          _tabController.animateTo(0);
        }
      },
    );
  }

  Future<void> _selectFromHistory(AddressModel address) async {
    final FriendLocationController friendController =
        Get.find<FriendLocationController>();
    setState(() => _checking = true);
    final FriendZoneCheckResult result =
        await friendController.selectFromHistory(address);
    if (!mounted) return;
    setState(() => _checking = false);

    if (result.isAvailable) {
      customSnackBar(
        'friend_location_saved_successfully'.tr,
        type: ToasterMessageType.success,
      );
      Get.back(result: true);
    } else if (result.status == FriendZoneStatus.notAvailable) {
      _showServiceUnavailableDialog();
    } else {
      customSnackBar(
        'connection_to_api_server_failed'.tr,
        type: ToasterMessageType.error,
      );
    }
  }

  // ------------------------------------------------------------- tab 2 flow

  Future<void> _onSaveLocation() async {
    final LocationController lc = Get.find<LocationController>();
    final FriendLocationController friendController =
        Get.find<FriendLocationController>();

    final String contactName = _contactNameController.text.trim();
    final String rawNumber = _contactNumberController.text.trim();
    if (contactName.isEmpty ||
        contactName == 'null' ||
        rawNumber.isEmpty ||
        rawNumber == 'null') {
      customSnackBar(
        'please_input_contact_person_name_and_phone_number'.tr,
        type: ToasterMessageType.info,
      );
      return;
    }

    final AddressModel friend = _pickedAddress(lc);
    if ((double.tryParse(friend.latitude ?? '') ?? 0) == 0) {
      customSnackBar('search_location'.tr, type: ToasterMessageType.info);
      return;
    }
    friend.house = _houseController.text.trim();
    friend.floor = _floorController.text.trim();
    friend.street = _streetController.text.trim();
    friend.zipCode = _zipController.text.trim();
    friend.contactPersonName = contactName;
    friend.contactPersonNumber = lc.countryDialCode +
        PhoneVerificationHelper.isPhoneValid(
          lc.countryDialCode + rawNumber,
          fromAuthPage: false,
        );

    setState(() => _saving = true);

    // Tab 1 par jis location ko validate kiya tha wahi hai to dobara call nahi.
    final FriendZoneCheckResult? preCheck =
        friendController.cachedCheckFor(friend);
    final FriendZoneCheckResult result =
        await friendController.selectFriendLocation(friend, preCheck: preCheck);

    if (!mounted) return;
    setState(() => _saving = false);

    if (result.isAvailable) {
      customSnackBar(
        'friend_location_saved_successfully'.tr,
        type: ToasterMessageType.success,
      );
      Get.back(result: true);
    } else if (result.status == FriendZoneStatus.notAvailable) {
      _showServiceUnavailableDialog();
    } else {
      customSnackBar(
        'connection_to_api_server_failed'.tr,
        type: ToasterMessageType.error,
      );
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'book_for_other_location'.tr,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: Colors.grey[500],
          indicatorColor: primary,
          labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
          unselectedLabelStyle: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
          ),
          tabs: [
            Tab(icon: const Icon(Icons.location_on_outlined, size: 20), text: 'tab_location'.tr),
            Tab(icon: const Icon(Icons.home_outlined, size: 20), text: 'tab_details'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildLocationTab(context), _buildDetailsTab(context)],
      ),
    );
  }

  // ------------------------------------------------------------- location tab

  Widget _buildLocationTab(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 52, child: _buildMapSection(context)),
        Expanded(
          flex: 48,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: GetBuilder<LocationController>(
              builder: (locationController) {
                final String addressText =
                    locationController.pickAddress.address?.isNotEmpty ?? false
                        ? locationController.pickAddress.address!
                        : 'select_friend_location_hint'.tr;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.place_outlined, color: primaryAccent),
                          const SizedBox(
                            width: Dimensions.paddingSizeDefault,
                          ),
                          Expanded(
                            child: Text(
                              addressText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color:
                                    Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _buildHistorySection(context),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _checking ? null : _onNextLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radiusDefault,
                            ),
                          ),
                        ),
                        child: _checking
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'next'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return GetBuilder<LocationController>(
      builder: (locationController) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialPosition!,
                initialZoom: 15.5,
                minZoom: 0,
                maxZoom: 16,
                onPositionChanged: (camera, hasGesture) {
                  if (!hasGesture) return;
                  _idleTimer?.cancel();
                  locationController.updateCameraMovingStatus(true);
                  _currentLatLng = camera.center;
                  _idleTimer = Timer(const Duration(milliseconds: 500), () {
                    locationController.updateCameraMovingStatus(false);
                    if (_currentLatLng != null) {
                      locationController.updatePosition(_currentLatLng!, false);
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.jassdbx.jassods',
                ),
              ],
            ),

            if (locationController.loading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: Image.asset(Images.marker, height: 44, width: 44),
              ),

            Positioned(
              top: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              child: LocationSearchDialog(
                getMapController: () => _mapController,
                pickedLocation: locationController.pickAddress.address,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSmall,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          (locationController.pickAddress.address?.isNotEmpty ??
                                  false)
                              ? locationController.pickAddress.address!
                              : 'search_location'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: Dimensions.paddingSizeDefault,
              right: Dimensions.paddingSizeDefault,
              child: InkWell(
                onTap: () async {
                  try {
                    await locationController.getCurrentLocation(
                      false,
                      deviceCurrentLocation: true,
                      mapController: _mapController,
                    );
                  } catch (_) {
                    customSnackBar(
                      'you_have_to_allow'.tr,
                      type: ToasterMessageType.info,
                    );
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusSmall,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: Theme.of(context).primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return GetBuilder<FriendLocationController>(
      builder: (friendController) {
        if (friendController.history.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'saved_friend_locations'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: friendController.history.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final AddressModel item = friendController.history[index];
                  final bool isSelected = friendController.isSameAsSelected(item);
                  return InkWell(
                    onTap: _checking ? null : () => _selectFromHistory(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryAccent.withValues(alpha: 0.12)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusSmall,
                        ),
                        border: Border.all(
                          color: isSelected ? primaryAccent : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: isSelected
                                ? primaryAccent
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 170),
                            child: Text(
                              item.address ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: isSelected
                                    ? primaryAccent
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------- details tab

  Widget _buildDetailsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: GetBuilder<LocationController>(
        builder: (locationController) {
          return Form(
            key: _detailsFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'friend_location_details'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'select_friend_location_hint'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Colors.grey[600],
                  ),
                ),
                if (_checkResult != null && _checkResult!.isAvailable) ...[
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.10),
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${'available_service'.tr} (${_checkResult!.availableServiceCount})',
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusDefault,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.place_outlined, color: primaryAccent, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          (locationController.pickAddress.address?.isNotEmpty ??
                                  false)
                              ? locationController.pickAddress.address!
                              : 'select_friend_location'.tr,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        title: 'house'.tr,
                        hintText: 'enter_house_no'.tr,
                        controller: _houseController,
                        focusNode: _houseNode,
                        nextFocus: _floorNode,
                        inputType: TextInputType.streetAddress,
                        isrequired: false,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: CustomTextField(
                        title: 'floor'.tr,
                        hintText: 'enter_floor_no'.tr,
                        controller: _floorController,
                        focusNode: _floorNode,
                        nextFocus: _streetNode,
                        inputType: TextInputType.streetAddress,
                        isrequired: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        title: 'street'.tr,
                        hintText: 'enter_street'.tr,
                        controller: _streetController,
                        focusNode: _streetNode,
                        nextFocus: _zipNode,
                        inputType: TextInputType.streetAddress,
                        isrequired: false,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),
                    Expanded(
                      child: CustomTextField(
                        title: 'zip_code'.tr,
                        hintText: 'enter_zip_code'.tr,
                        controller: _zipController,
                        focusNode: _zipNode,
                        nextFocus: _nameNode,
                        inputType: TextInputType.text,
                        isrequired: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextField(
                  title: 'contact_person_name'.tr,
                  hintText: 'contact_person_name'.tr,
                  controller: _contactNameController,
                  focusNode: _nameNode,
                  nextFocus: _numberNode,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),

                CustomTextField(
                  title: 'contact_person_number'.tr,
                  hintText: 'contact_person_number'.tr,
                  controller: _contactNumberController,
                  focusNode: _numberNode,
                  inputType: TextInputType.phone,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _onSaveLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radiusDefault,
                        ),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'save_location'.tr,
                            style: robotoBold.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}
