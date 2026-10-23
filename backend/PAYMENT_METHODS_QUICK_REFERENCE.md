# QUICK REFERENCE: Provider Payment Methods Workflow

## 3-Step Verification

### Step 1: Admin Panel Setup (2 min)
```
Provider Management → Edit Provider → Scroll Down
┌─ FIND: "Allowed Payment Gateways" section
├─ ACTION: Check boxes for ONLY methods this provider accepts
│  ✓ Cash after service
│  ✓ Wallet
│  ✓ Stripe
│  ✗ Razorpay (unchecked)
│  ✗ Paypal (unchecked)
└─ SAVE: Form saves to database
```

### Step 2: Verify API Response (2 min)
```bash
curl "https://api.domain.com/api/v1/client/setup/payment-config?provider_id=UUID"

# Expected Response:
{
  "content": {
    "payment_gateways": [
      {"gateway": "stripe", ...},
      {"gateway": "wallet", ...}
      # NOTE: Razorpay & Paypal NOT here
    ],
    "cash_after_service": 1,
    "wallet_payment": 1,
    "offline_payment": 0,
    "digital_payment": 1
  }
}
```

### Step 3: User App Display (2 min)
```
Open User App → Select Service → Add to Cart → Checkout

Payment Method Screen:
✅ Cash After Service       [VISIBLE]
✅ Wallet                   [VISIBLE]
✅ Stripe                   [VISIBLE]
❌ Razorpay                 [NOT VISIBLE]
❌ Paypal                   [NOT VISIBLE]

# Only shows: cash_after_service, wallet, stripe
```

---

## File Reference Guide

### Backend Files

| File | Purpose |
|------|---------|
| `Modules/ProviderManagement/Resources/views/admin/provider/edit.blade.php` | Admin UI checkboxes for payment methods (line 667-684) |
| `Modules/ProviderManagement/Http/Controllers/Web/Admin/ProviderController.php` | Saves selections to DB (line 1227) |
| `Modules/CustomerModule/Http/Controllers/Api/V1/Customer/ConfigController.php` | API endpoint that filters methods (line ~200) |
| `app/Lib/Helpers.php` | Helper functions (providerAllowsPaymentMethod, etc.) |

### Database

| Table | Field | Example |
|-------|-------|---------|
| providers | allowed_payment_methods | `["cash_after_service","stripe"]` |
| providers | independent_mode | `1` (enabled) or `0` (disabled) |
| providers | booking_fee | `50` |
| providers | tax_percent | `5` |

### User App Files

| File | Purpose |
|------|---------|
| `lib/feature/checkout/controller/checkout_controller.dart` | Fetches & applies restrictions (line 519-640) |
| `lib/feature/checkout/repo/checkout_repo.dart` | API call implementation |
| `lib/feature/checkout/widget/new_payment_method_selection.dart` | UI display (filtered lists) |

---

## API Endpoints

### Get Provider Payment Config
```
GET /api/v1/client/setup/payment-config?provider_id={UUID}

Query Parameters:
- provider_id (optional): Provider UUID

Response:
{
  "response_code": "default_200",
  "content": {
    "provider_id": "uuid",
    "independent_mode": 1,
    "payment_gateways": [...],
    "cash_after_service": 1,
    "digital_payment": 1,
    "wallet_payment": 1,
    "offline_payment": 0,
    "booking_additional_charge": 1,
    "additional_charge_fee_amount": 50,
    "provider_tax_percent": 5
  }
}
```

### Place Booking
```
POST /api/v1/client/order/submission/transmit

Body:
{
  "payment_method": "stripe",  # Must be in provider's allowed list
  "provider_id": "uuid",
  "zone_id": "uuid",
  ...
}

# Backend validates: providerRejectsPaymentMethod()
# Returns 400 if payment_method NOT in allowed_payment_methods
```

---

## Helper Functions (Backend)

```php
// Check if provider uses independent settings
providerIsIndependent($provider): bool

// Get allowed methods array
providerAllowedPaymentMethods($provider): ?array
// Returns: ["cash_after_service", "stripe", "razorpay"]
// Returns: null if no restrictions

// Check single method
providerAllowsPaymentMethod($provider, "stripe"): bool
// Returns: true/false

// Filter gateway list
filterPaymentGatewaysForProvider($gateways, $provider): array
// Removes gateways NOT in allowed_payment_methods

// Get provider-specific fee (or null for global)
providerBookingFee($provider): ?float

// Get provider-specific tax (or null for global)
providerEffectiveTaxPercent($provider, $globalTax): float
```

---

## Common Issues & Fixes

### ❌ Problem: All payment methods hidden in user app

**Check 1**: Independent mode disabled?
```sql
SELECT independent_mode FROM providers WHERE id='UUID';
# Should be: 1 (not 0)
```

**Check 2**: No methods selected?
```sql
SELECT allowed_payment_methods FROM providers WHERE id='UUID';
# Should be: ["cash_after_service", ...] (not empty, not null)
```

**Check 3**: Global payment disabled?
```sql
SELECT live_values FROM business_settings 
WHERE key='cash_after_service' AND settings_type='service_setup';
# Should be: 1 (enabled)
```

### ❌ Problem: Wrong methods showing

**Check 1**: Admin wizard selections
```
Admin Panel → Edit Provider → Scroll to "Allowed Payment Gateways"
Verify checkboxes match what you expect
```

**Check 2**: API response
```bash
curl "https://api/v1/client/setup/payment-config?provider_id=UUID"
Check: payment_gateways array contains expected items
```

### ❌ Problem: Booking accepted but payment method not allowed

**Check 1**: Backend validation missing
```php
# In booking controller, verify:
providerRejectsPaymentMethod($provider_id, $payment_method)
# Should reject if not in allowed list
```

**Check 2**: Method was removed after booking started
- User started booking when method was allowed
- Admin changed settings mid-booking
- User still tries old method
→ Refresh payment config during booking

---

## Testing Commands

### Database Queries
```sql
-- Check provider setup
SELECT id, company_name, independent_mode, 
       allowed_payment_methods, booking_fee 
FROM providers 
WHERE company_name LIKE '%ABC%';

-- Check what's stored
SELECT id, allowed_payment_methods 
FROM providers 
WHERE id='specific-uuid';

-- Decode JSON (MySQL 5.7+)
SELECT id, 
       JSON_EXTRACT(allowed_payment_methods, '$[0]') as first_method,
       JSON_LENGTH(allowed_payment_methods) as method_count
FROM providers;
```

### API Testing
```bash
# Test payment config API
curl -X GET \
  'https://your-domain.com/api/v1/client/setup/payment-config?provider_id=abc123def456' \
  -H 'Accept: application/json' | jq .

# Save response to file for inspection
curl -X GET \
  'https://your-domain.com/api/v1/client/setup/payment-config?provider_id=abc123def456' \
  -H 'Accept: application/json' | jq . > payment_config.json

# Check specific field
cat payment_config.json | jq .content.payment_gateways
```

### User App Testing
```
1. Open User App
2. Adb logcat to see:
   - fetchProviderPaymentConfig calls
   - API response logging
   - _applyProviderPaymentRestrictions execution
```

---

## Production Checklist

Before deploying to production:

- [ ] All providers have independent_mode configured (0 or 1)
- [ ] Providers with independent_mode=1 have allowed_payment_methods set
- [ ] At least one digital gateway is active in addon_settings
- [ ] Global payment toggles are correctly set in business_settings
- [ ] API endpoint tested with all provider_ids
- [ ] User app tested with multiple provider scenarios
- [ ] Booking submission validates payment method
- [ ] Fees and taxes calculated correctly
- [ ] Database backups created
- [ ] Rollback plan documented

---

## Support Resources

**Documentation**:
- COMPLETE_PAYMENT_FLOW_WITH_PROVIDER_RESTRICTIONS.md - Full flow diagram
- PAYMENT_FLOW_TESTING_GUIDE.md - Comprehensive testing steps
- This file - Quick reference

**Key Files to Review**:
1. Backend: `ConfigController.php` (API implementation)
2. Backend: `ProviderController.php` (Save logic)
3. App: `checkout_controller.dart` (Fetch & apply logic)
4. Database: `providers` table (Storage)
