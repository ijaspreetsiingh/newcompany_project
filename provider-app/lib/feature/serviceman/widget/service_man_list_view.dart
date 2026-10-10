import 'package:jassdbx_provider/feature/serviceman/widget/serviceman_card_view.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class ServiceManListview extends StatelessWidget {
  final List<int> visibleIndexes;
  const ServiceManListview({super.key, this.visibleIndexes = const []});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicemanSetupController>(
      builder: (servicemanController) {

        final List<ServicemanModel> servicemen = servicemanController.servicemanList ?? [];
        final List<int> indexes = visibleIndexes.isNotEmpty ? visibleIndexes : List.generate(servicemen.length, (i) => i);

        return ListView.builder(
          controller: servicemanController.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          itemCount: indexes.length,
          itemBuilder: (context, i) {
            final int index = indexes[i];
            if(index < 0 || index >= servicemen.length) return const SizedBox();
            return ServicemanCardView(serviceman: servicemen[index], index: index);
          },
        );
      },
    );
  }
}
