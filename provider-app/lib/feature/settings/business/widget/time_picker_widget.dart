import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class TimePickerWidget extends StatefulWidget {
  final String title;
  final String? time;
  final Function(String?) onTimeChanged;
  const TimePickerWidget({super.key, required this.title, required this.time, required this.onTimeChanged});

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}


class _TimePickerWidgetState extends State<TimePickerWidget> {
  String? _myTime;

  @override
  void initState() {
    super.initState();
    _myTime = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {

        Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
        TimeOfDay? time = await showCustomTimePicker();
        Get.find<UserProfileController>().trialWidgetShow(route: "");
        if(time != null) {
          setState(() {
            _myTime = DateConverter.convert24HourTimeTo12HourTime(DateTime(DateTime.now().year, 1, 1, time.hour, time.minute));

          });
          widget.onTimeChanged(_myTime);
        }
      },
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: InkColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: InkColors.border),
        ),
        child: Row(children: [

          Text(
            _myTime != null ? _myTime!: 'pick_time'.tr,
            style: robotoMedium.copyWith(fontSize: 13, color: InkColors.foreground),
            maxLines: 1,
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall,),

           Icon(Icons.access_time_rounded, size: 16, color: InkColors.mutedForeground),

        ]),
      ),
    );
  }
}
