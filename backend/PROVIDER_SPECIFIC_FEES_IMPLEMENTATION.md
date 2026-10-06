# PROVIDER-SPECIFIC COMMISSION & BOOKING FEES

## What We're Building

Instead of global admin commission/booking fees, **each provider has their own**:
- Admin Commission %: Different for each provider (e.g., Provider A = 15%, Provider B = 20%)
- Booking Fee ₹: Different for each provider (e.g., Provider A = ₹30, Provider B = ₹50)

Everything managed from: `/admin/provider/edit/{provider-id}`

---

## DATABASE CHANGES

### Add to `providers` table:

```sql
ALTER TABLE providers ADD COLUMN booking_fee DECIMAL(10, 2) DEFAULT 0;
ALTER TABLE providers RENAME COLUMN commission_percentage TO admin_commission_percentage;
```

**Or run migration:**
```bash
php artisan migrate --path=Modules/ProviderManagement/Database/Migrations/2026_10_05_add_provider_booking_fee.php
```

---

## MODEL UPDATE

### File: `Modules/ProviderManagement/Entities/Provider.php`

Add to `$fillable`:
```php
protected $fillable = [
    'admin_commission_percentage',  // renamed from commission_percentage
    'booking_fee',                   // NEW
    // ... other fields
];
```

Update `$casts`:
```php
protected $casts = [
    'admin_commission_percentage' => 'float',  // renamed
    'booking_fee' => 'float',                   // NEW
    // ... other casts
];
```

---

## PROVIDER EDIT PAGE UPDATE

### File: `Modules/ProviderManagement/Resources/views/admin/provider/edit.blade.php`

Add these fields in the form (in Step 2 or Step 5):

```blade
<div class="row g-3">
    <div class="col-md-6">
        <div class="form-floating form-floating__icon">
            <input type="number" 
                   class="form-control" 
                   name="admin_commission_percentage" 
                   id="admin_commission_percentage"
                   step="0.01"
                   min="0" 
                   max="100"
                   placeholder="Commission %" 
                   value="{{ $provider->admin_commission_percentage ?? 0 }}"
                   required>
            <label>Admin Commission (%) *</label>
            <span class="material-icons">percent</span>
        </div>
        <small class="text-muted d-block mt-1">
            {{ translate('This % will be cut from service price and given to admin') }}
        </small>
    </div>
    
    <div class="col-md-6">
        <div class="form-floating form-floating__icon">
            <input type="number" 
                   class="form-control" 
                   name="booking_fee" 
                   id="booking_fee"
                   step="0.01"
                   min="0" 
                   placeholder="Booking Fee ₹" 
                   value="{{ $provider->booking_fee ?? 0 }}"
                   required>
            <label>Booking Fee (₹) *</label>
            <span class="material-icons">attach_money</span>
        </div>
        <small class="text-muted d-block mt-1">
            {{ translate('Flat fee charged per booking (given to admin)') }}
        </small>
    </div>
</div>
```

---

## CONTROLLER UPDATE

### File: `Modules/ProviderManagement/Http/Controllers/Web/Admin/ProviderController.php`

In `update()` method, add to validation:

```php
$validator = Validator::make($request->all(), [
    // ... existing rules
    'admin_commission_percentage' => 'nullable|numeric|min:0|max:100',
    'booking_fee' => 'nullable|numeric|min:0',
]);

// In the update section:
$provider->admin_commission_percentage = $request->input('admin_commission_percentage', 0);
$provider->booking_fee = $request->input('booking_fee', 0);
```

---

## PAYMENT CALCULATION UPDATE

### File: `app/Lib/Helpers.php` or `Modules/BookingModule/Services/BookingService.php`

Replace global commission with provider-specific:

**Before (Global)**:
```php
$adminCommission = ($servicePrice * config('settings.admin_commission')) / 100;
$bookingFee = config('settings.booking_fee');
```

**After (Provider-Specific)**:
```php
$provider = $booking->provider;
$adminCommissionPercent = $provider->admin_commission_percentage ?? 0;
$bookingFee = $provider->booking_fee ?? 0;

$adminCommission = ($servicePrice * $adminCommissionPercent) / 100;
$totalAdminEarning = $adminCommission + $bookingFee + $tax;
$providerEarning = $servicePrice - $adminCommission;
```

---

## PAYMENT CALCULATION EXAMPLE

**With Provider-Specific Fees:**

```
Service Price: ₹2,500

For Provider A (Commission=15%, Fee=₹30):
  Admin Commission: ₹2,500 × 15% = ₹375
  Booking Fee: ₹30
  Service Tax: ₹450 (18%)
  ───────────────────────
  Admin Total: ₹375 + ₹30 + ₹450 = ₹855
  Provider Earning: ₹2,500 - ₹375 = ₹2,125
  Customer Pays: ₹2,500 + ₹450 + ₹30 = ₹2,980

For Provider B (Commission=20%, Fee=₹50):
  Admin Commission: ₹2,500 × 20% = ₹500
  Booking Fee: ₹50
  Service Tax: ₹450 (18%)
  ───────────────────────
  Admin Total: ₹500 + ₹50 + ₹450 = ₹1,000
  Provider Earning: ₹2,500 - ₹500 = ₹2,000
  Customer Pays: ₹2,500 + ₹450 + ₹50 = ₹3,000
```

---

## API UPDATE

### File: `Modules/BookingModule/Http/Controllers/Api/V1/Customer/BookingController.php`

When creating booking, calculate fees from provider:

```php
public function store(Request $request)
{
    // ... validation
    
    $service = Service::find($request->service_id);
    $provider = $service->providers()->first(); // or find assigned provider
    
    $servicePrice = $service->price;
    $tax = ($servicePrice * $service->tax) / 100;
    $adminCommissionPercent = $provider->admin_commission_percentage ?? 0;
    $bookingFee = $provider->booking_fee ?? 0;
    $adminCommission = ($servicePrice * $adminCommissionPercent) / 100;
    
    $totalAmount = $servicePrice + $tax + $bookingFee;
    
    $booking = Booking::create([
        'user_id' => auth()->id(),
        'provider_id' => $provider->id,
        'service_id' => $service->id,
        'total_amount' => $totalAmount,
        'service_price' => $servicePrice,
        'tax_amount' => $tax,
        'booking_fee' => $bookingFee,
        'admin_commission' => $adminCommission,
        // ... other fields
    ]);
    
    return response()->json([
        'booking_id' => $booking->id,
        'total_amount' => $totalAmount,
        'breakdown' => [
            'service_price' => $servicePrice,
            'tax' => $tax,
            'booking_fee' => $bookingFee,
            'admin_commission' => $adminCommission,
        ]
    ]);
}
```

---

## WHAT EACH APP SEES NOW

### User App - Checkout
```
Service: Full Home Cleaning
Price: ₹2,500
Tax (18%): ₹450
Booking Fee (Provider A): ₹30   ← Provider-specific!
────────────────────────────
Total Due: ₹2,980
```

### Provider App - Booking Details
```
Booking #NE384921
Service: Full Home Cleaning

Service Price: ₹2,500
Your Commission %: 15%          ← Provider-specific
Admin Cut (15%): ₹375
Your Earning: ₹2,125            ← Reflects custom commission
Booking Fee (Your Setting): ₹30
Customer Total Paid: ₹2,980
```

### Serviceman App - Job Details
```
(No change - still just sees job)
```

### Admin Panel - Booking View
```
Provider: Provider A
Service Price: ₹2,500
Provider Commission (15%): ₹375   ← Provider-specific
Provider Earning: ₹2,125
Booking Fee: ₹30                  ← Provider-specific
Admin Revenue: ₹375 + ₹30 = ₹405
Tax: ₹450
Admin Total: ₹855
```

---

## STEPS TO IMPLEMENT

1. **Database**: Run migration OR manually add columns
   ```sql
   ALTER TABLE providers ADD booking_fee DECIMAL(10,2) DEFAULT 0;
   ```

2. **Model**: Update `Provider.php` fillable and casts

3. **UI**: Add fields to provider edit page

4. **Controller**: Update validation and assignment

5. **Payment Logic**: Update calculation to use `$provider->admin_commission_percentage` and `$provider->booking_fee`

6. **All 3 Apps**: Update booking display to show provider-specific fees

---

## BENEFITS

✅ Each provider has custom commission rates
✅ Each provider has custom booking fees
✅ All managed from admin provider edit page
✅ Automatic calculation in payment processing
✅ Visible to all stakeholders (customer, provider, serviceman, admin)
✅ Stored in booking transaction for audit trail

