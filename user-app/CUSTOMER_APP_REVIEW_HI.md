# Customer app review (11 October 2026)

## Seedha nateeja

Customer app ka cart/address, social login aur radius-search code review kiya. Bataye gaye address popup aur Google sign-in ke bugs fix kiye. App ko abhi Play Store ke liye production-ready confirm nahi kar sakta: Android release build debug key se sign hota hai, app version `1.0.0+0` hai, aur Google sign-in ke liye fallback client ID placeholder hai. Admin panel mein Web Client ID set hai ya nahi, code se confirm nahi hota. Live API aur Google sign-in test bhi is workspace se nahi hua.

## Kaun se bugs fix hue

1. **Cart checkout house-details popup:** contact name/phone saved address mein na ho to logged-in profile se prefill hota hai. Street/postal code selected address ke coordinates se reverse-geocode hote hain, lekin existing saved values ko overwrite nahi karte. Geocode 8 seconds mein na aaye to user manually continue kar sakta hai. Confirm ki hui house details saved address ID hone par server par update hoti hain; is wajah se usi address par har booking mein dobara popup nahi aana chahiye.
2. **Address edit form:** naam field galti se phone number se bhar rahi thi. Ab saved contact name dikhata hai, aur missing ho to profile name; phone missing ho to profile phone.
3. **Google social login:** token aur temporary token pehle empty strings se initialize hote the, isliye API se token na milne par bhi app galat login branch mein ja sakti thi. Saath hi token aur user record ek response mein aane par existing-account sheet aur login route dono trigger hote the. Ab missing/empty token ko absent maana jata hai, valid token direct login karta hai, aur account-link confirmation sirf token ke bina conflict response par khulti hai. Duplicate token save bhi hata diya.
4. **Radius search:** provider lookup fail/timeout par radius agle level par chala jata tha, jabki availability maloom hi nahi hui thi. Ab API failure par pichla radius restore hota hai; successful “no provider” result par hi attempt count aage badhta hai.
5. **Existing-account sheet:** app logo/profile photo ki jagah simple account icon dikhaya, aur missing email par crash se bachne ke liye null-safe handling ki.

## Icon aur radius popup

Map marker asset `assets/images/marker.png` ko khol kar dekha: file render hoti hai aur marker corrupt nahi dikhta. Agar corrupt icon kisi aur screen ka hai to us screen ka naam/screenshot chahiye. Radius popup ka radius display aur manual-location/change-location/cancel actions source mein mile; provider lookup API response ke bina popup ka real-world behavior verify nahi hua.

## Play Store par upload se pehle zaroori

- [ ] `android/app/build.gradle.kts` mein `release` signing abhi debug signing config use karta hai. Apna release keystore configure karein; Play Store upload ke liye debug-signed release sahi nahi hai.
- [ ] `pubspec.yaml` version abhi `1.0.0+0` hai. Release ke liye market version aur har upload par unique build number set karein.
- [ ] `lib/util/app_constants.dart` mein Google server client ID `YOUR_CLIENT_ID_HERE` hai. App admin setup se client ID leti hai, isliye production server/admin configuration aur Android OAuth SHA fingerprints ke saath real device par Google sign-in test karein.
- [ ] Production API endpoint `https://newcompanyproject-production.up.railway.app` configured hai. Login, cart, address geocoding/save, payment configuration aur booking APIs ko release backend par smoke-test karein.
- [ ] Android release build aur Play Console pre-launch report run karein; is machine par verification complete nahi hui.

## Verification ki seema

Changed Dart files par `dart format`/`flutter analyze` chalane ki koshish ki, lekin local Dart CLI `Platform.resolvedExecutable` par `Null is not a subtype of String` error deta hai. Flutter command bhi is environment mein output diye bina hang hota raha, isliye analyzer ya release build pass hone ka daawa nahi kar raha. Live server, real Google OAuth, push notification delivery aur payment gateway ko production credentials/device ke bina verify nahi kiya.
