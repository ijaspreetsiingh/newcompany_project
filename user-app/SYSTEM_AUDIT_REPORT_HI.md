# Booking system code audit (11 Oct 2026)

## Scope

Code flow ko source files se trace kiya: Flutter customer app (`userapk`), provider app, serviceman app, aur Laravel backend ke API routes/controllers/admin booking controller. Yeh focused booking/API audit hai; har UI file, har Laravel module, payment gateway credentials, running production database, aur deployment config ka exhaustive security/operational audit nahi hai.

> **Write access:** User ki request par approval lekar backend aur Service man app ke zaroori files bhi update kiye gaye.

## System ka high-level flow

```text
Admin panel configures zones, categories/services, providers, payment and booking rules
        ↓
Customer app loads catalog/config → cart → address/schedule → payment → booking request
        ↓
Backend validates, prices, stores booking/payment/status history, selects/assigns provider
        ↓
Provider app accepts/ignores request and assigns a serviceman
        ↓
Serviceman app travels, marks reached, starts service, adds evidence/extra work, completes job
        ↓
Backend updates customer tracking, notifications, payment/commission/ledger and admin reports
```

The backend is the system of record: the mobile apps call `/api/v1/...`, while the Laravel booking module owns state transitions and persistence. Provider and serviceman are separate roles and API prefixes.

## Customer / User app kaise kaam karta hai

1. `lib/util/app_constants.dart` mein base URL aur API paths configured hain. App boot ke baad setup/config, groups (categories), tasks (services), banners/campaigns aur location/zone related endpoints se home screen build hoti hai.
2. Customer service choose karke basket/cart mein add karta hai. Cart, selected provider (where applicable), variation/quantity aur notes checkout flow tak jaate hain.
3. Checkout address + zone, service location, schedule, service type/repeat schedule, coupon/wallet/partial payment aur payment method collect karta hai. `CheckoutRepo.placeBookingRequest()` JSON payload ko `POST /api/v1/client/order/submission/transmit` par bhejta hai. Guest ID aur optional guest-created account info bhi bheje ja sakte hain.
4. Success response se readable booking number aur internal booking ID liya jata hai. App confirmation/offline-payment screen dikhata hai; booking list/details/track/status endpoints se aage updates milte hain.
5. Customer booking cancel, recurring occurrence cancel, review, recheck, payment-mode/offline payment aur serviceman tracking jaise actions kar sakta hai.

Relevant code: [app_constants.dart](C:/Users/ijasp/OneDrive/Desktop/userapk/lib/util/app_constants.dart), [checkout_repo.dart](C:/Users/ijasp/OneDrive/Desktop/userapk/lib/feature/checkout/repo/checkout_repo.dart), [checkout_controller.dart](C:/Users/ijasp/OneDrive/Desktop/userapk/lib/feature/checkout/controller/checkout_controller.dart).

## Provider app kaise kaam karta hai

Provider app `https://newcompanyproject-production.up.railway.app` ko use karta hai, v3.8 mark kiya gaya hai. Partner authentication ke baad dashboard/earnings, services, servicemen, bookings, calendar, settings aur reports dikhata hai.

Booking ka key flow:

- booking list/details: `POST /api/v1/partner/order`, `GET /api/v1/partner/order/{id}`
- accept/ignore: `PUT .../submission-approve/{booking_id}`, `POST .../submission-dismiss/{booking_id}`
- provider status: `PUT .../state-change/{booking_id}`
- serviceman assign/suggestions: `PUT .../assign-technician/{booking_id}`, `GET .../assign-suggestions/{booking_id}`, `PUT .../assign-servicemen/{booking_id}`
- provider auto-assignment controls: `auto-assign-switch`, `auto-assign-delay-window`, `auto-assign-state/{booking_id}`
- schedule, repeat booking, invoice, service changes, payment and recheck summary are additional flows.

Provider source mein ye paths `lib/util/app_constants.dart` mein hain; backend routes `Modules/BookingModule/Routes/api/v1/api.php` mein hain.

## Serviceman app kaise kaam karta hai

Serviceman app v3.6 mark hai aur wahi Railway backend URL use karta hai. Technician role login karke assigned work list/details, work status, notifications, location/work status aur booking conversation use karta hai.

- list/detail: `GET /api/v1/technician/order/index`, `GET /api/v1/technician/order/info/{id}`
- reached/start OTP: `PUT /api/v1/technician/order/reached/{booking_id}`; phir `PUT /api/v1/technician/order/state-change/{booking_id}` se ongoing
- completion: status update ke saath `booking_otp` (jab booking OTP enabled ho), optional completion photos
- extra service: `POST`/`DELETE /api/v1/technician/order/extra-service/...`
- payment receive: `PUT /api/v1/technician/order/pay-state-change/{booking_id}`

App controller/repository files `lib/feature/booking_details/...` hain. Backend status endpoint user ko role/assigned serviceman ke against check karta hai, offline payment approval ko enforce karta hai, OTP verify karta hai, aur status history transaction mein likhta hai.

## Admin panel se management

Admin Laravel web panel/API ke through booking lifecycle ko monitor/update karta hai. Admin booking list filters (status, provider, service, zone/time), details, schedule/status/service address/provider/serviceman assignment, payment aur invoice/report operations control karta hai. Booking module ke web routes mein admin booking screens/actions hain; `Modules/BookingModule/Http/Controllers/Web/Admin/BookingController.php` list/detail/status screen logic handle karta hai. Admin API routes `POST /api/v1/admin/booking`, `GET /api/v1/admin/booking/{id}`, `PUT /api/v1/admin/booking/status-update/{booking_id}` aur schedule update expose karte hain.

Business configuration (service catalog, zones, taxes/fees/commission, payment gateways, booking OTP/evidence, provider assignment) admin setup screens/config modules se aata hai. Customer app catalog/setup API response consume karta hai; apps mein kuch operational settings server-driven hain.

## Example: ek normal booking

Misaal ke taur par customer ghar ki cleaning select kare, apna address/zone aur kal 10 baje ka slot de, aur online payment choose kare:

1. Customer app catalog se service/rate/variation laata hai; basket aur checkout total banata hai.
2. App `submission/transmit` ko `payment_method`, `zone_id`, `service_schedule`, `service_address`, `service_type`, `booking_type`, `dates`, `service_location` aur payment flags bhejta hai.
3. Backend booking + details/history persist karta hai, payment flow initiate/record karta hai, eligible provider ko request deta hai (auto-assign configuration ke mutabiq).
4. Provider request accept karta hai aur technician assign karta hai. Provider ko response na mile/ignore ho to system ki configured assignment logic doosre eligible option ko de sakti hai.
5. Serviceman customer location par pahunch kar Reached mark karta hai; customer ko service-start OTP milta hai. Correct OTP se ongoing, kaam complete karne ke baad completion OTP/evidence se completed.
6. Backend customer booking status/notifications, provider earnings/commission aur transaction history update karta hai; admin panel se poora record inspect ho sakta hai.

Actual rates, assignment eligibility, OTP flags aur payment options admin config/zone/service/provider state par depend karte hain.

## Pehle mila bug (ab fix ho chuka hai)

**P1 — Start-service OTP request ka field name backend se match nahi karta.** Serviceman app repository status multipart map mein `startOtp` naam ka key bhejti hai, jabki Laravel serviceman controller `$request['start_otp']` padhta hai. Isse Reached ke baad valid 6-digit OTP submit karne par server ko expected value nahi milti aur “ongoing” update OTP error de sakta hai.

- App: `Service man app/lib/feature/booking_details/repository/booking_details_repo.dart`, `changeBookingStatus()` multipart data.
- Backend: `backend/Modules/BookingModule/Http/Controllers/Api/V1/Serviceman/BookingController.php`, ongoing status par `start_otp` validation.
- Sahi client mapping: `'start_otp': startOtp` (Dart null-aware map entry ke saath: `if (startOtp != null) 'start_otp': startOtp`).

**Fix apply kar diya:** repository payload mein `startOtp` ko conditional `start_otp` key se map kiya. Backend change ki zarurat nahi dikh rahi; technician app ko rebuild/release karna hoga.

## Compatibility / verification notes

- User app v3.7, provider v3.8, serviceman v3.6 labels hain; teeno same base URL use karte hain. Ye apne aap mein bug nahi, par naye booking fields/endpoints ke liye app/backend release compatibility verify karni chahiye.
- Route declarations mein customer/provider/technician booking endpoints aur mobile constants ka major path alignment source level par dikh raha hai.
- Is audit mein production API call, credentials, payments, database migration apply, ya Flutter build/test execute nahi hua. `flutter analyze --no-pub` run karne ki koshish timeout/no-output par interrupt karni padi; isliye analyzer pass ka claim nahi hai.
- Customer app mein Dart behavior change nahi kiya gaya; uska existing extra-item bill UI API data milne ke baad kaam karta hai. Backend aur Service man code fixes runtime booking se abhi verify nahi hue.

## Pehle recommended OTP fix (ab apply ho chuka hai)

Service-man repository map ko backend contract ke saath align karein:

```dart
final body = <String, String>{
  'booking_status': status,
  '_method': 'put',
  'booking_otp': otp,
  if (startOtp != null) 'start_otp': startOtp,
};
```

Phir Android technician app se test booking mein `Reached → correct start OTP → ongoing` flow verify karein. Saath mein wrong OTP reject, completed OTP, normal booking (start OTP absent) aur recurring booking status flows verify karein.

## Update: requested flow changes

User ke latest workflow ke mutabiq approval ke baad ye fixes bhi apply hue:

- Recheck button/request window 15 se **7 din** ki.
- Customer booking details aur guest tracking API mein `extraServices` relation load hota hai; customer app ka existing bill UI name, quantity aur price per unit/line amount dikhata hai.
- Extra service add/remove par backend customer aur provider owner ko booking push notification bhejta hai. Message mein item name, quantity aur total line amount hai.
- Nearest serviceman sort aur 300m Reached/OTP gate ab maximum **5-minute-old GPS** use karte hain.
- Serviceman start OTP ka request field `start_otp` se map hota hai.

Modified backend PHP files `php -l` se syntax-checked hain. Flutter app build aur production booking/push test abhi nahi chalaye gaye.
