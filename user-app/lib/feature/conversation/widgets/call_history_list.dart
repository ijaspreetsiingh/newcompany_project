import 'package:get/get.dart';
import 'package:jdds/feature/conversation/widgets/conversation_search_shimmer.dart';
import 'package:jdds/util/core_export.dart';

class CallHistoryList extends StatelessWidget {
  const CallHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallController>(
      builder: (callController) {
        if (callController.historyList.isEmpty && callController.historyLoading) {
          return const ConversationSearchShimmer();
        }

        if (callController.historyList.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
            children: [
              const Icon(Icons.call_end_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'no_calls_yet'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                'call_history_empty_desc'.tr,
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () => callController.loadHistory(reload: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: callController.historyList.length,
            itemBuilder: (context, index) {
              final call = callController.historyList[index];
              final other = call.otherUser ?? <String, dynamic>{};
              final bool missed = call.status == 'missed';
              final bool outgoing = call.direction == 'out';
              final IconData dirIcon = missed
                  ? Icons.call_missed_rounded
                  : outgoing
                      ? Icons.call_made_rounded
                      : Icons.call_received_rounded;
              final Color dirColor = missed
                  ? Colors.redAccent
                  : outgoing
                      ? Colors.green
                      : Theme.of(context).primaryColor;
              final String name = (other['name'] ?? '').toString();
              final String image = (other['image'] ?? '').toString();

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                          child: image.isEmpty
                              ? const Icon(Icons.person, size: 24, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Icon(dirIcon, size: 15, color: dirColor),
                        ),
                      ],
                    ),
                    title: Text(
                      name.isNotEmpty ? name : 'call'.tr,
                      style: robotoMedium.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        call.callType == 'video' ? 'video'.tr : 'voice'.tr,
                        callController.callStatusText(call.status),
                        if ((call.duration ?? 0) > 0) callController.formatDuration(call.duration!),
                      ].join(' · '),
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: missed ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.call_rounded, color: Theme.of(context).primaryColor),
                      onPressed: (other['id'] ?? '').toString().isEmpty
                          ? null
                          : () => callController.startCall(
                                calleeId: other['id'].toString(),
                                callType: 'voice',
                                name: name,
                                image: image,
                                phone: (other['phone'] ?? '').toString(),
                              ),
                    ),
                  ),
                  if (index < callController.historyList.length - 1)
                    const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
