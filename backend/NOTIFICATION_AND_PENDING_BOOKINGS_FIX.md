# 🔧 2 CRITICAL FIXES NEEDED - DETAILED ACTION PLAN

## Issue 1: Notification Overlay Popup (Countdown)

### Current Problem
- Notification popup sirf app foreground mein aata hai
- Background mein ya app close hone par nahi dikh raha
- Chahiye: Phone ke top par **system-level popup** jaise incoming call notification

### Solution Approach

#### Step 1: Enable Foreground Notifications
File: `Provider app/lib/main.dart` or Firebase setup file

Add this handler:
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show foreground notification
  showNotificationPopup(message);
});
```

#### Step 2: Create System-Level Overlay Notification
Create new file: `lib/helper/overlay_notification_helper.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class OverlayNotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> showAssignmentNotification({
    required String title,
    required String body,
    required int countdownSeconds,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'service_assignment_channel',
      'Service Assignment Notifications',
      channelDescription: 'Notifications for new service assignments',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,  // ← Shows like incoming call
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      styleInformation: DefaultStyleInformation(true, true),
    );

    const DarwinNotificationDetails iOSDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}
```

#### Step 3: Show Countdown Popup with System Notification
File: `Provider app/lib/helper/notification_helper.dart` (update)

```dart
Future<void> handleServiceAssignment(RemoteMessage message) async {
  // Show system-level notification
  await OverlayNotificationHelper.showAssignmentNotification(
    title: 'New Service Assignment!',
    body: 'Accept before timer ends',
    countdownSeconds: 60,
  );

  // Also show in-app popup with countdown
  Get.dialog(
    ServiceAssignmentCountdownDialog(
      bookingData: message.data,
      countdownSeconds: 60,
    ),
    barrierDismissible: false,
  );
}
```

### Android Manifest Changes
File: `Provider app/android/app/src/main/AndroidManifest.xml`

Add:
```xml
<!-- For full-screen intent (incoming call-like notifications) -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

---

## Issue 2: Zone Pending Bookings

### Current Problem
- "Working" tab pe sirf accepted bookings dikhai dete hain
- Declined/not accepted bookings missing
- Chahiye: Sab bookings jo nearby provider ko decline ho gaye

### Solution Approach

#### Step 1: Find Booking Query File
Search for: `lib/feature/booking/repo/booking_repo.dart` or similar

Current query likely:
```dart
// WRONG: Only shows accepted bookings
bookings = await db.getBookings(status: 'accepted');
```

Should be:
```dart
// CORRECT: Show assigned but not accepted yet (pending provider response)
bookings = await db.getBookings(
  status: ['assigned', 'pending'],
  zoneId: currentZone
);
```

#### Step 2: Update Booking Repository
File: `Provider app/lib/feature/booking/repo/booking_repo.dart`

Add new method:
```dart
Future<List<BookingModel>> getZonePendingBookings({
  required String zoneId,
  required String providerId,
}) async {
  try {
    final response = await apiClient.getData(
      '/api/v1/partner/order?zone_id=$zoneId&status=assigned&provider_id=$providerId'
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.body['content'] ?? [];
      return data.map((e) => BookingModel.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print('Error fetching pending bookings: $e');
    return [];
  }
}
```

#### Step 3: Update Booking Controller
File: `Provider app/lib/feature/booking/controller/booking_controller.dart`

```dart
Future<void> getZonePendingBookings() async {
  try {
    _isLoading = true;
    update();

    String zoneId = Get.find<LocationController>().getUserLocation()?.zoneId ?? '';
    String providerId = Get.find<AuthController>().getUserId();

    _pendingBookings = await bookingRepo.getZonePendingBookings(
      zoneId: zoneId,
      providerId: providerId,
    );

    _isLoading = false;
    update();
  } catch (e) {
    print('Error: $e');
    _isLoading = false;
    update();
  }
}
```

#### Step 4: Update UI - Working Tab
File: `Provider app/lib/feature/booking/view/booking_list_screen.dart`

```dart
// In Working tab
if (tabIndex == 1) {  // Working tab
  return GetBuilder<BookingController>(builder: (controller) {
    return ListView.builder(
      itemCount: controller.pendingBookings.length,
      itemBuilder: (context, index) {
        final booking = controller.pendingBookings[index];
        
        return BookingCard(
          booking: booking,
          isDeclined: booking.status == 'pending_acceptance',
          showAcceptButton: true,
          showDeclineButton: false,  // Already declined by you
        );
      },
    );
  });
}
```

---

## Files to Create/Modify

### NEW FILES:
```
1. lib/helper/overlay_notification_helper.dart
```

### MODIFY FILES:
```
1. lib/main.dart - Add Firebase foreground handler
2. lib/helper/notification_helper.dart - Update notification handler
3. lib/feature/booking/repo/booking_repo.dart - Add zone pending query
4. lib/feature/booking/controller/booking_controller.dart - Add method
5. lib/feature/booking/view/booking_list_screen.dart - Update UI
6. android/app/src/main/AndroidManifest.xml - Add permissions
```

---

## API Changes Needed (Backend)

### Endpoint: Get Zone Pending Bookings
```
GET /api/v1/partner/order?zone_id=ZONE_ID&status=assigned&provider_id=PROVIDER_ID

Response:
{
  "content": [
    {
      "id": "booking_id",
      "status": "assigned",
      "customer": {...},
      "service": {...},
      "booking_time": "2026-10-12 14:30:00",
      "declined_by": ["provider_1", "provider_2"],  // ← Who declined
      "nearest_provider_count": 5
    }
  ]
}
```

---

## Testing Checklist

### Notification Popup Test:
- [ ] Close app completely
- [ ] Send new booking notification from backend
- [ ] Check: Does notification appear like incoming call?
- [ ] Check: Can see countdown timer on popup?
- [ ] Check: Works even if app is closed?
- [ ] Check: Works even if phone is doing other things?
- [ ] Click notification → Opens app with countdown dialog

### Zone Pending Bookings Test:
- [ ] Login as provider
- [ ] Go to Working tab
- [ ] Should see: All bookings assigned in my zone
- [ ] Should see: Bookings declined by nearest providers
- [ ] Should see: Countdown showing time left to accept
- [ ] Click Accept → Confirms assignment
- [ ] Click Decline → Moves to next provider

---

## Implementation Order

1. **First**: Create `overlay_notification_helper.dart`
2. **Second**: Update Firebase handlers in `main.dart`
3. **Third**: Update booking repository queries
4. **Fourth**: Update UI to show pending bookings
5. **Fifth**: Add Android permissions
6. **Sixth**: Test thoroughly

---

## Status: READY FOR IMPLEMENTATION

All code snippets provided above. Ready to start fixing!

**Next Step**: Confirm you want to proceed with these fixes, or ask clarifying questions.
