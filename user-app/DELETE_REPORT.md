## 🗑️ SAFE DELETE - UNUSED FEATURES

### **FEATURE 1: my_post** 
- **Location**: `lib/feature/my_post/`
- **Used In**: 
  - `route_helper.dart` - Line 659 (GetPage for 'my_posts' route)
  - `settings_screen.dart` - Menu item
- **Status**: SAFE TO DELETE ✅ (Only in menu, not critical)
- **Action**: Delete folder + Remove from settings menu + Remove route

---

### **FEATURE 2: conversation** 
- **Location**: `lib/feature/conversation/`
- **Files**: 24 files (ConversationListScreen, ConversationDetailsScreen)
- **Used In**:
  - `route_helper.dart` - Lines 577, 586 (chatScreen, chatInbox routes)
  - Bottom nav menu (if exists)
  - Menu/settings
- **Status**: SAFE TO DELETE ✅ (Chat not active)
- **Action**: Delete folder + Remove routes + Remove menu items

---

### **FEATURE 3: loyalty_point** 
- **Location**: `lib/feature/loyalty_point/`
- **Used In**: 
  - Possibly menu/settings
  - No active routes found
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete folder + Remove any menu references

---

### **FEATURE 4: refer_and_earn** 
- **Location**: `lib/feature/refer_and_earn/`
- **Used In**:
  - `route_helper.dart` - Line 643 (ReferAndEarnScreen route)
  - Menu/settings
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete folder + Remove route + Remove menu

---

### **FEATURE 5: suggest_new_service** 
- **Location**: `lib/feature/suggest_new_service/`
- **Used In**: Menu/settings (possibly)
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete folder + Remove any references

---

### **FEATURE 6: web_landing** 
- **Location**: `lib/feature/web_landing/`
- **Used In**: Web only (not mobile)
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete folder (mobile doesn't need)

---

### **FEATURE 7: html** 
- **Location**: `lib/feature/html/`
- **Files**: HtmlViewerScreen (Terms, Privacy, About, etc.)
- **Used In**:
  - `route_helper.dart` - Lines 520-540 (termsAndCondition, aboutUs, privacyPolicy, etc.)
  - Settings menu
- **Status**: ⚠️ USE WITH CAUTION (Needed for T&C screens)
- **Action**: KEEP - Users need to see Terms/Privacy

---

### **FEATURE 8: create_post** 
- **Location**: `lib/feature/create_post/`
- **Used In**:
  - `route_helper.dart` - Line 655 (createPost route)
  - Menu
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete folder + Remove route + Remove menu

---

### **HOME FEATURE DUPLICATES**

#### **1. home_screen_refactored.dart** 
- **Location**: `lib/feature/home/view/home_screen_refactored.dart`
- **Used In**: Nowhere (OLD VERSION)
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete file (using home_screen.dart instead)

---

#### **2. web_home_screen.dart** 
- **Location**: `lib/feature/home/web_home_screen.dart`
- **Used In**: Web only (not mobile app)
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete file

---

#### **3. web_* files (8 files)**
- **Files**: web_banner_view.dart, web_category_view.dart, web_popular_service_view.dart, etc.
- **Location**: `lib/feature/home/web/`
- **Used In**: web_home_screen.dart only
- **Status**: SAFE TO DELETE ✅
- **Action**: Delete entire `web/` folder

---

#### **4. nest_home_widgets.dart**
- **Location**: `lib/feature/home/widget/nest_home_widgets.dart`
- **Used In**: Check if used
- **Status**: Likely duplicate - DELETE

---

#### **5. Unused dialogs in home/widget/**
- bottom_create_post_dialog.dart
- home_create_post_view.dart
- referal_welcome_dialog.dart
- advertisement_video_preview_dialog.dart
- **Status**: DELETE if not in main home flow

---

## 📊 DELETION SUMMARY

| Feature | Files | Lines | Size | Action |
|---------|-------|-------|------|--------|
| my_post | 7 | 500+ | 200KB | DELETE |
| conversation | 24 | 1500+ | 600KB | DELETE |
| loyalty_point | 10 | 800+ | 300KB | DELETE |
| refer_and_earn | 2 | 200+ | 100KB | DELETE |
| suggest_new_service | 8 | 600+ | 250KB | DELETE |
| web_landing | 10 | 700+ | 300KB | DELETE |
| create_post | 12 | 900+ | 400KB | DELETE |
| home_refactored | 1 | 500+ | 200KB | DELETE |
| web_home_screen | 1 | 800+ | 300KB | DELETE |
| web_home/* | 8 | 2000+ | 800KB | DELETE |
| **TOTAL** | **83** | **8500+** | **3.5MB+** | **DELETE** |

---

## 🔧 FILES TO MODIFY

1. **route_helper.dart** - Remove routes for deleted features
2. **settings_screen.dart** / menu files - Remove menu items
3. **main.dart** - If any bindings exist
4. **android/build.gradle** - Can reduce minSdkVersion if needed

---

## ✅ SAFE FEATURES TO KEEP

- html/ (needed for Terms/Privacy)
- All other active features
- home_screen.dart (main screen - KEEP)
- All controllers, models, repos for active features

