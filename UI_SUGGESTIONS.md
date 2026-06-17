# Bizzly — UI/UX Suggestion Guide

> **Maqsad:** Ye file ek living reference hai. Jab bhi kisi naye API section pe kaam karo, pehle yahan dekho ke us feature ki screen kahan rakhi jaani chahiye, kya navigation hogi, aur kya UX rules follow karne hain.

---

## App Structure Overview

```
Bottom Nav Bar (existing):
  Home | Businesses | Customers | Vendors | Team | Tasks | Assets

New Accounting Nav / Drawer Section (add karna hoga):
  Vouchers | Chart of Accounts | Ledger | Reports

Settings Screen:
  Accounting Periods | Business Team (Roles) | Profile | App Settings
```

> **Note:** Invoices, Expenses, aur Categories endpoints deprecated ho gaye hain (backend 404 return karta hai). In screens ko app se remove/hide karo.

---

## 1. Chart of Accounts

**API:** `GET/POST /api/chart-of-accounts` | `GET /api/dropdowns/chart-of-accounts`

### Kahan rakho
- Bottom nav ya side drawer mein **"Accounts"** tab — Vouchers ke saath group karo (Accounting section).
- Settings mein nahi — ye daily use ka feature hai.

### Screen Structure

```
Chart of Accounts Screen
├── Search bar (filter by name/nature)
├── Filter chips: All | Asset | Liability | Equity | Income | Expense
├── Hierarchical list (Level 1 > Level 2 > Level 3)
│   ├── L1: Top-level (e.g., Assets, Liabilities) — read-only, non-tappable header
│   ├── L2: Category (e.g., Current Assets) — expandable, read-only
│   └── L3: Actual account (e.g., Cash, Bank) — tappable
│       └── Tap → Account Detail Screen
└── FAB (+) → Create Account (sirf L3 private accounts ban sakte hain)
```

### Create Account Screen
- Fields: `account_name`, `parent_id` (L2 parent dropdown — `/api/dropdowns/chart-of-accounts` se)
- **Rule:** User sirf private L3 accounts bana sakta hai. Global L1/L2 accounts edit nahi ho sakte (403 aata hai — negative test confirmed).

### Account Detail Screen
- Account name, code, nature, level, balance
- "Edit" button sirf private accounts pe dikhao (global pe hide karo)
- Linked Ledger entries ka shortcut button

---

## 2. Accounting Periods

**API:** `GET /api/accounting-periods` | `GET /api/accounting-periods/current`
**Admin only:** `POST /api/accounting-periods` | `/close` | `/reopen`

### Kahan rakho
- **Settings → Accounting Periods**
- Regular user ko sirf "Current Period" info dikhao (read-only banner/card)
- Admin user ko full management screen dikhao

### Screen Structure

```
Settings → Accounting Periods
├── Current Period Card (top) — name, start_date, end_date, status
├── All Periods List
│   └── Each: name | date range | status chip (Open/Closed)
└── FAB (+) → Create Period  [Admin only — hide for non-admin]

Period Card Actions (Admin only):
  [Close Period] or [Reopen Period] button based on current status
```

### UX Rules
- **Owner/Accountant** ke liye ye screen read-only honi chahiye (sirf current period dekhein).
- **Platform Admin** ke liye create/close/reopen actions dikhao.
- Period close hone ke baad vouchers us period mein post nahi ho sakte — ye warning voucher creation screen pe bhi dikhao.

---

## 3. Business Team (Accounting Roles)

**API:** `GET/POST /api/team-members` | `GET/POST /api/team-members/:id`

### Ye `/api/employees` se ALAG hai
| Feature | `/api/employees` | `/api/team-members` |
|---|---|---|
| Purpose | HR record (salary, role, address) | App access with accounting role |
| Has login? | No | Yes (email + password) |
| Roles | Job title (free text) | `accountant` / `approver` |
| Screen | Team screen (existing) | Settings → Business Team |

### Kahan rakho
- **Settings → Business Team** (existing Team screen se alag rakho)
- Ya existing Team screen mein **"App Users"** tab alag se banao

### Screen Structure

```
Settings → Business Team
├── Team Members List
│   └── Each: name | role chip (Accountant/Approver) | status (active/inactive)
├── FAB (+) → Add Team Member

Add Team Member Screen:
  Fields:
    - Name
    - Email (login email hoga)
    - Password (temporary)
    - Phone
    - Accounting Role: [Accountant] [Approver]  ← toggle/radio
    - Create Employee Record: Yes/No toggle
    - Business (dropdown — business_id)
```

### Role Permissions (UI mein enforce karo)
| Action | Owner | Approver | Accountant |
|---|---|---|---|
| Create Voucher | ✅ | ✅ | ✅ |
| Submit Voucher | ✅ | ✅ | ✅ |
| Approve Voucher | ✅ | ✅ | ❌ |
| Close Period | ❌ | ❌ | ❌ (Admin only) |
| Edit Global CoA | ❌ | ❌ | ❌ (Admin only) |

---

## 4. Vouchers

**API:** `GET/POST /api/vouchers` | `POST /api/vouchers/:id/submit` | `/approve` | `/reject`
**Pending:** `GET /api/vouchers/pending-approvals`

### Kahan rakho
- **Bottom Nav / Drawer → "Vouchers"** — ye app ka core accounting feature hai
- Dashboard pe "Pending Approvals" badge/card bhi dikhao

### Voucher Types
| Type | Use Case |
|---|---|
| `receipt` | Cash/bank mein paisa aaya |
| `payment` | Cash/bank se paisa gaya |
| `journal` | General accounting entry |
| `contra` | Cash ↔ Bank transfer |
| `adjustment` | Correction/adjustment entry |

### Screen Structure

```
Vouchers Screen
├── Filter bar: All | Receipt | Payment | Journal | Contra | Adjustment
├── Status tabs: Draft | Submitted | Approved | Rejected
├── Search + Date range filter
├── Voucher List
│   └── Each card: voucher_type chip | date | narration | total amount | status chip
└── FAB (+) → Create Voucher

Voucher Detail Screen:
├── Header: type, date, narration, status
├── Lines table: Account | Debit | Credit
├── Total row (Debit = Credit — balanced)
├── CRM links (customer/vendor/employee if attached)
└── Action buttons (based on status + role):
    Draft    → [Edit] [Submit] [Delete]
    Submitted→ [Approve] [Reject]  (Owner/Approver only)
    Rejected → [Edit to redraft] 
    Approved → (no actions — read only)
```

### Create Voucher Screen
```
Create Voucher
├── Voucher Type selector (chips/dropdown)
├── Date picker
├── Narration field
├── Lines section:
│   ├── Line 1: [Account dropdown] [Debit/Credit toggle] [Amount]
│   ├── Line 2: ...
│   ├── [+ Add Line] button
│   └── Balance indicator: Debit Total vs Credit Total
│       - Green = balanced ✅
│       - Red = unbalanced ❌ (submit block karo)
├── CRM Link (optional): Link to Customer/Vendor/Employee
└── [Save Draft] [Save & Submit] buttons
```

### UX Rules
- Submit button tab tak disable rakho jab tak debit ≠ credit (422 prevent karo frontend pe).
- "Pending Approvals" screen sirf Owner/Approver ko dikhao — Accountant ke liye hide.
- Approved voucher edit nahi ho sakta — Edit button hide karo (403 prevent).

---

## 5. Ledger

**API:** `GET /api/ledger` | `GET /api/ledger/:id` | `GET /api/ledger/account/:account_id`

### Kahan rakho
- **Chart of Accounts → Account Detail → "View Ledger"** button
- Ya **Reports** section mein "Account Ledger" option ke tor pe
- Standalone bottom nav item banana zaroori nahi

### Screen Structure

```
Account Ledger Screen  (ledger/account/:id)
├── Account name + code header
├── Date range filter
├── Entries list:
│   └── Each: date | narration | debit | credit | running balance
├── Summary footer: Opening Balance | Total Debit | Total Credit | Closing Balance
```

### UX Rules
- Ledger read-only screen hai — koi edit/delete nahi.
- Voucher number pe tap karo to linked Voucher Detail Screen pe jao.

---

## 6. Reports

**API:**
- `GET /api/reports/trial-balance?from_date=&to_date=`
- `GET /api/reports/income-statement?from_date=&to_date=`
- `GET /api/reports/balance-sheet?as_of_date=`
- `GET /api/dashboard`

### Kahan rakho
- **Bottom Nav / Drawer → "Reports"** — existing balance sheet screen ko yahan move karo
- Dashboard existing hi rehne do (`/api/dashboard` already connected hai)

### Screen Structure

```
Reports Screen
├── Report type list / tabs:
│   ├── Trial Balance
│   ├── Income Statement
│   ├── Balance Sheet
│   └── (Future: Cash Flow)

Trial Balance Screen:
├── Date range picker (from_date, to_date)
├── [Generate] button
└── Table: Account | Debit | Credit

Income Statement Screen:
├── Date range picker
├── [Generate] button
└── Sections: Revenue | Expenses | Net Profit

Balance Sheet Screen:
├── As-of date picker (single date)
├── [Generate] button
└── Sections: Assets | Liabilities | Equity
```

### UX Rules
- Reports generate hone tak loading state dikhao.
- PDF export button add karo (existing `expensePdf` pattern follow kar sakte ho).
- Business filter (`?business_id=`) — multi-business users ke liye business picker dikhao.

---

## 7. Deprecated — Remove/Hide Karo

Ye endpoints backend pe 404 return karte hain. Inki screens app se hatao ya gracefully hide karo:

| Feature | Old Endpoint | Action |
|---|---|---|
| Invoices | `/api/invoices` | Screen remove/hide |
| Expenses | `/api/expenses` | Screen remove/hide |
| Categories | `/api/categories` | Screen remove/hide |
| Expense Dropdown | `/api/dropdowns/categories` | Remove from code |

---

## 8. Navigation Architecture (Final Suggested)

```
Bottom Navigation Bar (5 items):
  [Home] [Vouchers] [Accounts] [Reports] [More]

"More" drawer / screen:
  CRM: Customers | Vendors | Team (HR) | Tasks | Assets
  Accounting: Chart of Accounts | Ledger | Accounting Periods
  Settings: Business Team | Profile | App Settings
```

> **Why Vouchers in bottom nav?** Ye daily use ka feature hoga — accountant har roz vouchers banayega. Direct access zaroori hai.

---

## 9. Role-Based UI Visibility Summary

| Screen / Action | Platform Admin | Owner | Approver | Accountant |
|---|---|---|---|---|
| Create/Close Accounting Period | ✅ | ❌ | ❌ | ❌ |
| Edit Global CoA (L1/L2) | ✅ | ❌ | ❌ | ❌ |
| Create Private CoA (L3) | ❌ | ✅ | ✅ | ✅ |
| Create/Edit Voucher | ✅ | ✅ | ✅ | ✅ |
| Submit Voucher | ✅ | ✅ | ✅ | ✅ |
| Approve/Reject Voucher | ✅ | ✅ | ✅ | ❌ |
| Pending Approvals screen | ✅ | ✅ | ✅ | ❌ (hide) |
| Add Business Team Member | ✅ | ✅ | ❌ | ❌ |
| View Reports | ✅ | ✅ | ✅ | ✅ |

---

## 10. Quick API Reference (New Endpoints)

| Feature | Method | Endpoint |
|---|---|---|
| List CoA | GET | `/api/chart-of-accounts?level=&nature=&search=` |
| CoA Dropdown | GET | `/api/dropdowns/chart-of-accounts` |
| Create L3 Account | POST | `/api/chart-of-accounts` |
| Current Period | GET | `/api/accounting-periods/current` |
| List Periods | GET | `/api/accounting-periods` |
| Create Period | POST | `/api/accounting-periods` |
| Close Period | POST | `/api/accounting-periods/:id/close` |
| List Team Members | GET | `/api/team-members` |
| Create Team Member | POST | `/api/team-members` |
| List Vouchers | GET | `/api/vouchers?voucher_type=&status=&from_date=&to_date=` |
| Create Voucher | POST | `/api/vouchers` |
| Submit Voucher | POST | `/api/vouchers/:id/submit` |
| Approve Voucher | POST | `/api/vouchers/:id/approve` |
| Reject Voucher | POST | `/api/vouchers/:id/reject` |
| Pending Approvals | GET | `/api/vouchers/pending-approvals` |
| Account Ledger | GET | `/api/ledger/account/:account_id` |
| Trial Balance | GET | `/api/reports/trial-balance?from_date=&to_date=` |
| Income Statement | GET | `/api/reports/income-statement?from_date=&to_date=` |
| Balance Sheet | GET | `/api/reports/balance-sheet?as_of_date=` |
