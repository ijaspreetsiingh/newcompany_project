# 🔄 DEMANDIUM COMPLETE END-TO-END FLOW

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND (Laravel)                            │
│  - Admin Panel (Web)                                            │
│  - APIs for all 3 Apps                                          │
│  - Database (Categories, Providers, Users, etc.)               │
└─────────────────────────────────────────────────────────────────┘
          ↑                    ↑                    ↑
          │                    │                    │
   ┌──────┴──────┐      ┌──────┴──────┐      ┌──────┴──────┐
   │  ADMIN      │      │  PROVIDER   │      │  USER       │
   │  (Web)      │      │  (Flutter)  │      │  (Flutter)  │
   │             │      │             │      │             │
   │ Config +    │      │ Accept/      │      │ Browse +    │
   │ Manage      │      │ Reject +     │      │ Book        │
   │             │      │ Assign       │      │             │
   └─────────────┘      └─────────────┘      └─────────────┘
                              │                      │
                              └──────────┬───────────┘
                                         │
                            ┌────────────┴────────────┐
                            │   SERVICEMAN           │
                            │   (Flutter)            │
                            │                        │
                            │ Accept + Complete      │
                            │ Service                │
                            └────────────────────────┘
```

---

## COMPLETE FLOW: Admin → Provider → Serviceman → User

### **PHASE 1: ADMIN SETUP (Backend Web Panel)**

#### Step 1.1: Create Main Categories
**URL:** `http://127.0.0.1:8000/admin/category/create`

Admin:
1. Fill: Category name (e.g., "Plumbing")
2. Select: Zones (e.g., Delhi, Mumbai)
3. Upload: Category image
4. Click: Submit

**Database Result:**
- Saves: `categories` table (parent_id = 0)
- Links: `category_zone` table

**API Used:** `POST /api/v1/admin/category/store`

---

#### Step 1.2: Create Sub-Categories
**URL:** `http://127.0.0.1:8000/admin/sub-category/create`

Admin:
1. Select: Parent Category (e.g., "Plumbing")
2. Fill: Sub-category name (e.g., "Pipe Repair")
3. Fill: Description
4. Upload: Sub-category image
5. Click: Submit

**Database Result:**
- Saves: `categories` table (parent_id = main_category_id)

**API Used:** `POST /api/v1/admin/sub-category/store`

---

#### Step 1.3: Create Provider & Assign Zone
**URL:** `http://127.0.0.1:8000/admin/provider/create`

Admin:
1. Fill: Company name, email, phone
2. Fill: Contact person details
3. Select: **ONE ZONE** (e.g., Delhi)
4. Upload: Logo, identity documents
5. Click: Create

**Database Result:**
- `providers` table: zone_id = Delhi
- Provider created & assigned to Delhi

---

#### Step 1.4: Assign Categories to Provider (Zone-Aware)
**URL:** `http://127.0.0.1:8000/admin/provider/edit/prvd-xxx-xxx-xxx`

Admin:
1. Go: Edit Provider (Delhi zone provider)
2. **Switch 1:** Enable "Complete main categories"
   - Tick: "Plumbing" → Provider gets Plumbing + all its sub-categories
3. **Switch 2:** Enable "Specific sub-categories"
   - Select Main: Plumbing
   - Tick: "Pipe Repair", "Drain Cleaning"
4. Click: Update

**Database Result:**
```sql
-- Subscribed Services Table
INSERT INTO subscribed_services:
- provider_id: rahul-uuid
- zone_id: delhi-uuid         ← AUTO from provider.zone_id
- category_id: plumbing-uuid
- sub_category_id: pipe-repair-uuid
- assign_type: 'specific'
- is_subscribed: 1

-- UNIQUE CONSTRAINT: (zone_id, sub_category_id)
-- Meaning: Only Rahul can have Pipe Repair in Delhi
```

**Unique Constraint Check:**
- ❌ If another provider in Delhi tries "Pipe Repair" → Error shown
- ✅ Different provider in Mumbai can have "Pipe Repair"

---

### **PHASE 2: PROVIDER APP (Flutter)**

#### Step 2.1: Provider Login
**Screen:** Splash → Auth → Login

Provider (Rahul):
1. Open App
2. Enter: Email + Password
3. Click: Login

**Backend API:** `POST /api/v1/auth/login`

**Response Contains:**
- Provider ID
- Token
- Zone
- Assigned categories

---

#### Step 2.2: Provider Dashboard
**Screen:** `feature/dashboard`

Provider sees:
1. **Pending Requests Card**
   - Shows: New booking requests coming in
   - Count badge

2. **Active Bookings Card**
   - Shows: Bookings in progress

3. **Quick Stats**
   - Total bookings today
   - Earnings today
   - Rating

**API Used:** `GET /api/v1/provider/dashboard`

---

#### Step 2.3: Provider Receives Booking Request
**Screen:** `feature/booking_requests`

**How it triggers:**
1. User (Aanya) creates booking for "Pipe Repair" in Delhi zone
2. System checks: Delhi + Pipe Repair → finds Rahul (provider)
3. **Push Notification** sent to Rahul
   - Title: "New Booking Request!"
   - Message: "Pipe Repair booking in Indiranagar"

**Backend Logic:** `app/Lib/Helpers.php` → `autoAssignBooking()` or `findNearestProviders()`

---

#### Step 2.4: Provider Reviews Booking Details
**Screen:** `feature/booking_requests/view`

Provider (Rahul) taps notification:
1. Opens: Booking request card
2. Sees:
   - Customer name: Aanya Sharma
   - Service: Full home cleaning
   - Address: 12, 3rd Cross, Indiranagar (Delhi)
   - Date: Tomorrow, 10:00 AM
   - Budget: ₹2,548
3. Buttons:
   - ✅ Accept
   - ❌ Reject

**Database:** `bookings` table (status = pending)

---

#### Step 2.5: Provider Accepts Booking
**Action:** Tap "Accept"

**Backend API:** `POST /api/v1/provider/booking/{id}/accept`

**What happens:**
1. Booking status: pending → accepted
2. Serviceman assignment screen shows (if auto_assign_mode = 1)
3. Provider picks serviceman: "Raj" (from provider's team)
4. Notification sent to Raj: "New job assigned"
5. Notification sent to Customer: "Professional accepted your booking"

**Database:**
- `bookings` table: status = accepted, serviceman_id = raj-uuid
- `bookings` table: provider_id = rahul-uuid

**Key Role:** Provider acts as intermediary between customer & serviceman

---

#### Step 2.6: Provider Tracks Assigned Serviceman
**Screen:** `feature/booking_details`

Provider (Rahul) can:
1. View: Serviceman location (Raj's live location)
2. View: Booking timeline
3. Call/Chat: With customer
4. Call/Chat: With serviceman

---

### **PHASE 3: SERVICEMAN APP (Flutter)**

#### Step 3.1: Serviceman Login
**Screen:** Splash → Auth → Login

Serviceman (Raj):
1. Open: Serviceman App
2. Enter: Email + Password
3. Click: Login

**Backend API:** `POST /api/v1/auth/login`

**Response:**
- Serviceman ID
- Token
- Assigned provider

---

#### Step 3.2: Serviceman Dashboard
**Screen:** `feature/dashboard`

Serviceman sees:
1. **Assigned Bookings** (from provider)
2. **In Progress** bookings
3. Quick stats

---

#### Step 3.3: Serviceman Receives Job
**Trigger:** Provider assigns serviceman to booking

**Screen:** `feature/booking_request`

Serviceman (Raj) sees:
1. New job notification
2. Customer details
3. Service details
4. Location
5. Buttons:
   - ✅ Accept
   - ❌ Reject

---

#### Step 3.4: Serviceman Accepts Job
**Action:** Tap "Accept"

**Backend API:** `POST /api/v1/serviceman/booking/{id}/accept`

**What happens:**
1. Booking status: accepted → in_progress
2. Customer notified: "Serviceman starting service"
3. Timer starts: "Service duration ~4-5 hours"
4. Serviceman's location shared with customer

---

#### Step 3.5: Serviceman Completes Service
**On-Site:**
1. Serviceman arrives
2. Customer verifies: Work quality
3. Payment made: If "pay after service"
4. Serviceman marks: "Complete"

**Screen:** `feature/booking_details`

Serviceman:
1. Clicks: "Complete service"
2. Takes: Photos of work (optional)
3. Adds: Notes (optional)
4. Clicks: Submit

**Backend API:** `POST /api/v1/serviceman/booking/{id}/complete`

**Database:**
- `bookings` table: status = completed
- `ratings` table: Ready for customer to rate

---

### **PHASE 4: USER APP (Flutter)**

#### Step 4.1: User Browse & Search
**Screen:** `feature/home` → `feature/search`

User (Aanya):
1. Open: App
2. See: Featured services
3. Tap: Category (e.g., "Plumbing")
4. See: All plumbing services
5. Tap: "Pipe Repair"

**API Used:** 
- `GET /api/v1/client/group/` - Categories
- `GET /api/v1/client/sub-categories` - Sub-categories
- `GET /api/v1/client/services` - Services list

---

#### Step 4.2: User Views Service Details
**Screen:** `feature/service/service_detail`

User sees:
1. Service image
2. Price: Starting ₹2,499
3. Description
4. Ratings: 4.89 stars
5. Warranty info

---

#### Step 4.3: User Customizes & Adds to Cart
**Screen:** `feature/service/service_customize_sheet` (Bottom sheet)

User:
1. Sees: Service options
2. Selects: Quantity (e.g., 2 hours)
3. Clicks: "Add to cart · ₹2,499"

**Cart Data:**
```
Cart Item:
- Service: Pipe Repair
- Quantity: 1
- Price: ₹2,499
- Status: In cart
```

**API Used:** Local storage (cart stored locally)

---

#### Step 4.4: User Checkouts
**Screen:** `feature/checkout/checkout_screen_final`

User (Aanya):
1. Views: Cart items
2. Selects: **Address** (e.g., "Home · Indiranagar")
3. Selects: **Date** (Tomorrow)
4. Selects: **Time** (10:00 AM)
5. Price Summary:
   - Item: ₹2,499
   - Taxes: ₹249
   - Total: ₹2,748
6. Clicks: "Continue to payment"

---

#### Step 4.5: User Selects Payment Method
**Screen:** `feature/checkout/payment_screen_final`

User:
1. Sees: 3 payment options
   - 💵 Cash after service
   - 📱 UPI/Digital wallet
   - 💳 Credit/Debit card
2. Selects: "Cash after service" (default)
3. Clicks: "Place booking"

**Backend API:** `POST /api/v1/client/order/submission/transmit`

---

#### Step 4.6: Booking Confirmation
**Screen:** `feature/checkout/confirmation_and_tracking_final`

User sees:
1. Success checkmark ✓
2. **Booking ID:** #NE384921
3. Booking details:
   - Date: Tomorrow, 10:00 AM
   - Address: 12, 3rd Cross, Indiranagar
   - Service: Pipe Repair
   - Amount: ₹2,748
4. Buttons:
   - "Track booking"
   - "Back to home"

**Database Result:**
```sql
INSERT INTO bookings:
- id: NE384921
- user_id: aanya-uuid
- provider_id: rahul-uuid (AUTO-ASSIGNED from zone+category)
- category_id: plumbing-uuid
- sub_category_id: pipe-repair-uuid
- zone_id: delhi-uuid
- service_id: service-uuid
- booking_status: pending
- address: "12, 3rd Cross, Indiranagar"
- scheduled_date: tomorrow
- scheduled_time: 10:00 AM
- total_amount: 2748
- payment_method: cash
```

**Notification Chain:**
1. ✅ User receives: "Booking confirmed"
2. ✅ Provider (Rahul) receives: "New booking request"
3. ✅ If provider accepts → Serviceman (Raj) receives: "New job"

---

#### Step 4.7: Real-Time Tracking
**Screen:** `feature/booking/booking_tracking`

User (Aanya) taps: "Track booking"

Timeline updates:
```
✓ Booking confirmed (Today, 11:42 AM)
✓ Professional assigned (Today, 12:10 PM) - Rahul Kumar assigned
◦ Service in progress (Tomorrow, 10:00 AM)
◦ Completed (Pending)
```

Professional Card:
- Avatar: "RK" (Rahul Kumar)
- Rating: ⭐ 4.92 · 1.2k jobs
- Buttons: 📞 Call, 💬 Chat

---

#### Step 4.8: Service Completes
**Timeline Updates to:**
```
✓ Booking confirmed
✓ Professional assigned
✓ Service in progress
✓ Completed (Today, 2:45 PM)
```

User sees: "Thank you! Rate this service"

---

#### Step 4.9: User Rates Service
**Screen:** `feature/review` (Auto-opens after completion)

User:
1. Gives: Star rating (e.g., 5 ⭐)
2. Writes: Review comment
3. Clicks: "Submit"

**Backend API:** `POST /api/v1/client/review`

**Database:**
- `ratings` table: Created
- Provider rating: Updated (+1 to 4.92)

---

### **PHASE 5: PROVIDER RECEIVES EARNINGS**

After completion + payment:
1. Serviceman payment settled
2. Provider's wallet: Credited
3. Admin's commission: Deducted
4. Transaction record: Created

**Provider sees:** In `feature/transaction`
- Earnings: ₹2,123 (after commission)
- Date: Today
- Service: Pipe Repair

---

## Complete Data Flow Diagram

```
ADMIN PORTAL
├─ Create Category
│  └─ DB: categories (name, image, parent_id=0)
├─ Create Sub-Category
│  └─ DB: categories (parent_id=main_id)
├─ Create Provider
│  └─ DB: providers (zone_id=Delhi)
└─ Assign Categories to Provider
   └─ DB: subscribed_services (provider_id, zone_id, sub_category_id)
      └─ UNIQUE: (zone_id, sub_category_id) - Only ONE provider per zone per category

USER BOOKING FLOW:
├─ Browse services
│  └─ API: GET /api/v1/client/services
├─ Add to cart
│  └─ Local storage
├─ Checkout
│  └─ Select: Address, Date, Time
├─ Payment
│  └─ Select: Payment method
└─ Place Booking
   └─ API: POST /api/v1/client/order/submission/transmit
   └─ System finds: Provider (from zone + category)
   └─ DB: bookings (status=pending, provider_id=auto-assigned)
   └─ NOTIFICATION: Provider receives booking request

PROVIDER FLOW:
├─ Receives notification (booking request)
├─ Reviews booking details
├─ Clicks "Accept"
│  └─ DB: bookings (status=accepted)
│  └─ Provider selects serviceman
├─ Serviceman assigned
│  └─ NOTIFICATION: Serviceman receives job

SERVICEMAN FLOW:
├─ Receives notification (job assigned)
├─ Clicks "Accept"
│  └─ DB: bookings (status=in_progress)
│  └─ Location shared
├─ Service completion
│  └─ DB: bookings (status=completed)
│  └─ NOTIFICATION: User - service completed

USER RATING FLOW:
├─ Receives completion notification
├─ Opens rating screen
├─ Submits: Stars + Comment
│  └─ DB: ratings (user_id, provider_id, rating)
│  └─ Provider rating updated

PAYMENT & EARNINGS:
├─ Payment processing (if UPI/card)
├─ Commission deduction (admin%)
├─ Provider wallet credited
│  └─ DB: account (provider_id, balance)
└─ Provider sees earnings in transaction history
```

---

## Key Entities & Their Relationships

```sql
categories:
- id (UUID)
- name
- parent_id (0 = main, parent_id = main_id for sub)
- image
- is_active

zones:
- id (UUID)
- name

providers:
- id (UUID)
- zone_id (ONE ZONE PER PROVIDER)
- company_name
- is_active

subscribed_services (ZONE-AWARE):
- id (auto)
- provider_id (UUID)
- zone_id (UUID) ← FROM provider.zone_id
- category_id (UUID)
- sub_category_id (UUID)
- is_subscribed
- UNIQUE KEY: (zone_id, sub_category_id) ← ONE provider per zone per category

bookings:
- id (UUID)
- user_id (UUID)
- provider_id (UUID) ← AUTO from zone+category lookup
- category_id (UUID)
- sub_category_id (UUID)
- zone_id (UUID)
- serviceman_id (UUID) ← Assigned by provider
- booking_status (pending, accepted, in_progress, completed, cancelled)
- total_amount
- payment_method (cash, upi, card)

serviceman:
- id (UUID)
- provider_id (UUID) ← Works under provider

users:
- id (UUID)
- user_type (customer, provider-admin, serviceman)
- email, phone, etc.

ratings:
- id (auto)
- user_id (UUID)
- provider_id (UUID)
- rating (1-5)
- comment

transactions:
- id (auto)
- provider_id (UUID)
- booking_id (UUID)
- amount
- type (credit/debit)
```

---

## Zone-Based Automatic Provider Assignment Logic

```php
// When user places booking (user app)
// Location: User's address → Extract zone

$booking = Booking::create([
  'zone_id' => $userZone, // Auto-extracted from address
  'category_id' => $selectedCategory,
  'sub_category_id' => $selectedSubCategory,
]);

// Find provider assigned to this zone + category
$provider = Provider::query()
  ->where('zone_id', $userZone)
  ->whereHas('subscribed_services', function ($q) use ($userZone, $selectedSubCategory) {
    $q->where('zone_id', $userZone)
      ->where('sub_category_id', $selectedSubCategory)
      ->where('is_subscribed', 1);
  })
  ->first();

if ($provider) {
  $booking->provider_id = $provider->id; // AUTO-ASSIGN
  $booking->save();
  sendNotification($provider, "New booking request");
}
```

---

## 🎯 Summary

| Role | Action | System Response |
|------|--------|-----------------|
| **Admin** | Create category + assign to zones | DB: categories + category_zone |
| **Admin** | Create sub-category | DB: categories (parent_id set) |
| **Admin** | Create provider (zone: Delhi) | DB: providers (zone_id = Delhi) |
| **Admin** | Assign sub-cat to provider | DB: subscribed_services (zone_id + sub_cat_id UNIQUE) |
| **User** | Browse & book service | Auto-finds provider from zone |
| **Provider** | Accept booking | Assigns serviceman + notifies |
| **Serviceman** | Accept job | Status: in_progress |
| **User** | Service completes | Can rate provider |
| **Provider** | Receives earnings | Wallet credited |

---

## 🚀 Key Features

✅ **Zone-Based Assignment** - One provider per zone per category
✅ **Unique Constraint** - Prevents duplicate assignments
✅ **Auto Provider Finding** - User books → System auto-assigns correct provider
✅ **Real-Time Tracking** - User sees serviceman location
✅ **Multi-Level Notifications** - All stakeholders notified at each step
✅ **Payment Processing** - Cash/UPI/Card support
✅ **Rating System** - Users rate providers
✅ **Earnings Tracking** - Providers see real-time earnings

---

## 📱 App File Structure

**Backend (Laravel):** `C:\...\backend\`
- Routes: `routes/api.php`, `Modules/*/Routes/api.php`
- Controllers: `Modules/*/Http/Controllers/Api/V1/`
- Models: `Modules/*/Entities/`

**Provider App (Flutter):** `C:\...\provider\Provider app\lib\`
- Dashboard: `feature/dashboard`
- Booking: `feature/booking_requests`, `feature/booking_details`
- Auth: `feature/auth`

**Serviceman App (Flutter):** `C:\...\Service man app\lib\`
- Booking: `feature/booking_request`, `feature/booking_details`
- Auth: `feature/auth`

**User App (Flutter):** `C:\...\userapk\lib\`
- Booking: `feature/booking`, `feature/checkout`
- Shopping: `feature/cart`, `feature/service`
- Tracking: `feature/booking/booking_tracking`
