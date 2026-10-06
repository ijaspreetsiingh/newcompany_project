# 🔍 DEMANDIUM v3.7 - CODEBASE AUDIT & CLEANUP GUIDE

## What We Need to Check

1. **Sidebar Menu Items** - Which are actually used vs dummy
2. **Database Seeders** - What unnecessary data is being seeded
3. **API Routes** - Which endpoints are dead code
4. **Controllers** - Which controllers have unused methods
5. **Blade Views** - Which templates are not being used
6. **Models** - Which relationships/methods are unnecessary
7. **Migrations** - Which tables are not being used

---

## STEP 1: FIND SIDEBAR MENU CONFIGURATION

Let me check where sidebar is defined:
