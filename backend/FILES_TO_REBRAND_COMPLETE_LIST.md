# 🔍 FILES WITH "JASS" / "DEMANDIUM" REFERENCES

## Found Files (Need to Change)

### 1. **AI Module**
```
Modules/AI/PromptTemplates/ProductVariationSetup.php:28
"You are a Jass Booking booking service variation expert."
→ Change to: "YOVO booking service variation expert"
```

### 2. **BusinessSettingsModule - Invoice Template**
```
Modules/BusinessSettingsModule/Resources/views/admin/partials/invoice.blade.php:22
"support@jassbooking.com"
→ Change to: "support@yovo.com"

Modules/BusinessSettingsModule/Resources/views/admin/partials/invoice.blade.php:94
"All rights reserved By @JassBooking 2024"
→ Change to: "All rights reserved By YOVO 2024"
```

### 3. **BusinessSettingsModule - Configuration**
```
Modules/BusinessSettingsModule/Resources/views/admin/third-party.blade.php:650,662,1385
"https://JassBooking.6amtech.com/customer/auth/login/google/callback"
→ Change to: "https://yovo.6amtech.com/customer/auth/login/google/callback"
(or your actual domain)
```

### 4. **CustomerModule - API Headers**
```
Modules/CustomerModule/Http/Controllers/Api/V1/Customer/ConfigController.php:344,390,464,562
'User-Agent' => 'JassBookingServiceApp/1.0'
→ Change to: 'User-Agent' => 'YOVOServiceApp/1.0'
```

### 5. **ServicemanModule - API Headers**
```
Modules/ServicemanModule/Http/Controllers/Api/V1/Serviceman/ConfigController.php:167,213,287,385
'User-Agent' => 'JassBookingServiceApp/1.0'
→ Change to: 'User-Agent' => 'YOVOWorkerApp/1.0'
```

---

## SUMMARY: Files to Edit

| File | Line(s) | Change | Priority |
|------|---------|--------|----------|
| ProductVariationSetup.php | 28 | Jass → YOVO | Low |
| invoice.blade.php | 22, 94 | JassBooking → YOVO | High |
| third-party.blade.php | 650, 662, 1385 | JassBooking → YOVO | High |
| ConfigController.php (Customer) | 344, 390, 464, 562 | JassBooking → YOVO | Medium |
| ConfigController.php (Serviceman) | 167, 213, 287, 385 | JassBooking → YOVO | Medium |

---

## NO CHANGES NEEDED IN:

✅ These are SAFE - don't change:
- All namespaces (stay as is)
- All class names (stay as is)
- All database table names (stay as is)
- All route names (stay as is)
- All controller names (stay as is)
- All model names (stay as is)
- Module folder structure (stay as is)

---

## SAFE TO CHANGE:

✅ These can change (user-facing strings):
- String values in comments
- API headers/user agents
- Email addresses
- Domain names
- Business names in templates
- Support contact info

