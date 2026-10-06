## 🎯 ADMIN RADIUS SETTINGS - COMPLETE PATH & UPDATE GUIDE

### **BACKEND FOLDER STRUCTURE**

```
C:\Users\ijasp\OneDrive\Desktop\booking apk\Demandium v3.7\1\backend\
└── Modules\BusinessSettingsModule\
    ├── Http\Controllers\
    │   ├── Web\Admin\LocationSettingsController.php ← WEB PANEL
    │   └── Api\V1\Admin\LocationSettingsController.php ← API FOR MOBILE
    ├── Resources\views\admin\partials\
    │   └── location-search-settings.blade.php ← ADMIN FORM UI
    ├── Database\Migrations\
    │   └── 2024_01_15_create_search_radius_settings_table.php
    └── Routes\
        └── web.php & api.php (routes defined)
```

---

## **🌐 ADMIN PANEL ACCESS**

**URL:** `https://admin.yourdomain.com/admin/business-settings`

**Path:** Business Settings → App Settings → **Location Search** Tab

---

## **📋 SETTINGS FIELDS**

| Field | Type | Default | Range | Purpose |
|-------|------|---------|-------|---------|
| **Initial Radius** | number | 5 km | 1-100 km | Starting search radius |
| **Max Radius** | number | 50 km | 1-500 km | Maximum allowed radius |
| **Radius Step** | number | 5 km | 0.5-50 km | Increment per expansion |
| **Max Attempts** | integer | 5 | 1-20 | How many times to expand |
| **Show Popup** | toggle | ON | ON/OFF | Enable popup when no service |
| **Zone Reminder** | toggle | ON | ON/OFF | Show reminder in new zone |

---

## **💾 DATABASE STORAGE**

**Table:** `business_settings`

**Records stored with:**
- `key_name`: initial_search_radius, max_search_radius, radius_increment_step, max_search_attempts, show_popup_on_location_change, show_zone_reminder
- `settings_type`: location_search
- `live_values`: The actual value

**Example:**
```sql
| id | key_name                      | settings_type | live_values |
|----|-------------------------------|---------------|-------------|
| 1  | initial_search_radius         | location_search | 5          |
| 2  | max_search_radius             | location_search | 50         |
| 3  | radius_increment_step         | location_search | 5          |
| 4  | max_search_attempts           | location_search | 5          |
| 5  | show_popup_on_location_change | location_search | 1          |
| 6  | show_zone_reminder            | location_search | 1          |
```

---

## **🔌 API ENDPOINTS**

### **1. GET - Fetch Current Settings**
```
GET /api/v1/admin/business-settings/location/search-radius
Authorization: Bearer {admin_token}
```

**Response:**
```json
{
  "response_code": "default_200",
  "message": "Settings retrieved successfully",
  "content": {
    "initial_radius": 5,
    "max_radius": 50,
    "radius_increment_step": 5,
    "max_search_attempts": 5
  }
}
```

### **2. PUT - Update Settings**
```
PUT /api/v1/admin/business-settings/location/search-radius
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "initial_radius": 5,
  "max_radius": 50,
  "radius_increment_step": 5,
  "max_search_attempts": 5,
  "show_popup_on_location_change": true,
  "show_zone_reminder": true
}
```

**Response:**
```json
{
  "response_code": "default_200",
  "message": "Settings updated successfully"
}
```

---

## **📱 FLUTTER APP - HOW IT FETCHES SETTINGS**

**File:** `lib/feature/location/controller/radius_search_controller.dart`

```dart
Future<void> _loadSettings() async {
  try {
    final response = await apiClient.get(
      '${AppConstants.apiBaseUrl}/admin/business-settings/location/search-radius',
      headers: {'Authorization': 'Bearer $token'}
    );
    
    // Parse settings from response.content
    initialRadius = response['content']['initial_radius'];
    maxRadius = response['content']['max_radius'];
    radiusStep = response['content']['radius_increment_step'];
    maxAttempts = response['content']['max_search_attempts'];
    
    update(); // Update UI with new values
  } catch (e) {
    print('Error loading settings: $e');
  }
}
```

---

## **🔄 UPDATE FLOW - STEP BY STEP**

### **Admin Updates Settings:**
1. Admin logs in → Business Settings → App Settings → Location Search tab
2. Admin changes values (e.g., Initial Radius: 10 km)
3. Admin clicks "Update Settings"
4. Form sends PUT request to `/api/v1/admin/business-settings/location/search-radius`
5. Backend updates `business_settings` table
6. Database records updated

### **App Fetches Updated Settings:**
1. App opens home screen
2. `RadiusSearchController.checkAvailabilityAndPrompt()` runs
3. Calls `_loadSettings()` → API request
4. Gets latest values from database
5. Uses new radius values for search
6. **Popup shows with updated settings** ✅

---

## **🎯 EXAMPLE SCENARIO**

**Admin Update:**
- Changes Initial Radius from 5 km → 10 km
- Changes Max Radius from 50 km → 75 km
- Changes Step from 5 km → 10 km

**Database after update:**
```sql
initial_search_radius = 10
max_search_radius = 75
radius_increment_step = 10
max_search_attempts = 5
```

**User Experience (next time app opens):**
1. App fetches new settings from API
2. User opens home → No service in 10 km zone
3. Popup shows: "Search in 20 km?" (10 + 10 step)
4. User clicks → Searches 20 km → Then 30 km → Then 40 km
5. Max 5 attempts reached with new values ✅

---

## **⚠️ IMPORTANT NOTES**

1. **Admin must save settings** - Without update button click, values don't change
2. **API requires admin token** - Only authenticated admins can update
3. **Settings are cached** - App fetches fresh on each startup or manual refresh
4. **Validation rules enforced:**
   - max_radius must be ≥ initial_radius
   - initial_radius: 1-100 km
   - max_radius: 1-500 km
   - radius_step: 0.5-50 km
   - max_attempts: 1-20

---

## **📁 FILES TO MODIFY IF NEEDED**

| File | Purpose | Changes |
|------|---------|---------|
| `LocationSettingsController.php` (Web) | Admin panel logic | Add/change fields |
| `LocationSettingsController.php` (API) | Mobile API logic | API validation, response |
| `location-search-settings.blade.php` | Admin form UI | Add new input fields |
| `radius_search_controller.dart` | Mobile app logic | Load & use settings |

---

## **✅ TESTING UPDATE**

1. **Change admin setting:** Initial Radius = 15 km
2. **Check database:** `SELECT * FROM business_settings WHERE key_name = 'initial_search_radius'`
3. **Make API call (Postman):**
   ```
   GET /api/v1/admin/business-settings/location/search-radius
   ```
4. **Response should show:** `initial_radius: 15`
5. **Open app:** Popup should use 15 km as starting radius

---

## **🚀 SUMMARY**

| Component | Location | How Update Works |
|-----------|----------|------------------|
| **Admin Panel** | `/admin/business-settings` → Location Search | Form → PUT API → Database |
| **API Endpoints** | `/api/v1/admin/business-settings/location/search-radius` | GET/PUT |
| **Database** | `business_settings` table | Updates stored with key_name |
| **Flutter App** | `RadiusSearchController` | Fetches API → Uses new values |
| **User Sees** | Radius popup on home screen | Updated radius values |

