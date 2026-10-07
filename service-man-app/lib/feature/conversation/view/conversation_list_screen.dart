import 'package:demandium_serviceman/utils/core_export.dart';

class ConversationListScreen extends StatelessWidget {
  final String? fromNotification;
  const ConversationListScreen({super.key, this.fromNotification});

  @override
  Widget build(BuildContext context) {
    return InboxScreen(fromNotification: fromNotification);
  }
}
