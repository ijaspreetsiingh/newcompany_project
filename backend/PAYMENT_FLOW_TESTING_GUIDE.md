# Payment Flow Testing Guide - Complete Provider Payment Restrictions

## Overview
This guide validates that payment method restrictions work correctly across:
1. Admin Panel (Provider Setup)
2. Backend API (Filtering & Validation)
3. User App (Display & Selection)

---

## STEP 1: Admin Panel Setup Verification

### 1.1 Create/Edit Provider with Independent Mode

**Go to**: Admin Panel → Provider Management → Edit Provider

**Section: Step 4 - Independent Commission**

✅ Check: "Allow Independent Commission" toggle
- This enables provider-specific payment settings
- Status: Should show `independent_mode = 1` in database

✅ Configure:
- Admin Commission %: e.g., 2%
- Provider Commission %: e.g., 8%
- Platform Fee Amount: e.g., 50
- Tax %: e.g., 5%
- Booking Fee: e.g., 100

### 1.2 Select Payment Gateways

**Same Page - Payment Gateways Section**

✅ Check EXACTLY which gateways are allowed:
```
□ Cash after service    ← Should restrict COD
□ Wallet                ← Should restrict Wallet Payment  
□ Offline payment       ← Should restrict Bank Transfer
☑ Stripe               ← Allow Stripe
☑ Razorpay             ← Allow Razorpay
□ Paypal               ← Should restrict Paypal
```

**Example Scenario 1: Only Digital**
- Uncheck: Cash after service, Wallet, Offline
- Check: Stripe, Razorpay ONLY
- Expected: Customer sees ONLY Stripe/Razorpay at checkout

**Example Scenario 2: Cash + Wallet Only**
- Check: Cash after service, Wallet
- Uncheck: Offline, All digital gateways
- Expected: Customer sees ONLY Cash & Wallet, no digital methods

**Example Scenario 3: All Methods**
- Check: ALL options
- Expected: All payment methods available to customer

### 1.3 Save & Verify Database

**Check**: `SELECT * FROM providers WHERE id = 'provider_uuid'`

Look for:
```sql
independent_mode: 1
allowed_payment_methods: ["cash_after_service","wallet_payment","stripe","razorpay"]
admin_commission_percent: 2
provider_commission_percent: 8
platform_fee_amount: 50
tax_percent: 5
booking_fee: 100
```

---

## STEP 2: Backend API Testing

### 2.1 Test Payment Config Endpoint

**API Endpoint**: `GET /api/v1/client/setup/payment-config`

**Query Parameter**: `?provider_id=PROVIDER_UUID`

**Using Postman/Curl**:
```bash
curl -X GET \
  "https://your-domain.com/api/v1/client/setup/payment-config?provider_id=abc123def456" \
  -H "Accept: application/json"
```

**Expected Response**:
```json
{
  "response_code": "default_200",
  "content": {
    "provider_id": "abc123def456",
    "independent_mode": 1,
    "payment_gateways": [
      {
        "gateway": "stripe",
        "gateway_title": "Stripe",
        "gateway_image_full_path": "..."
      },
      {
        "gateway": "razorpay",
        "gateway_title": "Razorpay",
        "gateway_image_full_path": "..."
      }
    ],
    "cash_after_service": 1,
    "digital_payment": 1,
    "wallet_payment": 1,
    "offline_payment": 0,
    "booking_additional_charge": 1,
    "additional_charge_label_name": "Platform Fee",
    "additional_charge_fee_amount": 50,
    "provider_tax_percent": 5
  }
}
```

### 2.2 Verify Filtering Logic

**Test Case 1**: Provider with restricted gateways
- Expected: `payment_gateways` array contains ONLY Stripe & Razorpay
- Should NOT include: Paypal, PayStack, SenangPay, etc.

**Test Case 2**: Provider with independent_mode OFF
- Expected: `independent_mode: 0`
- Should return: Global config only, not provider-specific settings
- `cash_after_service`: From global business config
- `payment_gateways`: All active gateways (not filtered)

**Test Case 3**: Provider with independent_mode ON but no allowed methods
- Scenario: All checkboxes unchecked in wizard
- Expected: Empty `payment_gateways: []`
- All toggles: 0 (no payment methods)

**Test Case 4**: Missing provider_id
- Query: No provider_id parameter
- Expected: Still returns global config with independent_mode: 0

### 2.3 Database Verification

**Check Allowed Methods Storage**:
```sql
SELECT id, company_name, independent_mode, allowed_payment_methods 
FROM providers 
WHERE is_approved = 1;
```

**Example Output**:
```
Provider A: allowed_payment_methods = ["cash_after_service","wallet_payment"]
Provider B: allowed_payment_methods = ["stripe","razorpay","paypal"]
Provider C: allowed_payment_methods = [] (empty - uses global)
```

---

## STEP 3: User App (Flutter) Testing

### 3.1 Open User App & Test Booking Flow

**Pre-requisite**: Install latest Flutter app build

**Scenario Setup**:
- Zone: Set by customer location
- Category: Select a service category
- Provider: Select specific provider (Scenario 1 from Step 1.2)
- Expected: Only Stripe & Razorpay visible

**Steps**:
1. Open Customer App
2. Select Service Category (e.g., "Plumbing")
3. Select Provider (e.g., the one with ONLY Stripe/Razorpay allowed)
4. Click "Add to Cart"
5. Go to Checkout
6. Scroll to "Payment Method" section
7. Verify displayed methods

**Expected Result for Scenario 1** (Only Digital):
```
✅ Stripe Card
✅ Razorpay
❌ Cash After Service    (NOT visible)
❌ Wallet                (NOT visible if global wallet enabled)
❌ Offline Payment       (NOT visible)
```

### 3.2 Test Different Provider Scenarios

**Scenario 2**: Cash + Wallet Only Provider

**Steps**:
1. Select a DIFFERENT provider (with Cash + Wallet only)
2. Add to cart
3. Go to Checkout → Payment Method

**Expected Result**:
```
✅ Cash After Service
✅ Wallet (if customer is logged in with balance)
❌ Stripe             (NOT visible)
❌ Razorpay           (NOT visible)
❌ Offline            (NOT visible if not allowed)
```

**Scenario 3**: Provider with Independent Mode OFF

**Steps**:
1. Select provider WITHOUT independent mode enabled
2. Add to cart
3. Go to Checkout → Payment Method

**Expected Result**:
```
Shows GLOBAL payment methods (all enabled in business config)
NOT provider-specific restrictions
```

### 3.3 Payment Selection & Booking

**Test Case 1**: Correct Method Selection
- Scenario 1 Provider (Stripe/Razorpay only)
- Customer selects: Stripe
- Click: Proceed to Payment
- Expected: Should NOT show error, gateway accepts payment

**Test Case 2**: Invalid Method Attempt (Edge Case)
- Scenario 1 Provider (Stripe/Razorpay only)
- Try to force select: "Cash After Service" (via API manipulation)
- Expected Result: Backend should reject with error:
  ```json
  {
    "response_code": "error_code",
    "message": "Payment method not allowed for this provider"
  }
  ```

### 3.4 Check App Logs

**In Flutter App Console**:
```
[CheckoutController] fetchProviderPaymentConfig called with provider_id: abc123
[CheckoutController] API Response: payment_gateways length = 2
[CheckoutController] _applyProviderPaymentRestrictions: cash_after_service filtered out
[CheckoutController] Final payment list: [stripe, razorpay]
```

---

## STEP 4: End-to-End Integration Testing

### 4.1 Complete Booking Flow

**Test Scenario**: Customer books service from provider with restricted methods

**Setup**:
- Provider: "ABC Plumbing" (Independent Mode ON)
  - Allowed Payments: Stripe, Razorpay ONLY
  - Booking Fee: 50
  - Tax: 5%

**Customer Journey**:
```
1. Search → Find "ABC Plumbing"
2. Select Service → "Pipe Repair" (Price: 500)
3. Add to Cart
4. Checkout
   - Service Price: 500
   - Platform Fee: 50
   - Tax: 25 (5% of service)
   - Total: 575
5. Payment Method Selection
   ✅ Stripe available
   ✅ Razorpay available
   ❌ Cash After Service NOT visible
   ❌ Wallet NOT visible
6. Select Stripe
7. Proceed to Payment
8. Complete Transaction
9. Booking Confirmed
```

**Verification Points**:
✅ Payment methods filtered correctly
✅ Booking fee applied (50)
✅ Tax calculated (5%)
✅ Stripe payment processed successfully
✅ Booking saved with correct provider_id & payment_method

### 4.2 Multiple Providers in Cart

**Edge Case**: Customer has services from 2 different providers

**Setup**:
- Provider A: Stripe/Razorpay only
- Provider B: Cash/Wallet only
- Cart: Service from Provider A + Service from Provider B

**Expected Behavior**:
- Cart shows combined services
- Backend should use FIRST provider's payment config
- OR show: Only methods that BOTH providers support

**Note**: Check how your system handles multi-provider carts

---

## STEP 5: Troubleshooting Checklist

### If Payment Methods Not Showing in User App:

❌ **Problem**: All payment methods hidden

**Solution**:
1. Verify `independent_mode = 1` in database
2. Check `allowed_payment_methods` is NOT null/empty
3. Verify at least ONE checkbox selected in admin wizard
4. Check global payment toggles enabled:
   - `cash_after_service = 1`
   - `digital_payment = 1`
   - OR `wallet_payment = 1`

❌ **Problem**: Wrong methods showing

**Solution**:
1. Verify admin wizard selections match expected list
2. Check API response `/client/setup/payment-config?provider_id=X`
3. Inspect `payment_gateways` array in response
4. Verify `cash_after_service`, `wallet_payment` flags in response

❌ **Problem**: Payment method selected but booking rejected

**Solution**:
1. Check backend validation: `providerRejectsPaymentMethod()`
2. Verify selected method in provider's `allowed_payment_methods`
3. Check provider `independent_mode` status
4. Verify payment method enabled globally

### Database Query Checks:

**Check Provider Settings**:
```sql
SELECT 
  id, 
  company_name,
  independent_mode,
  allowed_payment_methods,
  booking_fee,
  tax_percent,
  admin_commission_percent,
  provider_commission_percent
FROM providers 
WHERE id = 'PROVIDER_UUID';
```

**Check Global Payment Config**:
```sql
SELECT key, live_values 
FROM business_settings 
WHERE settings_type IN (
  'service_setup',
  'booking_setup'
);
```

**Check Payment Gateways**:
```sql
SELECT key_name, settings_type, live_values 
FROM addon_settings 
WHERE settings_type = 'payment_config';
```

---

## STEP 6: Performance Considerations

### Optimization Notes:

1. **Provider Config Caching**:
   - User app caches `_providerPaymentConfig` per provider
   - Reduces API calls during checkout

2. **Database Indexing**:
   - Ensure index on: `providers(id, independent_mode, allowed_payment_methods)`
   - Ensure index on: `addon_settings(settings_type, key_name)`

3. **API Response Time**:
   - Payment config endpoint should respond <500ms
   - Check database query execution time

---

## Test Report Template

```
TEST DATE: ___________
TESTER: _______________
BUILD VERSION: ________

PROVIDER SETUP:
☐ Independent Mode: ON / OFF
☐ Allowed Methods Selected: ______________________
☐ Database Updated: Yes / No
☐ Values Stored Correctly: Yes / No

API TESTING:
☐ Endpoint Responds: Yes / No
☐ Response Code: 200 / ____
☐ Gateways Filtered: Yes / No
☐ Flags Correct: Yes / No

USER APP TESTING:
☐ Methods Displayed Correctly: Yes / No
☐ Count Matches Expected: _____
☐ Correct Methods Shown: Yes / No

BOOKING FLOW:
☐ Selection Works: Yes / No
☐ Payment Processed: Yes / No
☐ Booking Created: Yes / No
☐ Fees Applied Correctly: Yes / No

ISSUES FOUND:
______________________________________________________

FIXES APPLIED:
______________________________________________________

PASSED: ☐ Yes ☐ No
```

---

## Support Contacts

For issues:
1. Check this document first
2. Review database values
3. Check API response
4. Inspect app logs
5. Contact development team with test report
