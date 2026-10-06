import 'package:demandium_provider/feature/booking_details/widget/booking_service_location.dart';
import 'package:demandium_provider/helper/booking_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/util/core_export.dart';

/// ---------------------------------------------------------------------------
/// INK design sections for Booking Details
/// Port of design/src/routes/_tabs.booking.$id.tsx — real BookingDetailsController
/// data only, all actions delegate to existing controller/repo logic.
/// ---------------------------------------------------------------------------

/// Design pill button (outline / filled) with optional leading icon + loading.
class InkPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final bool loading;

  const InkPillButton({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.filled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.fontSize = 12.5,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null && !loading;
    final Color fg = filled ? InkColors.background : (enabled ? InkColors.foreground : InkColors.mutedForeground);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? InkColors.foreground : InkColors.card,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: filled ? Colors.transparent : InkColors.border),
        ),
        child: loading
            ? SizedBox(
                height: fontSize + 4,
                width: fontSize + 4,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: fontSize + 3, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoSemiBold.copyWith(fontSize: fontSize, color: fg),
                  ),
                ],
              ),
      ),
    );
  }
}

/// label (12 muted, left) — value (13 semibold, right) row from design.
class InkInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InkInfoRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: robotoRegular.copyWith(fontSize: 12, height: 1.4, color: InkColors.mutedForeground),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: robotoSemiBold.copyWith(
                  fontSize: 13, height: 1.4, color: valueColor ?? InkColors.foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Schedule & address — Date & time / Address / Booking type rows with dividers.
/// ---------------------------------------------------------------------------
class InkScheduleAddressSection extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const InkScheduleAddressSection({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    DateTime? schedule;
    if (bookingDetails.serviceSchedule != null) {
      schedule = DateTime.tryParse(bookingDetails.serviceSchedule!);
    } else if (bookingDetails.createdAt != null) {
      schedule = DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!);
    }

    final String address = BookingHelper.composeServiceAddress(
      bookingDetails.serviceAddress ?? bookingDetails.subBooking?.serviceAddress,
      fallback: 'address_not_found'.tr,
    );

    final bool isRepeat =
        bookingDetails.bookingType == "repeat" || bookingDetails.isRepeatBooking == 1;

    return InkSection(
      title: "Schedule & address",
      margin: const EdgeInsets.only(bottom: 24),
      child: InkCard(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          children: [
            InkInfoRow(label: "Date & time", value: schedule != null ? DateConverter.dateMonthYearTime(schedule) : "-"),
             Divider(height: 1, color: InkColors.border),
            InkInfoRow(label: "Address", value: address),
             Divider(height: 1, color: InkColors.border),
            InkInfoRow(label: "Booking type", value: isRepeat ? "Repeat / recurring" : "Regular"),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Customer card — avatar + name + phone + status chip + Call / Navigate pills.
/// ---------------------------------------------------------------------------
class InkBookingCustomerCard extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final bool isSubBooking;

  const InkBookingCustomerCard({super.key, required this.bookingDetails, this.isSubBooking = false});

  @override
  Widget build(BuildContext context) {
    final ServiceAddress? address = bookingDetails.serviceAddress ?? bookingDetails.subBooking?.serviceAddress;

    final String name = (address?.contactPersonName?.isNotEmpty ?? false)
        ? address!.contactPersonName!
        : "${bookingDetails.customer?.firstName ?? ''} ${bookingDetails.customer?.lastName ?? ''}".trim();

    final String phone = (address?.contactPersonNumber?.isNotEmpty ?? false)
        ? address!.contactPersonNumber!
        : bookingDetails.customer?.phone ?? bookingDetails.customer?.email ?? "";

    final bool canNavigate = address?.lat != null && address?.lon != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                InkAvatar(name: name.isEmpty ? "?" : name, size: 46),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(fontSize: 15, height: 1.3, color: InkColors.foreground, decoration: TextDecoration.none),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoRegular.copyWith(fontSize: 12, height: 1.3, color: InkColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkStatusChip(status: bookingDetails.bookingStatus ?? "pending"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkPillButton(
                    label: "Call",
                    icon: Icons.call_rounded,
                    onTap: phone.isEmpty
                        ? null
                        : () async {
                            try {
                              final bool ok = await launchUrl(Uri(scheme: 'tel', path: phone), mode: LaunchMode.externalApplication);
                              if (!ok) {
                                showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
                              }
                            } catch (_) {
                              showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkPillButton(
                    label: "Navigate",
                    icon: Icons.location_on_outlined,
                    onTap: canNavigate ? () => _openNavigation(context, address!) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openNavigation(BuildContext context, ServiceAddress address) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog(), barrierDismissible: true);
    } else {
      showCustomDialog(child: const CustomLoader());
      try {
        final position = await Geolocator.getCurrentPosition();
        await MapUtils.openMap(address.lat ?? 23.8103, address.lon ?? 90.4125, position.latitude, position.longitude);
      } catch (_) {
        showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
      } finally {
        Get.back();
      }
    }
  }
}

/// ---------------------------------------------------------------------------
/// Progress — vertical 4 step timeline (Requested → Accepted → Ongoing →
/// Completed), stage derived from the real booking status.
/// ---------------------------------------------------------------------------
class InkProgressTimeline extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const InkProgressTimeline({super.key, required this.bookingDetails});

  static const List<String> steps = ["Requested", "Accepted", "Ongoing", "Completed"];

  static int stageIndex(String? status) {
    switch (status) {
      case 'completed':
        return 3;
      case 'ongoing':
        return 2;
      case 'accepted':
        return 1;
      default:
        return 0;
    }
  }

  String _stepCaption(int index, int stage) {
    final List<StatusHistories> histories = bookingDetails.statusHistories ?? [];
    String? historyStatus = index == 0 ? 'pending' : steps[index].toLowerCase();
    StatusHistories? history;
    for (final element in histories) {
      final String? status = element.bookingStatus;
      if (status == historyStatus || (index == 0 && status == 'requested')) {
        history = element;
      }
    }
    if (history?.updatedAt != null) {
      return DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(history!.updatedAt!));
    }
    if (index == 0 && bookingDetails.createdAt != null) {
      return DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!));
    }
    if (index <= stage && bookingDetails.serviceSchedule != null) {
      return DateConverter.dateMonthYearTime(DateTime.tryParse(bookingDetails.serviceSchedule!));
    }
    if (index <= stage && bookingDetails.createdAt != null) {
      return DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(bookingDetails.createdAt!));
    }
    return "Pending";
  }

  @override
  Widget build(BuildContext context) {
    final int stage = stageIndex(bookingDetails.bookingStatus);
    final bool allDone = stage >= steps.length - 1;

    return InkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(steps.length, (i) {
          final bool done = allDone || i < stage;
          final bool current = !allDone && i == stage;
          final bool future = i > stage;

          Widget dot;
          if (done) {
            dot = Container(
              height: 24,
              width: 24,
              decoration:  BoxDecoration(color: InkColors.foreground, shape: BoxShape.circle),
              child:  Icon(Icons.check_rounded, size: 14, color: InkColors.background),
            );
          } else if (current) {
            dot = Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: InkColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: InkColors.foreground, width: 2),
              ),
              child: Text(
                "${i + 1}",
                style: robotoBold.copyWith(fontSize: 10, color: InkColors.foreground),
              ),
            );
          } else {
            dot = Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: InkColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: InkColors.border),
              ),
              child: Text(
                "${i + 1}",
                style: robotoBold.copyWith(fontSize: 10, color: InkColors.mutedForeground),
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  dot,
                  if (i < steps.length - 1)
                    Container(
                      height: 32,
                      width: 1,
                      color: i < stage ? InkColors.foreground : InkColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        steps[i],
                        style: robotoSemiBold.copyWith(
                          fontSize: 13.5,
                          height: 1.3,
                          color: future ? InkColors.mutedForeground : InkColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _stepCaption(i, stage),
                        style: robotoRegular.copyWith(fontSize: 11, height: 1.3, color: InkColors.mutedForeground),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Service items — line items (name × qty) + Total (payment method).
/// ---------------------------------------------------------------------------
class InkServiceItemsCard extends StatelessWidget {
  final BookingDetailsContent bookingDetails;

  const InkServiceItemsCard({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final List<ItemService> items = bookingDetails.details ?? [];

    return InkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 10, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: items[i].serviceName ?? "",
                        style: robotoRegular.copyWith(fontSize: 13, height: 1.4, color: InkColors.foreground),
                        children: [
                          TextSpan(
                            text: " ×${items[i].quantity ?? 1}",
                            style: robotoRegular.copyWith(fontSize: 13, height: 1.4, color: InkColors.mutedForeground),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkMoney(
                    BookingHelper.getBookingServiceUnitConst(items[i]),
                    style:  TextStyle(fontSize: 13, color: InkColors.foreground),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1)  Divider(height: 1, color: InkColors.border),
          ],
          const SizedBox(height: 12),
           Divider(height: 1, color: InkColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  bookingDetails.paymentMethod != null
                      ? "Total (${bookingDetails.paymentMethod!.tr})"
                      : 'total'.tr,
                  style: robotoBold.copyWith(fontSize: 13, height: 1.3, color: InkColors.foreground),
                ),
              ),
              InkMoney(
                bookingDetails.totalBookingAmount ?? 0,
                style:  TextStyle(fontSize: 16, color: InkColors.foreground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Assign serviceman — first active servicemen with Assign / Assigned pill,
/// wired to the existing assign-technician API + existing expandable sheet.
/// ---------------------------------------------------------------------------
class InkAssignServicemanSection extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final String bookingId;
  final bool isSubBooking;

  const InkAssignServicemanSection({
    super.key,
    required this.bookingDetails,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(builder: (servicemanSetupController) {
      final BookingDetailsController bookingDetailsController = Get.find<BookingDetailsController>();

      final String? assignedServicemanId = bookingDetails.servicemanId;
      final String assignedName = bookingDetails.serviceman?.user != null
          ? "${bookingDetails.serviceman!.user!.firstName ?? ''} ${bookingDetails.serviceman!.user!.lastName ?? ''}".trim()
          : "";
      final String assignedPhone = bookingDetails.serviceman?.user?.phone ?? "";
      final String assignedRole = bookingDetails.serviceman?.user?.userType ?? "";

      bool canReassign = bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing";
      bool reAssignServiceman = isSubBooking
          ? bookingDetails.subBooking?.serviceman != null
          : bookingDetails.serviceman != null;

      final List<ServicemanModel> activeServicemanList = (servicemanSetupController.servicemanList ?? [])
          .where((element) => element.isActive == 1)
          .toList();

      bool isAssigned(ServicemanModel model) {
        if (assignedServicemanId == null) return false;
        return assignedServicemanId == model.serviceman?.id ||
            assignedServicemanId == model.id ||
            (assignedName.isNotEmpty &&
                assignedName == "${model.firstName ?? ''} ${model.lastName ?? ''}".trim());
      }

      final List<ServicemanModel> shownList =
          activeServicemanList.where((model) => !isAssigned(model)).take(3).toList();

      void openAssignSheet() {
        servicemanSetupController.fromBookingDetailsPage(true);
        bookingDetailsController.showHideExpandView(350);
      }

      void assign(ServicemanModel model) {
        showCustomDialog(
          child: ConfirmationDialog(
            icon: Images.servicemanImage,
            description: '',
            title: "${"are_you_want_to_assign".tr} ${model.firstName ?? ""} ${model.lastName ?? ""} ${'for_this_booking'.tr}?",
            yesButtonColor: Theme.of(Get.context!).primaryColor,
            onYesPressed: () {
              servicemanSetupController.assignServiceman(
                bookingId: bookingId != "null" ? bookingId : null,
                subBookingId: bookingDetailsController.subBookingDetails?.content?.id,
                servicemanId: model.serviceman!.id!,
                reAssignServiceman: reAssignServiceman,
              );
              Get.back();
            },
          ),
          barrierDismissible: true,
        );
      }

      Widget buildRows() {
        final List<Widget> rows = [];

        String roleOrPhone(String? userType, String? phone) {
          final String role = (userType ?? "").trim();
          if (role.isNotEmpty) return role.capitalizeFirst ?? role;
          return phone ?? "";
        }

        if (assignedName.isNotEmpty) {
          rows.add(_ServicemanRow(
            name: assignedName,
            subtitle: roleOrPhone(assignedRole, assignedPhone),
            assigned: true,
            enabled: canReassign,
            onTap: canReassign ? openAssignSheet : null,
          ));
        }
        for (int i = 0; i < shownList.length; i++) {
          if (rows.isNotEmpty) {
            rows.add( Divider(height: 1, color: InkColors.border, indent: 16, endIndent: 16));
          }
          rows.add(_ServicemanRow(
            name: "${shownList[i].firstName ?? ''} ${shownList[i].lastName ?? ''}".trim(),
            subtitle: roleOrPhone(shownList[i].userType, shownList[i].phone),
            assigned: false,
            enabled: true,
            onTap: () => assign(shownList[i]),
          ));
        }
        if (rows.isEmpty) {
          rows.add(Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'no_serviceman_available'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(fontSize: 13, color: InkColors.mutedForeground),
            ),
          ));
        }
        return Column(children: rows);
      }

      return InkSection(
        title: "Assign serviceman",
        action: activeServicemanList.isEmpty ? null : 'Assign_serviceman'.tr,
        onAction: activeServicemanList.isEmpty ? null : openAssignSheet,
        margin: const EdgeInsets.only(bottom: 24),
        child: InkCard(padding: const EdgeInsets.symmetric(vertical: 6), child: buildRows()),
      );
    });
  }
}

class _ServicemanRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool assigned;
  final bool enabled;
  final VoidCallback? onTap;

  const _ServicemanRow({
    required this.name,
    required this.subtitle,
    required this.assigned,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          InkAvatar(name: name.isEmpty ? "?" : name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoSemiBold.copyWith(fontSize: 13.5, height: 1.3, color: InkColors.foreground),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: robotoRegular.copyWith(fontSize: 11, height: 1.3, color: InkColors.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          assigned
              ? GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: InkColors.foreground, borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      "Assigned",
                      style: robotoSemiBold.copyWith(fontSize: 11, color: InkColors.background),
                    ),
                  ),
                )
              : InkPillButton(
                  label: "Assign",
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  onTap: enabled ? onTap : null,
                ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Action area — primary CTA switches by real status and calls the existing
/// controller actions (accept / start / complete + OTP & photo evidence flows),
/// secondary = Invoice + Edit booking, destructive = red text pill.
/// ---------------------------------------------------------------------------
class InkBookingActionBar extends StatelessWidget {
  final BookingDetailsContent bookingDetails;
  final String bookingId;
  final bool isSubBooking;

  const InkBookingActionBar({
    super.key,
    required this.bookingDetails,
    required this.bookingId,
    required this.isSubBooking,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookingDetailsController>(builder: (bookingDetailsController) {
      final ConfigModel configModel = Get.find<SplashController>().configModel;
      final String status = bookingDetails.bookingStatus ?? "";
      final String dropdown = isSubBooking
          ? bookingDetailsController.subBookingDropDownValue
          : bookingDetailsController.dropDownValue;

      if (isSubBooking && status == "pending") return const SizedBox.shrink();

      final bool isPartial = bookingDetails.partialPayments != null && bookingDetails.partialPayments!.isNotEmpty;
      final bool subBookingPaid = isSubBooking && bookingDetails.isPaid == 1;
      final bool canEdit = !subBookingPaid &&
          (configModel.content?.providerCanEditBooking ?? 0) == 1 &&
          !isPartial &&
          (status == "accepted" || status == "ongoing") &&
          !(bookingDetails.isGuest == 1 && bookingDetails.paymentMethod != "cash_after_service");

      final bool canCancel = bookingDetailsController.statusTypeList.contains("canceled") &&
          !(isSubBooking && bookingDetails.isPaid == 1);

      Widget primary;
      if (status == "pending") {
        primary = bookingDetailsController.isAcceptButtonLoading
            ? const _InkPrimaryLoading()
            : InkPrimaryButton(label: "Accept booking", onTap: _accept(context, bookingDetailsController));
      } else if (dropdown == "completed" &&
          bookingDetailsController.showPhotoEvidenceField &&
          configModel.content?.bookingOtpVerification == 1) {
        primary = InkPrimaryButton(
          label: 'request_for_otp'.tr,
          onTap: () {
            bookingDetailsController.sendBookingOTPNotification(bookingId, shouldUpdate: false);
            showCustomBottomSheet(
                child: OtpVerificationBottomSheet(bookingId: bookingId, isSubBooking: isSubBooking));
          },
        );
      } else if (status == "accepted") {
        primary = bookingDetailsController.isStatusUpdateLoading
            ? const _InkPrimaryLoading()
            : InkPrimaryButton(label: "Start service", onTap: () => _startService(bookingDetailsController));
      } else if (status == "ongoing") {
        primary = bookingDetailsController.isStatusUpdateLoading
            ? const _InkPrimaryLoading()
            : InkPrimaryButton(
                label: "Mark completed",
                onTap: () => _markCompleted(context, bookingDetailsController, configModel),
              );
      } else {
        primary = InkPrimaryButton(label: "Download invoice", onTap: () => _downloadInvoice());
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          children: [
            primary,
            if (status != "pending") ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkPillButton(
                      label: 'invoice'.tr,
                      icon: Icons.description_outlined,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      onTap: _downloadInvoice,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkPillButton(
                      label: 'edit_booking'.tr,
                      icon: Icons.person_add_alt_outlined,
                      fontSize: 13,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      onTap: canEdit
                          ? () {
                              Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrail) {
                                if (isTrail) {
                                  Get.to(() => BookingEditScreen(
                                        bookingEditType: isSubBooking
                                            ? BookingEditType.subBooking
                                            : BookingEditType.regular,
                                      ));
                                }
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
            if (status == "pending" || canCancel) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: status == "pending" ? _ignore(context, bookingDetailsController) : _cancel(bookingDetailsController),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    status == "pending" ? 'ignore'.tr : "Cancel booking",
                    textAlign: TextAlign.center,
                    style: robotoSemiBold.copyWith(fontSize: 12.5, color: InkColors.destructive),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  VoidCallback _accept(BuildContext context, BookingDetailsController controller) {
    return () {
      if (Get.find<UserProfileController>().isSubscriptionRequired &&
          Get.find<UserProfileController>()
              .providerModel
              ?.content
              ?.subscriptionInfo
              ?.subscribedPackageDetails
              ?.isCanceled ==
          1) {
        showCustomSnackBar(
            "your_subscription_plan_has_been_cancelled_you_will_not_able_to_accept_any_booking_request".tr,
            type: ToasterMessageType.info);
      } else {
        Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial) {
          if (isTrial) {
            showCustomDialog(
              child: ConfirmationDialog(
                yesButtonColor: Theme.of(Get.context!).primaryColor,
                title: "want_accept_this_booking?".tr,
                icon: Images.servicemanImage,
                description: 'accept_booking_hint_text'.tr,
                onYesPressed: () {
                  controller.acceptBookingRequest(bookingId);
                  Get.back();
                },
                onNoPressed: () => Get.back(),
              ),
            );
          }
        });
      }
    };
  }

  VoidCallback _ignore(BuildContext context, BookingDetailsController controller) {
    return () {
      showCustomDialog(
        child: ConfirmationDialog(
          yesButtonColor: Theme.of(Get.context!).primaryColor,
          title: "are_you_sure_to_ignore_the_booking_request".tr,
          description: "once_you_ignore_the_request",
          noButtonColor: Theme.of(context).colorScheme.error,
          noTextColor: Colors.white,
          icon: Images.warning,
          noButtonText: "cancel",
          onYesPressed: () {
            controller.ignoreBookingRequest(bookingId);
            Get.back();
            Get.back();
          },
        ),
      );
    };
  }

  void _startService(BookingDetailsController controller) {
    controller.changeBookingStatusDropDownValue("ongoing", isSubBooking);
    controller.changeBookingStatus(bookingId, bookingStatus: bookingDetails.bookingStatus, isSubBooking: isSubBooking);
  }

  void _markCompleted(
      BuildContext context, BookingDetailsController controller, ConfigModel configModel) {
    final String dropdown = isSubBooking
        ? controller.subBookingDropDownValue
        : controller.dropDownValue;
    final bool imageVerification = configModel.content?.bookingImageVerification == 1;
    final bool otpVerification = configModel.content?.bookingOtpVerification == 1;

    if (dropdown != "completed") {
      controller.changeBookingStatusDropDownValue("completed", isSubBooking);

      if (imageVerification && controller.pickedPhotoEvidence.isEmpty) {
        controller.changePhotoEvidenceStatus(status: false);
        showCustomBottomSheet(
            child: CameraButtonSheet(bookingId: bookingId, isSubBooking: isSubBooking));
      } else if (imageVerification || otpVerification) {
        controller.changePhotoEvidenceStatus(status: true);
        if (!otpVerification) {
          controller.changeBookingStatus(bookingId,
              bookingStatus: bookingDetails.bookingStatus, isSubBooking: isSubBooking);
        }
      } else {
        controller.changePhotoEvidenceStatus(status: false);
        controller.changeBookingStatus(bookingId,
            bookingStatus: bookingDetails.bookingStatus, isSubBooking: isSubBooking);
      }
    } else {
      controller.changeBookingStatus(bookingId,
          bookingStatus: bookingDetails.bookingStatus, isSubBooking: isSubBooking);
    }
  }

  VoidCallback _cancel(BookingDetailsController controller) {
    return () {
      controller.changeBookingStatusDropDownValue("canceled", isSubBooking);
      controller.changeBookingStatus(bookingId, bookingStatus: bookingDetails.bookingStatus, isSubBooking: isSubBooking);
    };
  }

  Future<void> _downloadInvoice() async {
    showCustomDialog(child: const CustomLoader());
    try {
      final String languageCode = Get.find<LocalizationController>().locale.languageCode;
      final String uri =
          "${AppConstants.baseUrl}${isSubBooking ? AppConstants.singleRepeatBookingInvoiceUrl : AppConstants.regularBookingInvoiceUrl}${bookingDetails.id}/$languageCode";
      final bool opened = await launchUrl(Uri.parse(uri), mode: LaunchMode.externalApplication);
      if (!opened) {
        showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
      }
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    } finally {
      Get.back();
    }
  }
}

class _InkPrimaryLoading extends StatelessWidget {
  const _InkPrimaryLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: InkColors.foreground, borderRadius: BorderRadius.circular(50)),
      child:  SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: InkColors.background),
      ),
    );
  }
}
