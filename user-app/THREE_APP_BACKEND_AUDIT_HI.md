# Teen apps + backend: updated review

**Review date:** 11 October 2026  
**Scope:** Customer, provider, service-man apps and Laravel booking APIs  
**Nateeja:** Repeat-booking OTP, provider-side OTP bypass, customer repeat-booking access, provider extra-service response, provider catalogue selection aur pehle mile customer-app bugs par fixes kiye. Local Docker API/PHP smoke checks pass hue. Production host ne `reached` path par `GET/HEAD` allow dikhaya, jabki app/backend `PUT` use karte hain—backend deploy/route cache update abhi zaroori hai. Full authenticated booking lifecycle ya Play Store build certify nahi hua.

## Booking flow simple terms mein

1. Admin zone/category set karke provider assign karta hai. Customer app current location/zone ke mutabik services aur providers dikhati hai. Is admin-to-customer flow ka live data test nahi hua.
2. Booking backend tak jaati hai; provider accept/assign karta hai. Backend nearest service-man ko recent location ke basis par dispatch karta hai. Purani location (5 min se zyada) ko fresh nahi maana jata.
3. Service-man “Reached” karta hai. Regular aur repeat booking dono ke liye backend 300m ke andar, recent GPS location par start OTP banata hai. Customer booking details mein OTP dekh sakta hai.
4. Service-man sahi OTP ke baad hi booking `ongoing` kar sakta hai. Provider app ke regular/repeat status APIs ab seedha `ongoing` karke OTP bypass nahi kar sakte.
5. Service-man custom/external extra work aur price add karta hai; backend total badalta hai aur customer/provider notification bhejne ki koshish karta hai. Customer/provider booking detail mein extra-service lines dikhni chahiye.
6. Customer service complete hone ke baad 7 din ke andar recheck/unsatisfied request kar sakta hai. API/UI code maujood hai; notification delivery aur actual recheck task ka live test nahi hua.

## Kya fix hua

- **Customer app address popup:** logged-in profile ka naam/phone prefill; selected location se missing street/postcode lene ki koshish; address edit form ka naam/phone mapping fix.
- **Customer app Google login:** empty token ko valid login samajhne aur successful token ke baad galat account-link sheet dikhane ka risk fix.
- **Radius lookup:** failed provider API call par search radius ko galat increment karne ke bajay restore kiya.
- **Backend OTP:** regular/repeat booking `accepted` honi chahiye; GPS par “Reached” ke baad hi OTP generate/verify hota hai; OTP generation `random_int()` se hoti hai.
- **Repeat booking OTP:** service-man app ab repeat detail se correct repeat status endpoint use karti hai; backend repeat instance ke liye location, OTP aur customer notification handle karta hai. Customer repeat detail mein OTP fields parse/render hote hain.
- **Provider OTP bypass:** provider ke regular aur repeat status endpoint ab service start directly set nahi karte.
- **Repeat booking privacy:** customer repeat details API parent booking ke customer owner ko verify karti hai aur missing booking par null crash se bachti hai.
- **Provider extra service detail:** API response ab `extraServices` relation load karti hai, jise provider app pehle se render kar sakti thi.
- **Extra-work popup:** provider ki assigned category ke active catalogue services aur zone price/variant select karne ka option, external service, aur manual custom work option. Service API ab current serviceman ke provider assignment/zone ke mutabik filter karti hai. Labels English, Hindi, Bengali aur Arabic mein add kiye.
- **Reached 405 diagnosis:** source code mein app aur backend dono `PUT` use karte hain; production host ke `OPTIONS` response mein sirf `GET, HEAD` mila. Backend route ko deploy karke route cache clear karna hai. GET fallback nahi lagaya, kyunki GET se booking/OTP mutate karna unsafe hai.
- **API log security:** customer, provider aur service-man API clients se bearer-token, request-body aur saved-address logging hatai; JSON `Accept` header add kiya. Service-man full response-body logging bhi band hai. Isse pasted debug log jaisi credential leak dobara app logs mein nahi honi chahiye. Jo token log mein aa chuka hai use compromised samjho: service-man ko logout karke token revoke/expire karwao aur dobara sign-in karo.
- **Android setup:** teenon apps ke release variant debug signing ki jagah release keystore config use karte hain. Customer aur service-man build number `0` se `1` hua.

## Test result

- Docker MySQL par migration `2026_10_11_000001_add_start_otp_and_extra_services_to_bookings_table` **applied** mili.
- Local `GET /api/v1/client/setup` → **200**.
- Local customer booking detail, provider status aur service-man reached API ke bina login → **401** (routes/auth middleware check; booking transition test nahi).
- Teen modified backend controllers par Docker PHP lint → **pass, syntax errors nahi**.
- Service-man ke edited Dart widgets `dart format` se parse/format hue; translation JSON chaaron locales mein valid hai.
- Docker route list `PUT api/v1/technician/order/reached/{booking_id}` register karti hai. Local `PUT` unauthenticated request → **401** (expected). Production route method mismatch → deployment blocker.
- Docker container mein PHPUnit missing hai; `php artisan test` command available nahi, isliye automated API integration tests execute nahi hue.
- Flutter/Dart analyzer changed files par 60+ seconds tak bina output hang hua; stop karna pada. Build/analyzer pass ka evidence nahi mila.
- Setup/auth smoke test local Docker (`localhost:8000`) par hua. Production host OPTIONS check ne `GET/HEAD` methods return kiye; production booking/payment data mutate nahi kiya.

## Abhi release ke pehle jo chahiye

1. **Private signing key:** release config set hai, lekin teenon app folders mein `key.properties`/keystore nahi mila. Original Play signing keystore aur private properties configure karne ke baad hi Play-signed APK/AAB banega. Humne koi nayi private key/password generate ya expose nahi ki.
2. **Build/test toolchain:** Flutter analyze hang hua, aur service-man APK artifact 25 Sep ka hai. Current source se fresh APK/AAB build + install verification abhi nahi hui.
3. **Backend deploy for 405:** updated Laravel backend ko production host par deploy karke route cache refresh karna baaki hai; uske baad app mein `I have reached` dobara test karein.
4. **Authenticated end-to-end API test:** valid staging customer/provider/service-man logins ke saath booking → assign → 300m reached → OTP → extra charge → completion → 7-day recheck ko run karna baaki hai. Public setup/auth smoke test hi hua.
5. **Device/integration checks:** push notification delivery, payment gateway, Google OAuth fingerprints/config, GPS background permissions, offline/retry aur real-device UI validate nahi hue.

**Seedha jawab:** Extra-work popup ab provider service/external/manual options deta hai aur local code mein 405 route `PUT` hai. Lekin production host par backend update pending hai; jab tak route deploy/cache clear nahi hota, live app ka 405 nahi rukega. Keystore aur authenticated staging end-to-end test bhi baaki hain.

## Performance audit (11 October 2026)

### Source se mile concrete slowdown points

- **Provider app startup duplicate requests:** `provider/Provider app/lib/feature/nav/bottom_nav_screen.dart` mein `loadData()` `getProviderInfo()` pehle fire karta hai aur phir usi ko await karke dobara chalata hai. Provider dashboard screen bhi `getProviderInfo()` fire karti hai. Isliye ek hi profile ke liye startup par 2–3 requests lag sakti hain. `getEarningData()` startup aur dashboard screen dono taraf se call hota hai.
- **Service-man app unnecessary chart calls:** `Service man app/lib/feature/dashboard/controller/dashboard_controller.dart` ka `onInit()` turant monthly aur yearly chart API dono hit karta hai. Pehli screen par chahiye nahi to inhe chart section khulne par lazy-load kiya ja sakta hai. Service-man booking list API initial limit 7 leti hai, jabki alag refresh/popup paths 10 bhi lete hain; request dedupe/status reuse check karna chahiye.
- **Customer app home fan-out:** `userapk/lib/feature/home/home_screen.dart` mein visible home ke liye pehle 5 data fetch ek saath wait hote hain; phir 8 aur background fetch shuru hote hain. Home ka pehla render `popularServiceList` aane par depend hai. Existing local cache helpful hai, par cold install/empty cache par screen ko usable skeleton/quick actions ke saath pehle dikhana chahiye.
- **HTTP connection reuse nahi:** teenon API clients normal GET/POST/PUT/DELETE ke liye top-level `http.get/post/put/delete` use karte hain. Har call par temporary client banne ki wajah se repeat TLS/TCP connection reuse ka fayda nahi milta. Long-lived `http.Client`/connection reuse se repeated API calls faster ho sakte hain. Multipart calls ko bhi same client se bhejna hoga.
- **Cache refresh render ko delay kar sakta hai:** customer `DataSyncRepo._fetchFromClient()` successful response ke baad local Drift DB mein cache write ko `await` karta hai. Data callback cache write complete hone ke baad hi aata hai; cache write ko background mein karne se network result jaldi UI tak aa sakta hai.
- **Provider booking list API ka backend load:** `Provider BookingController::index()` booking rows ke saath status-wise, pending aur accepted counts alag calculate karta hai, phir list paginate karta hai. Ye har tab refresh par multiple count queries bana sakta hai. Dashboard API `ProviderController::dashboard()` 8 requested sections ko ek response mein assemble karta hai; ye one HTTP call hai par server-side section queries ko profile karna hoga. Existing performance-index migration booking/relations ke kai indexes add karti hai, lekin booking-repeat/search/location ke actual query plans phir bhi `EXPLAIN ANALYZE` se verify karne chahiye; blind extra indexes se writes slow ho sakte hain.

### Docker/backend se mila evidence

- Local Docker ke app, DB, nginx, Redis, queue worker aur scheduler containers running mile. `jdds-app` sample par takriban 19% CPU tha; DB takriban 174 MiB RAM use kar raha tha. Is one-time sample se overload conclude nahi hota.
- Read-only local `/api/v1/client/setup` request 10-second timeout tak complete nahi hui; container ke andar se same request probe bhi waqt mein finish nahi hui aur rokni padi. Isliye local end-to-end API p50/p95 baseline establish nahi hua.
- PHP-FPM ke recent logs mein kai web requests 3.0–4.0 seconds ke baad slow-request mark hue. Slow trace `ptrace` permission ke karan record nahi hui. Ye high-priority profiling signal hai, lekin exact controller/query cause log se akela prove nahi hota.
- Docker stack Windows OneDrive folder bind-mount karta hai. Vendor/views named volumes par hain, par source tree Windows filesystem se mount hai. Local development mein ye file I/O ko slow kar sakta hai; production mein image ke andar immutable source deploy hona chahiye.
- `php-opcache.ini` OPcache JIT disable karta hai, par `Dockerfile` JIT enable karta hai. Effective loaded PHP config `php --ri opcache` se confirm karni chahiye. Laravel mein JIT ko speed fix maan kar enable na karein; JIT conflicting config ko ek jagah se manage karein. FPM slowlog 3 seconds par hai, par ptrace blocked hai.
- `docker-compose.yml` comment ke mutabik `mysql-optimization.cnf` bind-mount Windows permissions ki wajah se MySQL ignore karta hai. Isliye file mein likhi DB tuning ko active samajhna galat hoga jab tak container mein active config verify na ho.

### Sabse pehle kya badalna chahiye

1. **Duplicate calls band + in-flight dedupe:** provider `loadData()` ka double profile call aur dashboard se repeat fetch hatao; har controller/API query ke liye same request already running ho to usi Future ko reuse karo. Service-man charts ko tab khulne par load karo. Isse bina backend risk ke startup ke requests ghatengi.
2. **Click par foran UI feedback:** button press ke turant baad optimistic state/loading indicator dikhao; network ko background mein chalne do, failure par state rollback/message. Server ka response click ke 1 ms mein aana possible nahi hai. UI ka acknowledgement 1 frame (~16 ms at 60 Hz) mein aa sakta hai; remote request ko network/server time lagega.
3. **HTTP keep-alive:** app-wide reusable HTTP client lagao aur GetX service dispose par close karo; TLS/connection timings measure karo.
4. **Home/dashboard ko staged banao:** first paint ke liye sirf zone, categories aur popular/nearby services; below-the-fold campaigns, all-services, recommendations, chat counts background/lazy. Cached stale data pehle dikhao, fresh response baad mein. Search type karte waqt debounce + cancellation.
5. **Backend ko trace karke optimize:** staging mein per-route p50/p95, SQL query count/time, response bytes aur external service duration log karo (token/PII nahi). Laravel Telescope/Debugbar production mein nahi; sampling APM ya staging query log use karo. Dashboard/booking list par `EXPLAIN ANALYZE`; phir exact query-shape ke composite indexes, eager-loading aur selected columns.
6. **Slow side effects queue karo:** push, email, SMS, webhook/geocoding ko booking transaction ke synchronous response se bahar queued job mein rakho; user ko action accepted ka response foran do. Queue worker aur retries/failed jobs monitor karo.
7. **Production runtime:** app code aur DB same region; production Docker image immutable (Windows bind mount nahi), `APP_DEBUG=false`, `php artisan optimize`/config-route-view cache, OPcache timestamps production ke liye off. FPM workers, DB max connections aur Redis memory real RAM/request load ke hisaab se size hon—compose ke fixed `15` workers/`1000` MySQL connections ko bina load test ke copy na karein.
8. **Media:** CDN/object storage, resized WebP/AVIF thumbnails, content-hash assets ke long cache headers, list views par lazy image decode.
9. **Targets define karo:** same-region simple authenticated API p50 ~150–250 ms, p95 <500 ms starting target; complex dashboard ko alag budget do. Real device par tap-to-feedback <100 ms rakho. Ye targets measurement goals hain, guarantee nahi.

### Is pass mein apply kiye gaye safe changes

- Teenon apps ke API clients ab ek reusable `http.Client` use karte hain; JSON aur multipart requests is client se jaati hain aur service close hone par client band hota hai. Repeated calls mein TCP/TLS connection reuse ka mauka milta hai.
- Customer home ka recommended-search API call first batch ke blocking wait se second/background batch mein move kiya.
- Customer app mein fresh API response ab UI callback se pehle local cache DB write ka wait nahi karta; cache write background mein best-effort hoti hai.
- Provider startup mein `getProviderInfo()` ka duplicate call hataaya; duplicate earning-data startup fetch hataaya (dashboard screen us data ko load karti hai).
- Service-man app ne initial open par eager yearly-chart request hata di; yearly chart toggle par load hota hai. Bottom navigation se repeat monthly/yearly chart requests bhi hataayi.

**Validation status:** static source scan mein teeno API clients ke GET/POST/PUT/DELETE aur multipart calls reusable client se jaate dikhte hain; duplicate call sites verify kiye. Dart SDK `--version` chala, lekin formatter subcommand environment ke `Platform.resolvedExecutable` null error se fail hua; Flutter analyze/build bhi is pass mein complete nahi hua. Local setup API 10-second probe aur container probe complete nahi huye. Isliye changes ko build/device performance test pass kehna sahi nahi hoga.

**Conclusion:** App side par unnecessary request aur connection overhead kam karne ke changes kiye. Backend ko andaze se nahi badla: PHP-FPM 3–4 sec slow marks ka exact controller/query trace abhi available nahi, aur local Docker MySQL `performance_schema=OFF` hai. Laravel route/query profiling next zaroori step hai. Production p50/p95 ya exact speed improvement abhi verify nahi hui; 1 ms remote API realistic target nahi hai.
