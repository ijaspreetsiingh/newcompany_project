# ❌ BEKAR ITEMS - DELETE LIST

## 1️⃣ CUSTOMIZED REQUESTS (Bidding System)
```
Route: admin/booking/post
Menu: "Customized Requests"
Lines in _aside.blade.php: 107-112

DELETE: Yes (not needed)
Reason: You don't have custom request feature
Affected:
  - BidModule/Post model
  - BookingModule post routes
  - Views/Controllers for posts
```

## 2️⃣ VERIFY REQUESTS (Booking Verification)
```
Route: admin/booking/list/verification
Menu: "verify_requests"
Lines in _aside.blade.php: 116-121

DELETE: Maybe (optional)
Reason: Only if you don't need manual verification
Keep if: High-value bookings need verification
```

## 3️⃣ OFFLINE PAYMENT LIST
```
Route: admin/booking/list/offline-payment
Menu: "Offline Payment List"
Lines in _aside.blade.php: 127-131

DELETE: Optional
Reason: Only needed if you accept offline payments
Keep if: You want offline payment tracking
```

## 4️⃣ DISCOUNTS
```
Routes: 
  - admin/discount/list
  - admin/discount/create
Menu: "Discounts" (2 items)
Lines in _aside.blade.php: 169-195

DELETE: Yes (optional feature)
Reason: Not core to booking system
Keep if: You want discount management
Module: PromotionManagement
```

## 5️⃣ COUPONS
```
Routes:
  - admin/coupon/list
  - admin/coupon/create
Menu: "Coupons" (2 items)
Lines in _aside.blade.php: 196-222

DELETE: Yes (optional feature)
Reason: Not core to booking system
Keep if: You want coupon/promo codes
Module: PromotionManagement
```

## 6️⃣ WALLET BONUS
```
Routes:
  - admin/bonus/list
  - admin/bonus/create
Menu: "Wallet Bonus" (2 items)
Lines in _aside.blade.php: 223-249

DELETE: Yes (optional feature)
Reason: Not core to booking system
Keep if: You want loyalty bonus system
Module: BusinessSettingsModule
```

## 7️⃣ CAMPAIGNS
```
Routes:
  - admin/campaign/list
  - admin/campaign/create
Menu: "Campaigns" (2 items)
Lines in _aside.blade.php: 250-276

DELETE: Yes (marketing feature)
Reason: Not core to booking system
Keep if: You want marketing campaigns
Module: PromotionManagement
```

## 8️⃣ ADVERTISEMENTS
```
Routes:
  - admin/advertisements/ads-list
  - admin/advertisements/new-ads-request
Menu: "Advertisements" (2 items)
Lines in _aside.blade.php: 277-303

DELETE: Yes (marketing feature)
Reason: Not core to booking system
Keep if: You want ads marketplace
Module: Custom Module
```

## 9️⃣ PROMOTIONAL BANNERS
```
Route: admin/banner/create
Menu: "promotional_banners" (1 item)
Lines in _aside.blade.php: 304-311

DELETE: Yes (marketing feature)
Reason: Not core to booking system
Keep if: You want banner management
```

## 🔟 EMPLOYEE MANAGEMENT
```
Routes:
  - admin/role/list
  - admin/employee/list
  - admin/employee/create
Menu: "Employee Role Setup", "employee_list", "add_new_employee" (3+ items)
Lines in _aside.blade.php: 527-586

DELETE: Yes (not applicable)
Reason: You have admin users, not employees
Keep if: You want employee management
```

## 1️⃣1️⃣ NEWSLETTER SUBSCRIBERS
```
Route: admin/customer/newsletter/list
Menu: "Subscribed Newsletter" (1 item)
Lines in _aside.blade.php: 510-516

DELETE: Optional
Reason: Newsletter feature
Keep if: You want email newsletters
```

## 1️⃣2️⃣ CUSTOMER LOYALTY POINTS
```
Route: admin/customer/loyalty-point/report
Menu: "Loyalty Points Transactions" (1 item)
Lines in _aside.blade.php: 501-509

DELETE: Optional
Reason: Not core to booking system
Keep if: You want loyalty points system
```

## 1️⃣3️⃣ ANALYTICS (Advanced)
```
Routes:
  - admin/analytics/search/keyword
  - admin/analytics/search/customer
Menu: "Analytics" (2 items)
Lines in _aside.blade.php: 656-680

DELETE: Optional
Reason: Advanced feature, not critical
Keep if: You want search analytics
```

## 1️⃣4️⃣ SUBSCRIPTIONS (Premium Plans)
```
Routes:
  - admin/subscription/package/list
  - admin/subscription/subscriber/list
  - admin/subscription/settings
Menu: "Subscription Management" (3 items)
Lines in _aside.blade.php: 727-762

DELETE: Yes (not relevant)
Reason: You don't have subscription model
Keep if: You want premium subscriptions
Module: BusinessSettingsModule
```

## 1️⃣5️⃣ LANDING PAGE ITEMS
```
Routes: admin/business-settings/get-landing-information
Menu Items: "Button & links", "Speciality", "Testimonial", "Features", "Images", "Background", "Social_Media", "Meta", "Web_App", "Web_App_Image"
Lines in _aside.blade.php: 763-815

DELETE: Yes (website features)
Reason: You're building app, not website
Keep if: You have website with landing page
```

## 1️⃣6️⃣ PAGE & MEDIA
```
Routes:
  - admin/business-page-setup/list
  - admin/social-media/index
  - admin/business-settings/get-landing-information
Menu: "Page & Media" (3+ items)
Lines in _aside.blade.php: 719-750

DELETE: Yes (website features)
Reason: Website page management
Keep if: You have website
```

## 1️⃣7️⃣ WITHDRAW METHOD SETUP
```
Route: admin/withdraw/method/create
Menu: "Withdraw method setup" (part of Withdraws section)

DELETE: Optional
Reason: Only if multiple withdrawal methods
Keep if: Multiple payment methods (bank, UPI, etc.)
```

---

## SUMMARY: WHAT TO DELETE

### DEFINITELY DELETE (10 items):
1. ❌ Customized Requests (Bidding)
2. ❌ Discounts
3. ❌ Coupons
4. ❌ Wallet Bonus
5. ❌ Campaigns
6. ❌ Advertisements
7. ❌ Promotional Banners
8. ❌ Employee Management (Role + Employees)
9. ❌ Subscriptions
10. ❌ Landing Page/Website features

### OPTIONALLY DELETE (5 items):
1. ⚠️ Verify Requests (if not needed)
2. ⚠️ Offline Payment List (if cash not needed)
3. ⚠️ Newsletter (if not using emails)
4. ⚠️ Loyalty Points (if not using)
5. ⚠️ Advanced Analytics (if not needed)

---

## NEXT STEPS

Tu batao:

1. **Delete everything from "DEFINITELY DELETE"?** (10 items)
2. **Keep/Delete from "OPTIONALLY DELETE"?** (which ones?)

Once confirm, I'll delete from:
- **_aside.blade.php** (sidebar UI)
- **Routes** (remove routes)
- **Controllers** (remove unused)
