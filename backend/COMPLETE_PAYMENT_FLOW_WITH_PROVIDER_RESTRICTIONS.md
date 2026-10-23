# Complete Payment Flow with Provider Payment Restrictions

## Flow Diagram

```
ADMIN PANEL (Backend)
├─ Provider Wizard Step 4
│  ├─ Checkboxes: Allow Payment Gateways
│  ├─ Stored in: Provider.allowed_payment_methods (JSON)
│  └─ Example: ["cash_after_service", "wallet_payment", "stripe"]
│
├─ Settings: Independent Commission ON
│  ├─ Admin Commission %
│  ├─ Provider Commission %
│  ├─ Platform Fee Amount
│  ├─ Tax % per Provider
│  └─ Booking Fee per Provider
│
└─ Save to Database

BACKEND API
├─ POST /api/v1/admin/provider/update
│  ├─ Reads: allowed_payment_methods[] checkboxes
│  ├─ Encodes: json_encode(array_values(array_filter(...)))
│  ├─ Stores in: providers.allowed_payment_methods
│  └─ Validation: providerAllowedPaymentMethods() returns array or null
│
├─ GET /api/v1/client/setup/payment-config?provider_id=UUID
│  ├─ Reads: providers.allowed_payment_methods
│  ├─ Gets Global Config: business_config('cash_after_service', etc.)
│  ├─ Filters Digital Gateways: filterPaymentGatewaysForProvider()
│  ├─ Returns JSON:
│  │  ├─ provider_id
│  │  ├─ independent_mode: 1/0
│  │  ├─ payment_gateways: [filtered list]
│  │  ├─ cash_after_service: 1/0
│  │  ├─ wallet_payment: 1/0
│  │  ├─ offline_payment: 1/0
│  │  ├─ digital_payment: 1/0
│  │  ├─ booking_additional_charge: 1/0
│  │  ├─ additional_charge_fee_amount: number
│  │  └─ provider_tax_percent: number/null
│  │
│  └─ Logic:
│     ├─ If independent_mode OFF → use global settings only
│     └─ If independent_mode ON → use provider's allowed methods + global toggles

CUSTOMER APP (Flutter)
├─ Checkout Flow
│  └─ New Booking Triggered
│     ├─ Get Zone + Category + Provider ID
│     ├─ CartController has: cart.provider?.id
│     └─ Call fetchProviderPaymentConfig(provider_id)
│
├─ fetchProviderPaymentConfig(provider_id)
│  ├─ API Call: GET /api/v1/client/setup/payment-config?provider_id=UUID
│  ├─ Response: { payment_gateways: [...], cash_after_service: 1, ... }
│  ├─ Store in: _providerPaymentConfig
│  └─ Call: _applyProviderPaymentRestrictions()
│
├─ _applyProviderPaymentRestrictions()
│  ├─ Read _providerPaymentConfig flags
│  ├─ Filter _othersPaymentList:
│  │  ├─ Remove Cash if: cash_after_service != 1
│  │  └─ Remove Wallet if: wallet_payment != 1
│  ├─ Filter _digitalPaymentList:
│  │  ├─ Clear all if: digital_payment != 1
│  │  └─ Remove gateways NOT in: payment_gateways array
│  └─ Deselect if current selection no longer valid
│
├─ Payment Method Display
│  └─ NewPaymentMethodSelection Widget
│     ├─ Show _othersPaymentList (Cash, Wallet)
│     ├─ Show _digitalPaymentList (Stripe, Razorpay, etc.)
│     ├─ All items already filtered by provider restrictions
│     └─ Customer sees only ALLOWED methods for THIS provider

BOOKING PLACEMENT
├─ Customer selects payment method (now filtered correctly)
├─ API Call: POST /api/v1/client/order/submission/transmit
│  ├─ Sends: payment_method, booking details, provider_id in cart
│  └─ Backend validates: providerRejectsPaymentMethod(provider_id, method)
│
└─ Validation Check
   ├─ Backend checks: provider->allowed_payment_methods
   ├─ If method NOT in allowed list → 400 error
   └─ If valid → booking accepted
```

## Key Components

### 1. Admin Panel: Provider Wizard Step 4
**File**: `Modules/ProviderManagement/Resources/views/admin/provider/edit.blade.php` (lines 667-684)
```blade
<label>Allowed Payment Gateways</label>
<div class="border rounded p-12 bg-white">
    @foreach ($paymentGatewayOptions as $gatewayOption)
        <input type="checkbox" name="allowed_payment_methods[]"
               value="{{ $gatewayOption['key'] }}"
               @checked(in_array($gatewayOption['key'], $selectedPaymentMethods, true))>
        <span>{{ $gatewayOption['label'] }}</span>
    @endforeach
</div>
```

**Helper Functions**:
- `paymentGatewayOptions()` - Returns all available gateways (base + digital)
- `providerAllowedPaymentMethods($provider)` - Decodes JSON, returns array or null

### 2. Backend: Provider Controller Update
**File**: `Modules/ProviderManagement/Http/Controllers/Web/Admin/ProviderController.php` (line 1227)
```php
$provider->allowed_payment_methods = json_encode(
    array_values(
        array_filter((array) $request->input('allowed_payment_methods', []))
    )
);
```

### 3. Backend: Payment Config API
**File**: `Modules/CustomerModule/Http/Controllers/Api/V1/Customer/ConfigController.php` (lines ~200)
```php
public function providerPaymentConfig(Request $request): JsonResponse
{
    $provider = \Modules\ProviderManagement\Entities\Provider::find(
        $request['provider_id']
    );
    
    $payment_gateways = filterPaymentGatewaysForProvider(
        $gateways, $provider
    );
    
    return response()->json([
        'provider_id' => $provider->id,
        'independent_mode' => providerIsIndependent($provider) ? 1 : 0,
        'payment_gateways' => $payment_gateways,
        'cash_after_service' => providerAllowsPaymentMethod(
            $provider, 'cash_after_service'
        ) ? 1 : 0,
        // ... more fields
    ]);
}
```

**Helper Functions**:
- `filterPaymentGatewaysForProvider()` - Filters gateway list by allowed methods
- `providerAllowsPaymentMethod()` - Checks if method allowed for provider
- `providerIsIndependent()` - Checks if independent mode enabled
- `providerBookingFee()` - Gets provider-specific booking fee
- `providerEffectiveTaxPercent()` - Gets provider-specific tax %

### 4. User App: Checkout Controller
**File**: `userapk/lib/feature/checkout/controller/checkout_controller.dart` (lines 519-627)
```dart
void getPaymentMethodList({...}) {
    // Build payment lists from global config
    _othersPaymentList = [...];
    _digitalPaymentList = [...];
    
    // Fetch provider-specific config
    fetchProviderPaymentConfig(cartProviderId);
}

Future<void> fetchProviderPaymentConfig(String? providerId) async {
    final Response response = await checkoutRepo
        .getProviderPaymentConfig(providerId);
    _providerPaymentConfig = response.body['content'];
    
    // Apply restrictions to lists
    _applyProviderPaymentRestrictions();
}

void _applyProviderPaymentRestrictions() {
    // Read flags from _providerPaymentConfig
    if (!flag(config['cash_after_service'])) {
        _othersPaymentList.removeWhere(...);
    }
    if (!flag(config['wallet_payment'])) {
        _othersPaymentList.removeWhere(...);
    }
    // Filter digital gateways by allowed_gateways from config
    _digitalPaymentList.removeWhere((method) =>
        !allowedGateways.contains(method.gateway));
}
```

## Zone + Category + Provider Logic

- **Zone**: Determines which providers are available in that area
- **Category**: Provider must have this category assigned
- **Provider Payment Methods**: IF provider in that category + zone + has independent mode ON
  → Apply provider's allowed_payment_methods restrictions
  → Otherwise use global settings

## Troubleshooting Checklist

✅ Provider has Independent Mode ON in admin wizard
✅ Provider has at least 1 category assigned (Wizard Step 2)
✅ Provider is in the correct zone (Setup tab)
✅ Payment Gateways checkboxes checked in Wizard Step 4
✅ Global payment methods enabled: cash_after_service, wallet_payment, digital_payment
✅ Digital gateways configured and active in addon_settings
✅ User app calls: GET /api/v1/client/setup/payment-config?provider_id=UUID
✅ Response includes payment_gateways array with selected gateways
✅ User app filters lists based on returned flags
✅ Payment method selection restricted to allowed methods only
✅ Booking placement validates: providerRejectsPaymentMethod()

## API Endpoints

### Admin Endpoints
- `POST /api/v1/admin/provider/create` - Create provider with allowed_payment_methods
- `PUT /api/v1/admin/provider/{id}` - Update provider settings including gateways

### Customer Endpoints
- `GET /api/v1/client/setup/payment-config?provider_id=UUID` - Get provider config
- `POST /api/v1/client/order/submission/transmit` - Place booking (validates method)

## Database

**Table**: providers
- `allowed_payment_methods` (json) - Stores selected gateways
- `independent_mode` (tinyint) - Enable provider-specific settings
- `booking_fee` (decimal) - Provider-specific customer fee
- `tax_percent` (decimal) - Provider-specific tax %
- `admin_commission_percent` (decimal)
- `provider_commission_percent` (decimal)

**Table**: addon_settings
- `settings_type = 'payment_config'`
- `key_name` - Gateway key (stripe, razorpay, etc.)
- `live_values` - Status, credentials
- `additional_data` - gateway_title, etc.
