# 🔧 3 Issues to Fix in Checkout Flow

## Issue 1: Contact Person Name & Number Not Auto-Filling

**Problem**: When user clicks "Edit Details" in checkout, the Contact Person Name and Phone fields are empty instead of auto-filling from their account.

**Current Code**: `customer_location_info.dart` (Line ~165)
- It reads from `widget.address?.contactPersonName` 
- Falls back to `Get.find<UserController>().userInfoModel?.firstName`
- **BUT**: Usually empty on first checkout

**Solution**:
```dart
void initState() {
  super.initState();
  
  // Get logged-in user info
  final userInfo = Get.find<UserController>().userInfoModel;
  final isLoggedIn = Get.find<AuthController>().isLoggedIn();
  
  // Auto-fill NAME: Address value > User's full name > Empty
  if(widget.address?.contactPersonName?.isNotEmpty ?? false) {
    _contactPersonNameController.text = widget.address!.contactPersonName!;
  } else if(isLoggedIn && userInfo != null) {
    String fullName = "${userInfo.firstName ?? ""} ${userInfo.lastName ?? ""}".trim();
    _contactPersonNameController.text = fullName;
  }
  
  // Auto-fill PHONE: Address value > User's phone > Empty
  if(widget.address?.contactPersonNumber?.isNotEmpty ?? false) {
    _contactPersonNumberController.text = widget.address!.contactPersonNumber!;
  } else if(isLoggedIn && userInfo?.phone != null) {
    _contactPersonNumberController.text = userInfo!.phone!;
  }
}
```

---

## Issue 2: Street Address Only Shows 2 Words

**Problem**: Street field shows "Kartavya Path" (2 words) instead of full address like "Kartavya Path, Sector 5, Delhi, India"

**Current**: The `address.address` field only contains short form

**Root Cause**: Address selection from Google Places API returns incomplete data

**Solution**:
Check `customer_location_info.dart` Line 95-105 where address is displayed:
```dart
if(addressModel.address != null && addressModel.address != "" ) 
  Row(children: [
    Text( addressModel.address ?? "", maxLines: 2),
    // Currently shows: "Kartavya Path"
    // Should show: Full formatted address
  ])
```

**Fix**: Modify AddressModel to store complete address components:
- `street` - Kartavya Path
- `city` - New Delhi
- `state` - Delhi  
- `country` - India
- `zipcode` - 110004
- `address` - Full formatted: "Kartavya Path, Sector 5, New Delhi, Delhi 110004, India"

Then display as:
```dart
Text("${addressModel.street}, ${addressModel.city}, ${addressModel.state}, ${addressModel.zipcode}, ${addressModel.country}")
```

---

## Issue 3: Payment Methods Showing ALL Instead of Provider's Allowed Only

**Problem**: Payment screen shows ALL gateways (Cash, Stripe, Razorpay, Flutterwave, Paystack, Ssl Commerzet) but provider might have ONLY Stripe + Razorpay allowed.

**Current Flow**:
1. App calls: `getPaymentMethodList()` (Line 519 of checkout_controller.dart)
2. Fetches: `fetchProviderPaymentConfig(providerId)` 
3. Calls API: `GET /api/v1/client/setup/payment-config?provider_id=UUID`
4. Applies: `_applyProviderPaymentRestrictions()` (Line ~640)

**Problem**: API returns all gateways OR gateways not filtered correctly

**Debug Steps**:
```dart
// In checkout_controller.dart after fetchProviderPaymentConfig():

void _applyProviderPaymentRestrictions() {
  final config = _providerPaymentConfig;
  if (config == null) {
    // ❌ If null, no restrictions applied!
    print("⚠️ WARNING: Provider config is NULL - showing all methods");
    return;
  }
  
  print("✅ Config found for provider");
  print("Payment gateways: ${config['payment_gateways']}");
  print("Cash allowed: ${config['cash_after_service']}");
  print("Digital allowed: ${config['digital_payment']}");
  
  // ... rest of filtering
}
```

**Expected Behavior**:
- Provider has Stripe + Razorpay allowed
- API returns: `{"payment_gateways": [{"gateway": "stripe"}, {"gateway": "razorpay"}]}`
- After filtering: Only these 2 shown
- Current showing: All 6 gateways

**Solution**:
```dart
void getPaymentMethodList({bool shouldUpdate = false}) {
  // ... build initial lists ...
  
  // CRITICAL: Fetch provider config
  final String? cartProviderId = _currentCartProviderId();
  if (cartProviderId != null) {
    fetchProviderPaymentConfig(cartProviderId);  // This MUST complete before UI renders
  } else {
    print("❌ ERROR: No provider ID found in cart!");
  }
}

Future<void> fetchProviderPaymentConfig(String? providerId) async {
  try {
    print("🔄 Fetching config for provider: $providerId");
    final Response response = await checkoutRepo.getProviderPaymentConfig(providerId);
    
    if (response.statusCode == 200) {
      _providerPaymentConfig = response.body['content'];
      _providerPaymentConfigFor = providerId;
      print("✅ Config fetched: ${_providerPaymentConfig}");
    } else {
      print("❌ API Error: ${response.statusCode}");
      _providerPaymentConfig = null;
    }
  } catch (e) {
    print("❌ Exception: $e");
    _providerPaymentConfig = null;
  }
  
  _applyProviderPaymentRestrictions();
  update();
}
```

---

## Files That Need Fixing

### 1. Customer Location Info (Name & Phone Auto-Fill)
**File**: `lib/feature/checkout/widget/order_details_section/customer_location_info.dart`
**Lines**: 163-180 (initState method)
**Change**: Enhanced auto-fill logic

### 2. Address Model (Full Address Display)
**Files**: 
- `lib/feature/address/model/address_model.dart` - Add full address fields
- `lib/feature/checkout/widget/order_details_section/customer_location_info.dart` - Display correctly

### 3. Payment Methods Filtering (Provider Restrictions)
**File**: `lib/feature/checkout/controller/checkout_controller.dart`
**Lines**: 519-640
**Issue**: Check if `fetchProviderPaymentConfig()` is completing before UI renders
**Solution**: Add await/wait mechanism, add debug logging, verify API response

---

## Verification After Fixes

### Test 1: Name & Phone Auto-Fill
1. Login to app
2. Go to checkout
3. Click "Edit Details"
4. **Expected**: Name and Phone pre-filled from user account
5. **Actual Currently**: Empty fields

### Test 2: Full Address Display
1. Select address in checkout
2. **Expected**: Full address like "Kartavya Path, Sector 5, New Delhi, Delhi 110004"
3. **Actual Currently**: Only "Kartavya Path" (2 words)

### Test 3: Provider Payment Methods
1. Create provider with Stripe + Razorpay ONLY
2. Go to checkout for that provider
3. **Expected**: Only Stripe & Razorpay visible
4. **Actual Currently**: All 6 gateways (Cash, Stripe, Razorpay, Flutterwave, Paystack, Ssl Commerz)

---

## Code Changes Needed

### Change 1: Auto-Fill from User Account
```diff
- _contactPersonNameController.text = (widget.address?.contactPersonName != null && ...)
-     ? widget.address!.contactPersonName!
-     : userInfo?.firstName ?? "";
+ 
+ // Full name from account if address is empty
+ if(widget.address?.contactPersonName?.isNotEmpty ?? false) {
+   _contactPersonNameController.text = widget.address!.contactPersonName!;
+ } else if(isLoggedIn && userInfo != null) {
+   String fullName = "${userInfo.firstName ?? ""} ${userInfo.lastName ?? ""}".trim();
+   _contactPersonNameController.text = fullName;
+ }
```

### Change 2: Debug Payment Config Loading
```dart
void getPaymentMethodList({...}) {
  // ...existing code...
  
  final String? cartProviderId = _currentCartProviderId();
  print("📊 DEBUG: Cart Provider ID: $cartProviderId");
  
  if (cartProviderId != null) {
    fetchProviderPaymentConfig(cartProviderId);  // Make sure this is awaited
    print("📊 DEBUG: Config state: $_providerPaymentConfig");
  }
}
```

### Change 3: Verify API Response
```dart
Future<void> fetchProviderPaymentConfig(String? providerId) async {
  if (providerId == null) {
    print("⚠️ Provider ID is null!");
    return;
  }
  
  try {
    final Response response = await checkoutRepo.getProviderPaymentConfig(providerId);
    print("📍 API Response: ${response.body}");
    
    if (response.statusCode == 200) {
      _providerPaymentConfig = response.body['content'];
      print("✅ Payment config set: ${_providerPaymentConfig?['payment_gateways']}");
    }
  } catch (e) {
    print("❌ ERROR: $e");
  }
}
```

---

## Testing Commands

**Check Database**:
```sql
-- Verify provider's allowed payment methods
SELECT id, company_name, independent_mode, allowed_payment_methods 
FROM providers WHERE id='test-provider-id';

-- Should show: allowed_payment_methods = ["stripe","razorpay"]
```

**Check API Response**:
```bash
curl "http://localhost:8000/api/v1/client/setup/payment-config?provider_id=test-provider-id"

# Should return:
{
  "payment_gateways": [
    {"gateway": "stripe"},
    {"gateway": "razorpay"}
  ],
  ...
}
```

**Check App Logs**:
```
adb logcat | grep "DEBUG\|payment\|config"
```

---

## Status: 🔴 PENDING FIXES

All 3 issues need to be fixed. Let me know when you're ready and I'll implement all fixes immediately.
