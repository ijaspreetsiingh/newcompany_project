import 'package:get/get.dart';
import 'package:demandium_serviceman/utils/core_export.dart';

/// Serviceman ka "Recheck Tasks" screen — customer ki completed booking
/// par 15 din ke andar recheck aaya hai, yahan se wapas jakar check kare.
class RecheckListScreen extends StatefulWidget {
  const RecheckListScreen({super.key});

  @override
  State<RecheckListScreen> createState() => _RecheckListScreenState();
}

class _RecheckListScreenState extends State<RecheckListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RecheckController>().getRecheckList(reload: true);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      Get.find<RecheckController>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.kBackground,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          PageHeader(
            title: 'recheck_tasks'.tr,
            subtitle: 'recheck_tasks_subtitle'.tr,
            onBack: () => Get.back(),
          ),

          GetBuilder<RecheckController>(
            builder: (controller) {
              if (controller.isLoading) {
                return const Expanded(child: Center(child: CircularProgressIndicator()));
              }

              if (controller.recheckList.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                      child: Text(
                        'no_recheck_tasks'.tr,
                        textAlign: TextAlign.center,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: context.kMutedForeground,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: RefreshIndicator(
                  color: context.kPrimary,
                  onRefresh: () => controller.getRecheckList(reload: true),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    itemCount: controller.recheckList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      final dynamic item = controller.recheckList[index];
                      final String id = '${item['id'] ?? ''}';
                      final String status = '${item['status'] ?? 'requested'}';
                      final String reason = '${item['reason'] ?? ''}';
                      final String note = '${item['serviceman_note'] ?? ''}';
                      final String dueAt = '${item['due_at'] ?? ''}';

                      final dynamic booking = item['booking'];
                      final String readableId = '${booking?['readable_id'] ?? ''}';
                      final String address = '${booking?['service_address']?['address'] ?? ''}';
                      final dynamic customer = item['customer'] ?? booking?['customer'];
                      final String customerName = '${customer?['first_name'] ?? ''} ${customer?['last_name'] ?? ''}';

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        decoration: BoxDecoration(
                          color: context.kCard,
                          borderRadius: BorderRadius.circular(kRadiusMd),
                          border: Border.all(color: context.kBorder),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(
                              child: Text(
                                readableId.isNotEmpty ? '${'booking'.tr} #$readableId' : 'recheck_task'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: context.kForeground,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(context, status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: _statusColor(context, status).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _statusLabel(status),
                                style: robotoBold.copyWith(
                                  fontSize: 10,
                                  color: _statusColor(context, status),
                                ),
                              ),
                            ),
                          ]),

                          if (customerName.trim().isNotEmpty) ...[
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(
                              customerName.trim(),
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: context.kForeground,
                              ),
                            ),
                          ],

                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: context.kMutedForeground,
                              ),
                            ),
                          ],

                          if (reason.isNotEmpty) ...[
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(
                              '${'customer_issue'.tr}: $reason',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: context.kMutedForeground,
                              ),
                            ),
                          ],

                          if (dueAt.isNotEmpty && status != 'completed' && status != 'expired') ...[
                            const SizedBox(height: 4),
                            Text(
                              '${'recheck_due_by'.tr}: $dueAt',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: context.kPrimary,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                          ],

                          if (note.isNotEmpty) ...[
                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                            Text(
                              '${'serviceman_note'.tr}: $note',
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: context.kForeground,
                              ),
                            ),
                          ],

                          if (status == 'requested' || status == 'in_progress') ...[
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Row(children: [
                              if (status == 'requested')
                                Expanded(
                                  child: CustomButton(
                                    btnTxt: 'start_recheck'.tr,
                                    isLoading: controller.isUpdating,
                                    onPressed: () => controller.updateRecheckStatus(id, 'in_progress'),
                                  ),
                                ),
                              if (status == 'requested') const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(
                                child: CustomButton(
                                  btnTxt: 'mark_recheck_done'.tr,
                                  isLoading: controller.isUpdating,
                                  onPressed: () => _showCompleteDialog(context, controller, id),
                                ),
                              ),
                            ]),
                          ],
                        ]),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, RecheckController controller, String recheckId) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: context.kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault)),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              'complete_recheck'.tr,
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: context.kForeground),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'complete_recheck_message'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: context.kMutedForeground,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'inspection_report'.tr,
                hintStyle: robotoRegular.copyWith(color: context.kMutedForeground),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(children: [
              Expanded(
                child: CustomButton(
                  btnTxt: 'cancel'.tr,
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: CustomButton(
                  btnTxt: 'submit'.tr,
                  isLoading: controller.isUpdating,
                  onPressed: () async {
                    Get.back();
                    await controller.updateRecheckStatus(
                      recheckId,
                      'completed',
                      note: noteController.text.trim(),
                    );
                  },
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'expired':
        return context.kDestructive;
      case 'in_progress':
        return Colors.orange;
      default:
        return context.kPrimary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'completed'.tr;
      case 'expired':
        return 'expired'.tr;
      case 'in_progress':
        return 'in_progress'.tr;
      default:
        return 'requested'.tr;
    }
  }
}
