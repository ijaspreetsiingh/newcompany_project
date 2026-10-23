# 💰 COMPLETE PAYMENT FLOW - DEMANDIUM v3.7

## System Overview

```
USER APP (Customer)
    ↓ Books service + Selects payment method
    ↓
BACKEND (Laravel)
    ↓ Creates booking, calculates taxes/commission
    ↓ Redirects to payment gateway (Stripe/Paypal/Razorpay/etc)
    ↓ Receives payment callback
    ↓ Updates booking status
    ↓ Splits payment: Admin Commission + Provider Earning + Tax
    ↓
PROVIDER APP
    ↓ Receives booking notification
    ↓ Accepts booking
    ↓ Views booking details + payment info
    ↓
SERVICEMAN APP
    ↓ Receives job assignment
    ↓ Completes service
    ↓
WALLET / TRANSACTION MODULE
    ↓ Records all transactions
    ↓ Tracks provider earnings
```

---

## PAYMENT CALCULATION BREAKDOWN

### Service Price = Base Price + Variations

**Example:**
- Service: "Full Home Cleaning"
- Base Price: ₹2,500
- Variations: None
- **Total Service Price = ₹2,500**

### Applied Charges

1. **Service Tax** (on service price)
   - Set per service: `services.tax` (e.g., 18%)
   - **Calculation**: ₹2,500 × 18% = ₹450

2. **Booking Fee** (platform fee)
   - Set in business settings: `booking_fee` (e.g., ₹50)
   - **Calculation**: Flat ₹50

3. **Service Charge** (optional)
   - Set per service if enabled
   - **Calculation**: Flat or percentage

### Total Amount Customer Pays

```
Customer Total = Service Price + Service Tax + Booking Fee
               = ₹2,500 + ₹450 + ₹50
               = ₹3,000
```

### Payment Split (After Successful Payment)

**Admin Gets:**
- Service Tax: ₹450 (100%)
- Booking Fee: ₹50 (100%)
- Admin Commission: Service Price × Commission% = ₹2,500 × 20% = ₹500
- **Admin Total = ₹450 + ₹50 + ₹500 = ₹1,000**

**Provider Gets:**
- Service Price - Admin Commission = ₹2,500 - ₹500 = ₹2,000
- **Provider Total = ₹2,000**

**Customer Paid = ₹3,000**
**Provider Earned = ₹2,000**
**Admin Kept = ₹1,000** (taxes + commission + fee)

---

## WHERE PAYMENT IS SET IN SYSTEM

### 1. SERVICE LEVEL - Backend

**File**: `Modules/ServiceManagement/Entities/Service.php` or Database

**Fields**:
```
services table:
- id: UUID
- name: string
- price: decimal (BASE PRICE) ← User sees this
- tax: integer (e.g., 18 for 18%) ← Applied on service price only
- cover_image, thumbnail, etc.
```

**Where you set it**: `/admin/service/create` and `/admin/service/edit/{id}`

In the form:
- Price input field
- Tax percentage field

### 2. SYSTEM LEVEL - Backend Admin Settings

**File**: `Modules/BusinessSettingsModule`

**Business Settings Keys**:
```
- admin_commission: % (e.g., 20)  ← How much admin keeps from service price
- booking_fee: ₹ (e.g., 50)       ← Platform fee per booking
- service_charge: ₹ or % (optional)
- payment_method_commission: % (e.g., 2.5% for Stripe)
```

**Where you set it**: `/admin/business-settings` or similar

---

## PAYMENT FLOW - Step by Step

### Customer App - USER BOOKING

**Step 1: Browse Services**
- User sees service price (BASE)
- Example: "Full Home Cleaning - ₹2,500"

**Step 2: Add to Cart**
- User adds service to cart
- Cart shows: Service Price: ₹2,500

**Step 3: Checkout**
- User goes to checkout
- System calculates:
  - Service Price: ₹2,500
  - Service Tax (18%): ₹450
  - Booking Fee: ₹50
  - **Total Due: ₹3,000**
- User sees breakdown with tax, fee, total

**Step 4: Select Payment Method**
- Cash after service
- Online payment (Stripe/Paypal/Razorpay/etc.)

**Step 5: Submit Booking**
- If CASH: Booking created with status `pending_payment`
- If ONLINE: Redirects to payment gateway

**Step 6: Payment Confirmation**
- Payment successful → Booking status = `accepted`
- Push notification to customer
- Notification to provider

### Backend - PAYMENT PROCESSING

**File**: `Modules/PaymentModule/Http/Controllers/PaymentController.php`

**Webhook/Callback Handler**:
```php
public function paymentSuccess($bookingId)
{
    $booking = Booking::find($bookingId);
    
    // Update booking status
    $booking->booking_status = 'accepted';
    $booking->payment_status = 'paid';
    $booking->save();
    
    // Calculate splits
    $servicePrice = $booking->service->price;
    $tax = ($servicePrice * $booking->service->tax) / 100;
    $bookingFee = config('settings.booking_fee');
    $adminCommission = ($servicePrice * config('settings.admin_commission')) / 100;
    $providerEarning = $servicePrice - $adminCommission;
    
    // Record transactions
    Transaction::create([
        'booking_id' => $bookingId,
        'type' => 'service_payment',
        'amount' => $booking->total_amount,
        'description' => 'Payment for ' . $booking->service->name
    ]);
    
    // Credit provider wallet
    $provider = $booking->provider;
    $provider->account()->increment('balance', $providerEarning);
    
    // Notify provider
    notifyProvider($provider, "New booking - You earned ₹{$providerEarning}");
}
```

### Provider App - BOOKING DETAILS

**Provider sees**:
1. Booking ID
2. Service Name
3. Customer Name & Rating
4. **Service Price: ₹2,500** (what they will earn)
5. Taxes & Fees: ₹500 (breakdown)
6. **Total Amount: ₹3,000** (what customer paid)
7. Payment Status: `Paid` or `Pending`
8. Payment Method: `Card` / `UPI` / `Cash`

Provider can see in dashboard:
- Today's Earnings: ₹5,000 (sum of all provider earnings from bookings)
- Admin Commission Cut: ₹1,250
- Taxes Kept by Admin: ₹1,125

### Serviceman App - JOB DETAILS

**Serviceman sees**:
- Booking ID
- Service name
- Customer details
- Scheduled time
- Location
- Service Price (what provider will pay them - if applicable)

Serviceman DOES NOT see tax/commission breakdown

### Transaction Module - RECORD KEEPING

**File**: `Modules/TransactionModule/Entities/Transaction.php`

**Every booking creates transactions**:

```
Transaction 1:
- Type: "Customer Payment"
- From: Customer
- To: Admin
- Amount: ₹3,000
- Status: Completed

Transaction 2:
- Type: "Service Charge"
- From: Admin
- To: Provider
- Amount: ₹2,000 (provider earning)
- Status: Completed

Transaction 3:
- Type: "Admin Commission"
- From: Service Price
- To: Admin
- Amount: ₹500
- Status: Completed
```

---

## WHERE TO FIND EACH COMPONENT

### 1. Service Price & Tax
**Backend Files**:
- Create: `Modules/ServiceManagement/Resources/views/admin/create.blade.php`
  - Line: Tax percentage field
  - Line: Price field

- Edit: `Modules/ServiceManagement/Resources/views/admin/edit.blade.php`

- API: `Modules/ServiceManagement/Http/Controllers/Api/V1/Admin/ServiceController.php`
  - `store()` method → saves price and tax

### 2. Admin Commission & Fees
**Backend Files**:
- Settings: `Modules/BusinessSettingsModule`
  - Admin can set commission % and booking fee

- Config: `config/settings.php` or database `business_settings` table

### 3. Payment Processing
**Backend Files**:
- Main: `Modules/PaymentModule/Http/Controllers/PaymentController.php`
- Stripe: `Modules/PaymentModule/Http/Controllers/StripePaymentController.php`
- Razorpay: `Modules/PaymentModule/Http/Controllers/RazorPayController.php`
- Webhook: Handles payment callbacks, updates booking

### 4. Transaction Tracking
**Backend Files**:
- Model: `Modules/TransactionModule/Entities/Transaction.php`
- Controller: `Modules/TransactionModule/Http/Controllers/Api/V1/TransactionController.php`

### 5. Wallet/Account
**Backend Files**:
- Model: `Modules/TransactionModule/Entities/Account.php`
- Tracks: `balance`, `total_earned`, `total_paid_out`

---

## USER APP - What Customer Sees

### Checkout Screen
```
Service: Full Home Cleaning
Price: ₹2,500              ← Base service price
Service Tax (18%): ₹450   ← Calculated from service.tax
Booking Fee: ₹50          ← Platform fee
─────────────────────────
Total Due: ₹3,000         ← What customer pays
```

### Payment Methods Available
1. **Cash after service** - No payment now, pay serviceman on-site
2. **Online Payment** - Card/UPI/Wallet
   - Redirects to payment gateway
   - Completes transaction
   - Booking confirmed immediately

### Confirmation Screen (After Payment)
```
Payment Successful ✅
Booking ID: #NE384921
Amount Paid: ₹3,000
Booking Confirmed
Professional assigned soon
```

---

## PROVIDER APP - What Provider Sees

### Booking List
```
Booking #NE384921
Service: Full Home Cleaning
Customer: Aanya Sharma ⭐ 4.8

Earn: ₹2,000          ← Provider's actual earning
Customer Paid: ₹3,000 ← Total transaction
(Tax & fees: ₹1,000)  ← Breakdown shown

Status: Paid ✓
```

### Provider Wallet/Earnings Dashboard
```
Today's Total Earnings: ₹5,000
(From 2-3 completed bookings)

Commission Cut (20%): -₹1,000
Platform Tax/Fees: -₹800
─────────────────────────
Your Net Earning: ₹3,200
```

---

## ADMIN APP/PANEL - What Admin Sees

### Booking Details View
```
Booking #NE384921
Customer: Aanya
Provider: Rahul Services
Service: Full Home Cleaning

Breakdown:
├─ Service Price: ₹2,500
├─ Service Tax (18%): ₹450
├─ Booking Fee: ₹50
├─ Admin Commission (20%): ₹500
└─ Provider Earning: ₹2,000
─────────────────────────
Total Transaction: ₹3,000

Admin Revenue This Booking: ₹1,000
- Tax: ₹450
- Commission: ₹500
- Fee: ₹50
```

### Admin Dashboard
```
Total Revenue (This Month): ₹50,000
- From Taxes: ₹9,000
- From Commissions: ₹20,000
- From Booking Fees: ₹5,000
- From Other Charges: ₹16,000

Provider Payouts: -₹40,000
Net Admin Profit: ₹10,000
```

---

## PAYMENT GATEWAY INTEGRATION

### Supported Gateways
1. **Stripe** - International
2. **Razorpay** - India
3. **Paypal** - International
4. **Paytm** - India
5. **Flutterwave** - Africa
6. **SslCommerz** - Bangladesh
7. **SenangPay** - Malaysia
8. **Paystac** - Various

### For Each Gateway:
1. Admin configures API keys in settings
2. At checkout, customer redirected to gateway
3. Gateway handles payment securely
4. Sends webhook callback to `/api/v1/payment/callback`
5. Backend validates & processes
6. Updates booking status

---

## CASH PAYMENT FLOW

### For "Cash After Service" Bookings

1. **User selects "Cash"** at checkout
2. **Booking created** with `payment_status = 'pending_payment'`
3. **Provider accepts** and completes service
4. **At service end**, serviceman collects cash from customer
5. **Serviceman marks "collected"** in app
6. **Backend updates** booking to `payment_status = 'paid'`
7. **Provider wallet credited** with earning amount

---

## SCENARIO EXAMPLE

### Booking Journey: Full Flow

**Customer Books:**
1. "Full Home Cleaning - ₹2,500" selected
2. Checkout shows:
   - Price: ₹2,500
   - Tax (18%): ₹450
   - Fee: ₹50
   - **Total: ₹3,000**
3. Selects "Card Payment"
4. Pays ₹3,000 via Stripe
5. Gets confirmation: "Booking #NE384921 Confirmed"

**Backend Processes:**
1. Payment successful from Stripe
2. Creates Transaction:
   - Customer Payment: ₹3,000 ✓
3. Updates Booking: status = "accepted"
4. Splits money:
   - Provider Account: +₹2,000
   - Admin Account: +₹450 (tax) +₹50 (fee) +₹500 (commission)

**Provider Receives:**
1. Push Notification: "New Booking! Earn ₹2,000"
2. Opens booking, sees:
   - Customer: Aanya
   - Service: Cleaning
   - **Provider Earning: ₹2,000**
   - Payment Status: Paid ✓
3. Accepts booking
4. Assigns serviceman

**Serviceman Goes:**
1. Goes to customer location
2. Completes service
3. Collects cash OR customer already paid (card)
4. Marks "Completed"

**Provider Wallet Updates:**
- Available Balance: +₹2,000
- Can withdraw anytime

---

## KEY TAKEAWAYS

✅ **Customer pays**: Service Price + Tax + Booking Fee = Total
✅ **Provider earns**: Service Price - Admin Commission
✅ **Admin keeps**: Tax + Booking Fee + Commission
✅ **All tracked**: In Transaction module
✅ **Visible to**: Customer (what they paid), Provider (what they earned), Admin (everything)
✅ **Payment methods**: Cash or Online (Stripe/Razorpay/etc)
✅ **Each booking**: Creates transaction records for accounting

