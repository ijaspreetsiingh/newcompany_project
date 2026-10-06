import 'package:demandium_provider/util/core_export.dart';

class ConversationListTabview extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const ConversationListTabview({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkPills(
      items: const ["All", "Customers", "Servicemen"],
      value: value,
      onChanged: onChanged,
    );
  }
}
