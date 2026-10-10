import 'dart:ui';

import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({super.key});
  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen>{

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<BookingRequestController>().updateBookingRequestIndex(1);
    Get.find<BookingRequestController>().updateSelectedServiceType();
    Get.find<BookingRequestController>().getBookingRequestList('pending',1,reload: true, isFirst: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Design filter button: Any status -> Pending -> Ongoing -> Any status.
  /// Uses the existing controller status filter (tab index), so no extra API call
  /// is introduced — the same tab listener triggers getBookingRequestList.
  void _cycleStatusFilter(BookingRequestController controller){
    final int nextIndex = controller.currentIndex == 0 ? 1 : controller.currentIndex == 1 ? 3 : 0;
    controller.updateBookingRequestIndex(nextIndex);
    controller.menuScrollController?.scrollToIndex(
      nextIndex, preferPosition: AutoScrollPosition.middle,
      duration: const Duration(milliseconds: 500),
    );
    controller.menuScrollController?.highlight(nextIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<UserProfileController>(builder: (userController){
          return GetBuilder<BookingRequestController>(
            builder:(bookingRequestController){
              return Column(children: [
                _buildHeader(context, bookingRequestController),

                Expanded(
                  child: TabBarView(
                    controller: bookingRequestController.tabController,
                    dragStartBehavior: DragStartBehavior.down,
                    children: List<Widget>.generate(
                          6,
                          (index) => BookingRequestList(query: _searchQuery),
                        ),
                  ),
                ),
              ],);
            },
          );
        }),
      ),
    );
  }

  /// Sticky design header: title + circular calendar / filter buttons,
  /// pill search field, service type pills, status pills, status filter note.
  Widget _buildHeader(BuildContext context, BookingRequestController controller){
    final List<String> serviceTypePills = ['all'.tr, 'regular'.tr, 'repeat'.tr];
    final List<ServiceType> serviceTypes = [ServiceType.all, ServiceType.regular, ServiceType.repeat];
    final int activeServiceIndex = serviceTypes.indexOf(controller.selectedServiceType);
    final bool showStatusFilter = controller.currentIndex != 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: InkColors.background.withValues(alpha: 0.90),
        border:  Border(bottom: BorderSide(color: InkColors.border)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                'requests'.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: displayBold.copyWith(fontSize: 22, height: 1.15, color: InkColors.foreground),
              ),
            ),
            InkIconButton(
              icon: Icons.calendar_month_outlined,
              onTap: () => Get.toNamed(RouteHelper.getCalendarOrderRoute()),
            ),
            const SizedBox(width: 8),
            InkIconButton(
              icon: Icons.tune,
              onTap: () => _cycleStatusFilter(controller),
            ),
          ]),

          const SizedBox(height: 12),

          InkSearchField(
            hint: 'Search customer, service or ID',
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),

          const SizedBox(height: 12),

          InkPills(
            items: serviceTypePills,
            value: activeServiceIndex < 0 ? serviceTypePills.first : serviceTypePills[activeServiceIndex],
            onChanged: (value) {
              final int index = serviceTypePills.indexOf(value);
              controller.updateSelectedServiceType(type: serviceTypes[index < 0 ? 0 : index]);
            },
          ),

          const BookingRequestMenuBar(),

          if (showStatusFilter)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${'filter'.tr}: ${controller.bookingStatus.tr.capitalizeFirst ?? controller.bookingStatus}',
                style: robotoRegular.copyWith(fontSize: 11, height: 1.3, color: InkColors.mutedForeground),
              ),
            ),
        ],
      ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionCanceledView extends StatelessWidget {
  const SubscriptionCanceledView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

          Text("your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request".tr, style: robotoRegular.copyWith(color: InkColors.mutedForeground),
            textAlign: TextAlign.center,),

          const SizedBox(height: Dimensions.paddingSizeDefault,),

          CustomButton(
            btnTxt: 'choose_plan'.tr,
            width: 180, height: 45,
            radius: Dimensions.radiusLarge,
            onPressed: () {
              Get.toNamed(RouteHelper.getBusinessPlanScreen());
            },
          ),
        ],),
      ),
    );
  }
}

class TurnOnServiceAvailability extends StatelessWidget {
  const TurnOnServiceAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [

          Text("service_availability_option_has_turned_off".tr, style: robotoRegular.copyWith(color: InkColors.mutedForeground),
            textAlign: TextAlign.center,),

          const SizedBox(height: Dimensions.paddingSizeDefault,),

          InkWell(
            onTap: () => Get.to(const BusinessSettingScreen()),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(color: InkColors.foreground),
              ), padding:  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall-3),
                child: Text("go_to_business_settings".tr, style: robotoRegular.copyWith(color: InkColors.foreground),)),
          )

        ],),
      ),
    );
  }
}

class BookingRequestList extends StatefulWidget {
  final String query;
  const BookingRequestList({super.key, this.query = ''});

  @override
  State<BookingRequestList> createState() => _BookingRequestListState();
}

class _BookingRequestListState extends State<BookingRequestList> {
  int value =  1;


  @override
  void initState() {
    super.initState();

    Get.find<BookingRequestController>().tabController?.addListener(() {

      if(value==1){
        Future.delayed(const Duration(milliseconds: 100), (){

          Get.find<BookingRequestController>().menuScrollController?.scrollToIndex(
            Get.find<BookingRequestController>().tabController!.index, preferPosition: AutoScrollPosition.middle,
            duration: const Duration(milliseconds: 500),
          );
          Get.find<BookingRequestController>().menuScrollController?.highlight( Get.find<BookingRequestController>().tabController!.index);
          Get.find<BookingRequestController>().updateBookingRequestIndex( Get.find<BookingRequestController>().tabController!.index);

          Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingRequestStatusList[Get.find<BookingRequestController>().tabController!.index], 1, reload: true);

        });

        value--;

      }

    });

    }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(builder: (userProfileController){
      return GetBuilder<BookingRequestController>(builder: (bookingRequestController){
        return bookingRequestController.bookingRequestList == null ?
        const BookingRequestItemShimmer():

        bookingRequestController.currentIndex == 1  && userProfileController.providerModel?.content?.providerInfo?.serviceAvailability == 0 ?
        Center(
          child: SizedBox(height: Get.height * 0.7,
            child:const TurnOnServiceAvailability(),
          ),
        ) : bookingRequestController.currentIndex == 1  &&  userProfileController.isSubscriptionRequired && userProfileController.providerModel?.content?.subscriptionInfo?.subscribedPackageDetails?.isCanceled == 1 ? Center(
          child: SizedBox(height: Get.height * 0.7,
            child:const SubscriptionCanceledView(),
          ),
        ) : bookingRequestController.bookingRequestList!.isEmpty ? Center(
          child: SizedBox(height: Get.height * 0.7,
            child: NoDataScreen(
                text: bookingRequestController.currentIndex == 0 ? "you_do_not_have_any_booking_request_yet".tr :
                '${'you_have_not'.tr} ${bookingRequestController.bookingStatus.tr.toLowerCase()} ${"request_yet".tr}',
                type: NoDataType.request
            ),
          ),
        ) : BookingRequestListview(query: widget.query);
      });
    });
  }
}
