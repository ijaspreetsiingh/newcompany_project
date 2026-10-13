# Payment Gateway Restrictions System - Documentation Index

## Overview

This system allows providers to restrict which payment methods customers can use during checkout. When independent commission mode is enabled for a provider, the admin can select exactly which payment gateways (Cash, Wallet, Stripe, Razorpay, etc.) are allowed. Customers then see ONLY those methods at checkout.

---

## Documentation Files

### 🎯 START HERE

1. **PAYMENT_METHODS_QUICK_REFERENCE.md**
   - 5-minute overview
   - Quick verification steps
   - Common fixes
   - File locations
   - **Best for**: Quick questions, troubleshooting

### 📋 DETAILED GUIDES

2. **COMPLETE_PAYMENT_FLOW_WITH_PROVIDER_RESTRICTIONS.md**
   - Full system architecture
   - Complete flow diagram
   - Component breakdown
   - Zone + Category + Provider logic
   - **Best for**: Understanding how system works end-to-end

3. **PAYMENT_FLOW_TESTING_GUIDE.md**
   - Step-by-step testing procedures
   - Admin setup verification
   - API testing with Postman
   - User app testing
   - End-to-end scenarios
   - Troubleshooting checklist
   - Test report template
   - **Best for**: QA, testing, validation

### ✅ VERIFICATION

4. **PAYMENT_SYSTEM_COMPLETE_VERIFICATION.md**
   - Executive summary
   - What's implemented & working
   - Layer-by-layer breakdown
   - Complete scenario walkthrough
   - Verification checklist
   - System status: COMPLETE ✅
   - **Best for**: Confirming system is working, deployment decision

---

## Quick Navigation

### I need to...

**Understand how the system works**
→ Read: `COMPLETE_PAYMENT_FLOW_WITH_PROVIDER_RESTRICTIONS.md`

**Setup a provider with payment restrictions**
→ Follow: `PAYMENT_FLOW_TESTING_GUIDE.md` → STEP 1

**Test if it's working**
→ Use: `PAYMENT_FLOW_TESTING_GUIDE.md` → STEP 2-4

**Fix something that's broken**
→ Check: `PAYMENT_METHODS_QUICK_REFERENCE.md` → Common Issues

**Verify before production**
→ Review: `PAYMENT_SYSTEM_COMPLETE_VERIFICATION.md`

**Find a specific file or API**
→ Check: `PAYMENT_METHODS_QUICK_REFERENCE.md` → File Reference

---

## System Architecture (Bird's Eye View)

```
┌─────────────────────────────────────────────────────────────────┐
│ ADMIN PANEL                                                     │
│ Provider Wizard Step 4 → Select Payment Methods → Save           │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│ DATABASE                                                        │
│ providers.allowed_payment_methods = ["stripe", "razorpay", ...] │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│ BACKEND API                                                     │
│ GET /api/v1/client/setup/payment-config?provider_id=UUID        │
│ Returns: Filtered gateways + flags (cash, wallet, etc.)         │
└────────────────────────────┬────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│ USER APP                                                        │
│ Fetches config → Filters payment lists → Shows ONLY allowed     │
│ methods to customer                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Key Components

### 1. Admin Panel
- **File**: `Modules/ProviderManagement/Resources/views/admin/provider/edit.blade.php`
- **Location**: Provider Edit Form → Scroll to "Allowed Payment Gateways"
- **Action**: Admin checks boxes for allowed methods

### 2. Database
- **Table**: `providers`
- **Field**: `allowed_payment_methods` (JSON)
- **Format**: `["cash_after_service", "wallet_payment", "stripe", "razorpay"]`

### 3. Backend API
- **Endpoint**: `GET /api/v1/client/setup/payment-config`
- **File**: `Modules/CustomerModule/Http/Controllers/Api/V1/Customer/ConfigController.php`
- **Logic**: Reads DB → Filters gateways → Returns config with flags

### 4. User App
- **File**: `lib/feature/checkout/controller/checkout_controller.dart`
- **Logic**: Fetches API → Applies restrictions → Displays filtered list
- **UI**: `lib/feature/checkout/widget/new_payment_method_selection.dart`

### 5. Validation
- **File**: `Modules/BookingModule/Http/Controllers/Api/V1/Customer/BookingController.php`
- **Method**: `placeRequest()`
- **Logic**: Validates payment_method is in provider's allowed list

---

## Helper Functions (Backend)

All in: `app/Lib/Helpers.php`

| Function | Purpose | Returns |
|----------|---------|---------|
| `providerIsIndependent($provider)` | Check if independent mode ON | bool |
| `providerAllowedPaymentMethods($provider)` | Get allowed methods array | array or null |
| `providerAllowsPaymentMethod($provider, $method)` | Check if method allowed | bool |
| `filterPaymentGatewaysForProvider($gateways, $provider)` | Filter gateway list | array |
| `providerBookingFee($provider)` | Get provider's booking fee | float or null |
| `providerEffectiveTaxPercent($provider, $tax)` | Get provider's tax % | float |

---

## API Endpoints

### Get Provider Payment Config
```
GET /api/v1/client/setup/payment-config?provider_id={UUID}

Returns:
{
  "provider_id": "uuid",
  "independent_mode": 1,
  "payment_gateways": [{gateway: "stripe"}, {gateway: "razorpay"}],
  "cash_after_service": 1,
  "wallet_payment": 0,
  "offline_payment": 0,
  "digital_payment": 1,
  "booking_additional_charge": 1,
  "additional_charge_fee_amount": 50,
  "provider_tax_percent": 5
}
```

### Place Booking
```
POST /api/v1/client/order/submission/transmit

Required: payment_method must be in provider's allowed list
Validation: providerRejectsPaymentMethod($provider_id, $method)
```

---

## Workflow Example

```
SCENARIO: Customer books from "ABC Plumbing" (Stripe/Razorpay only)

1. ADMIN SETUP (1 time)
   Admin Panel → Edit ABC Plumbing
   Scroll to "Allowed Payment Gateways"
   ☑ Stripe
   ☑ Razorpay
   ☐ Cash after service
   ☐ Wallet
   ☐ Offline
   SAVE

2. CUSTOMER BROWSING
   Customer opens app → Searches "ABC Plumbing"
   Selects service → Adds to cart

3. CHECKOUT FLOW
   Customer goes to Checkout
   CheckoutController.getPaymentMethodList() called
   ├─ Fetches global config
   ├─ Calls fetchProviderPaymentConfig("abc-plumbing-uuid")
   │
   └─ API REQUEST
      GET /api/v1/client/setup/payment-config?provider_id=abc-plumbing-uuid
      
      ↓ BACKEND PROCESSING
      
      Reads: providers.allowed_payment_methods = ["stripe", "razorpay"]
      Filters gateways to only those in list
      Returns: {
        payment_gateways: [
          {gateway: "stripe"},
          {gateway: "razorpay"}
        ],
        cash_after_service: 0,
        wallet_payment: 0,
        digital_payment: 1
      }
      
      ↓ RESPONSE RECEIVED

4. APP FILTERING
   _applyProviderPaymentRestrictions()
   ├─ Reads: cash_after_service = 0 → Remove Cash from list
   ├─ Reads: wallet_payment = 0 → Remove Wallet from list
   ├─ Reads: digital_payment = 1 → Keep digital gateways
   └─ Filter digital list to only: [stripe, razorpay]

5. UI DISPLAY
   Payment Method Screen:
   ✅ Stripe Card        [SELECT]
   ✅ Razorpay           [SELECT]
   ❌ Cash After Service (not visible)
   ❌ Wallet             (not visible)
   ❌ Offline            (not visible)

6. CUSTOMER SELECTION
   Customer selects: Stripe
   Payment method stored: "stripe"

7. BOOKING CREATION
   POST /api/v1/client/order/submission/transmit
   Body: {payment_method: "stripe", provider_id: "abc-plumbing-uuid", ...}
   
   ↓ BACKEND VALIDATION
   
   providerRejectsPaymentMethod("abc-plumbing-uuid", "stripe")
   ├─ Reads: allowed_payment_methods = ["stripe", "razorpay"]
   ├─ Checks: "stripe" in list
   └─ Result: ✅ ALLOWED
   
   Booking Created ✅
```

---

## Testing Checklist

- [ ] Step 1: Admin Panel Setup (PAYMENT_FLOW_TESTING_GUIDE.md → STEP 1)
- [ ] Step 2: Backend API Testing (PAYMENT_FLOW_TESTING_GUIDE.md → STEP 2)
- [ ] Step 3: User App Testing (PAYMENT_FLOW_TESTING_GUIDE.md → STEP 3)
- [ ] Step 4: End-to-End Testing (PAYMENT_FLOW_TESTING_GUIDE.md → STEP 4)
- [ ] Step 5: Verification (PAYMENT_SYSTEM_COMPLETE_VERIFICATION.md)

---

## Troubleshooting

### Payment Methods Not Showing
- [ ] Check: `independent_mode = 1` in database
- [ ] Check: `allowed_payment_methods` is NOT null/empty
- [ ] Check: At least ONE checkbox selected in admin
- [ ] Check: Global payment toggles enabled
→ Full guide: `PAYMENT_METHODS_QUICK_REFERENCE.md`

### Wrong Methods Showing
- [ ] Verify admin wizard selections
- [ ] Check API response with Postman
- [ ] Inspect `payment_gateways` array in response
→ Full guide: `PAYMENT_METHODS_QUICK_REFERENCE.md`

### Booking Rejected Even With Allowed Method
- [ ] Check backend validation
- [ ] Verify method in `allowed_payment_methods`
- [ ] Check `independent_mode` status
→ Full guide: `PAYMENT_METHODS_QUICK_REFERENCE.md`

---

## File Locations

### Backend
```
Modules/ProviderManagement/
├─ Resources/views/admin/provider/edit.blade.php     ← Admin UI
└─ Http/Controllers/Web/Admin/ProviderController.php ← Save logic

Modules/CustomerModule/
└─ Http/Controllers/Api/V1/Customer/ConfigController.php ← API

app/Lib/Helpers.php ← Helper functions
```

### Database
```
Database/table: providers
├─ allowed_payment_methods (json)
├─ independent_mode (tinyint)
├─ booking_fee (decimal)
└─ tax_percent (decimal)
```

### User App
```
lib/feature/checkout/
├─ controller/checkout_controller.dart    ← Fetch & apply logic
├─ repo/checkout_repo.dart                ← API call
└─ widget/new_payment_method_selection.dart ← UI display
```

---

## Production Deployment

1. **Pre-Deployment**:
   - Review: `PAYMENT_SYSTEM_COMPLETE_VERIFICATION.md`
   - Test: `PAYMENT_FLOW_TESTING_GUIDE.md`
   - Verify: All documentation matches code

2. **Deployment**:
   - Update backend code
   - Run migrations (if any)
   - Update mobile app
   - Test with real providers

3. **Post-Deployment**:
   - Monitor API response times
   - Check error logs
   - Verify bookings being created correctly
   - Monitor payment success rates

---

## Support

For questions or issues:
1. Check the relevant documentation file above
2. Search this index for keywords
3. Review the quick reference guide
4. Follow the testing guide steps
5. Contact development team with findings

**Last Updated**: [Current Date]
**System Status**: ✅ Complete and Production Ready
