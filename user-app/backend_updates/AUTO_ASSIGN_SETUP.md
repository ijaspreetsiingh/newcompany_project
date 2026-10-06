# Auto-Assign System — Complete Implementation

Ye complete auto-assign system 4 projects me implement kiya gaya hai. Neeche har change, setup steps aur testing flow diya gaya hai.

---

## 📁 Projects & Locations

| Project | Location |
|---|---|
| **Backend** (Laravel 12) | `booking apk/Demandium v3.7/codecanyon-40224772.../backend` |
| **Provider App** (Flutter) | `Desktop/provider/Provider app` |
| **Service Man App** (Flutter) | `booking apk/Demandium v3.7/.../Service man app` |
| **User App** (Flutter) | current repo (`jdds`) |

---

## ⚙️ FLOW KAISE KAAM KARTA HAI

```
USER BOOKING PLACE
        ↓
┌─────────────────────────────┐
│ Kisi provider ka Toggle ON? │
└─────────────────────────────┘
   YES              NO
    ↓                ↓
SABHI BOOKINGS   NEAREST PROVIDER
US PROVIDER KO   (Haversine distance sort)
    ↓                ↓
TIMER (provider  TIMER (2 min default)
ne set kiya)         ↓
    ↓           ┌─ ACCEPTED? ─┐
┌─ ACCEPTED? ─┐  YES         NO
  YES    NO     ↓           ↓
   ↓      ↓   SERVICEMAN  NEXT PROVIDER
SERVICEMAN    assign      (30s timer,
   ↓          (30s timer)  repeat)
ACCEPTED?         ↓        ↓
  ↓             DONE     NEXT SERVICEMAN
DONE / NEXT
```

- Provider **reject** kare ya **timer expire** ho → booking agle nearest provider ko chali jaati hai (ignored/expired providers exclude hote hain)
- Koi provider available nahi → booking `pending` rehti hai (admin/provider manual assign kar sakta hai)
- Serviceman reject kare → agle serviceman ko assignment jaati hai

---

## 🗄️ PHASE 1: BACKEND

### 1.1 NAYI FILES
| File | Kya hai |
|---|---|
| `Modules/ProviderManagement/Database/Migrations/2026_09_22_000001_add_auto_assign_to_providers_table.php` | `providers` me `auto_assign_mode` (bool, default 0) + `auto_assign_wait_time` (int, default 120s) |
| `Modules/ProviderManagement/Database/Migrations/2026_09_22_000002_create_provider_booking_timers_table.php` | `provider_booking_timers` table (booking_id, provider_id, status: pending/accepted/ignored/expired/auto_approved, expires_at) |
| `Modules/BookingModule/Database/Migrations/2026_09_22_000003_add_auto_assign_to_bookings_table.php` | `bookings` me `auto_assigned`, `auto_assign_expires_at`, `assigned_provider_id` |
| `Modules/BookingModule/Database/Migrations/2026_09_22_000004_add_auto_assign_to_booking_repeats_table.php` | `booking_repeats` me same 3 columns |
| `Modules/BookingModule/Database/Migrations/2026_09_22_000005_add_serviceman_auto_assign_to_bookings_table.php` | `bookings` + `booking_repeats` me `serviceman_assign_expires_at` |
| `Modules/ProviderManagement/Entities/ProviderBookingTimer.php` | Naya entity (booking() + provider() relations) |
| `app/Jobs/AutoApproveBookingJob.php` | Scheduled job — expired timers process karta hai |

### 1.2 MODIFIED FILES
| File | Change |
|---|---|
| `Modules/ProviderManagement/Entities/Provider.php` | casts + fillable me auto-assign fields, `autoAssignTimers()` relation |
| `Modules/BookingModule/Entities/Booking.php` + `BookingRepeat.php` | casts + fillable me auto-assign datetime fields |
| `app/Lib/Helpers.php` | Naye helpers: `calculateDistance`, `findNearestProviders`, `assignBookingToProvider`, `moveBookingToNextProvider`, `autoAssignBooking`, `processExpiredAutoAssign`, `processExpiredServicemanAssign`, `assignBookingToServiceman`, `findNextServiceman` + imports |
| `Modules/BookingModule/Http/Traits/BookingTrait.php` | `placeBookingRequest()` me `$booking->save()` ke baad `autoAssignBooking($booking)` hook |
| `Modules/BookingModule/Http/Controllers/Api/V1/Provider/BookingController.php` | `toggleAutoAssign()`, `updateAutoAssignWaitTime()`, `getAutoAssignStatus()` + `requestAccept`/`requestIgnore` me timer handling |
| `Modules/BookingModule/Http/Controllers/Api/V1/Serviceman/BookingController.php` | `acceptBooking()`, `rejectBooking()` |
| `Modules/BookingModule/Routes/api/v1/api.php` | Naye routes |
| `routes/console.php` | `Schedule::job(new AutoApproveBookingJob)->everyThirtySeconds()->withoutOverlapping()` |

### 1.3 NAYE API ENDPOINTS
```
PUT  /api/v1/provider/booking/auto-assign-toggle           → toggle ON/OFF
PUT  /api/v1/provider/booking/auto-assign-wait-time        → {wait_time: seconds (30-3600)}
GET  /api/v1/provider/booking/auto-assign-status/{id}      → timer status (popup polling ke liye)

PUT  /api/v1/serviceman/booking/accept/{booking_id}        → serviceman accept
PUT  /api/v1/serviceman/booking/reject/{booking_id}        → serviceman reject (next SM ko jayegi)
```

### 1.4 SETUP STEPS
```bash
cd "backend"
php artisan migrate          # naye columns + table banega
php artisan schedule:work    # ya crontab: * * * * * php artisan schedule:run
                             # (schedule:work local testing ke liye)
```

> ⚠️ **Note:** Providers ke paas `coordinates` (latitude/longitude) set hone chahiye tabhi wo nearest-provider flow me aayenge. Profile update se coordinates set hote hain.

---

## 🏪 PHASE 2: PROVIDER APP

| File | Change |
|---|---|
| `lib/util/app_constants.dart` | `autoAssignToggleUrl`, `autoAssignWaitTimeUrl`, `autoAssignStatusUrl` |
| `lib/feature/profile/model/provider_model.dart` | `ProviderInfo` me `autoAssignMode`, `autoAssignWaitTime` |
| `lib/feature/profile/repository/user_repo.dart` | `toggleAutoAssign()`, `updateAutoAssignWaitTime()` |
| `lib/feature/profile/controller/user_controller.dart` | `initAutoAssignSettings()`, `toggleAutoAssignMode()`, `updateAutoAssignWaitTime()`, `autoAssignWaitTimeLocal` setter |
| `lib/feature/settings/business/widget/booking_setup_tab_item_widget.dart` | **Naya `_AutoAssignCardWidget`** — Switch + wait-time slider (30s–600s) |
| `lib/feature/booking_details/repo/booking_details_repo.dart` | `toggleAutoAssign()`, `updateAutoAssignWaitTime()`, `getAutoAssignStatus()` |
| `lib/feature/booking_requests/controller/booking_timer_controller.dart` | **NAYA** — countdown + accept/reject + auto-close |
| `lib/feature/booking_requests/view/incoming_booking_popup.dart` | **NAYA** — full-screen popup (timer, service info, Reject/Accept) |
| `lib/helper/route_helper.dart` | `incomingBookingPopup` route |
| `lib/helper/notification_helper.dart` | `type == 'new_booking_request'` → popup open |
| `lib/util/core_export.dart` | popup + timer controller exports |
| `assets/language/en.json` | naye translation keys |

**Toggle kahan milega:** Business Settings → Booking Setup tab me "Auto-Assign Mode" card.

---

## 🔧 PHASE 3: SERVICE MAN APP

| File | Change |
|---|---|
| `lib/common/enums/enums.dart` | `BooingListStatus` me `pending` add (ab: pending, accepted, ongoing) |
| `lib/utils/app_constants.dart` | `acceptBookingUrl`, `rejectBookingUrl` |
| `lib/feature/booking_request/repository/booking_request_repo.dart` | `acceptBooking()`, `rejectBooking()` |
| `lib/feature/booking_request/controller/booking_timer_controller.dart` | **NAYA** — 30s countdown + accept/reject |
| `lib/feature/booking_request/view/incoming_booking_popup.dart` | **NAYA** — full-screen popup |
| `lib/helper/route_helper.dart` | `incomingBookingPopup` route |
| `lib/helper/notification_helper.dart` | `new_booking_request` → pending list refresh + popup open |
| `lib/utils/core_export.dart` | exports |
| `assets/language/en.json` | translation keys |

---

## 📱 PHASE 4: USER APP (current repo)

| File | Change |
|---|---|
| `lib/feature/booking/controller/booking_status_polling_controller.dart` | **NAYA** — har 3s status poll, provider accept hone par callback |
| `lib/feature/booking/widget/booking_finding_provider_widget.dart` | **NAYA** — "Finding provider..." + "Provider Found!" card |
| `lib/feature/checkout/view/order_successful_screen.dart` | `bookingId` param + polling widget integrate |
| `lib/feature/checkout/controller/checkout_controller.dart` | booking place hone par bookingId ke saath success screen |
| `lib/helper/route_helper.dart` | `getOrderSuccessRoute(status, {bookingId})` |
| `lib/util/core_export.dart` | exports |
| `assets/language/en.json` | `finding_provider`, `provider_found`, `view_booking`, etc. |

**Flow:** Booking place → success screen pe "Finding provider..." spinner → provider accept (3s polling detect) → "Provider Found!" card (photo, name, rating) → View Booking.

---

## 🧪 TESTING CHECKLIST

1. `php artisan migrate` + `php artisan schedule:work` start karo
2. **Toggle ON test:** Provider app → Business Settings → Auto-Assign ON → koi booking place karo → usi provider ko popup aani chahiye
3. **Nearest test:** Toggle OFF, 2 providers different locations pe → booking → nearest ko popup
4. **Timer expire test:** Popup aane do, accept mat karo → timer khatam → next provider ko popup
5. **Reject test:** Reject dabao → next provider ko jaye
6. **Serviceman flow:** Provider accept → serviceman app me popup (30s) → accept → booking `accepted`
7. **User app:** Booking place → "Finding provider..." → accept ke baad "Provider Found!"
8. **No provider case:** Sab ignore karo → booking pending rehti hai, customer ko "Still finding provider" notification

---

## ✅ VERIFICATION STATUS

- Saari PHP files `php -l` verified — **no syntax errors**
- Provider app: `flutter analyze` clean (koi error/warning nahi)
- Service Man app: `flutter analyze` clean
- User app: `flutter analyze` clean — **No issues found**
- Teeno `en.json` JSON-valid
