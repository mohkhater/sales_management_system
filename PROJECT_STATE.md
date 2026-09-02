# Sales Management System — Project State

> هذا الملف هو سجل الحالة والقرارات الهندسية للمشروع.
> لا يحتوي على نسخ من الكود؛ مصدر الحقيقة للكود هو Git وملفات المشروع نفسها.
>
> يجب تحديث هذا الملف عندما تتغير حالة المشروع أو يتم اتخاذ قرار هندسي مهم، وليس عند كل تغيير صغير في الكود.

---

## 1. Project Identity

**Project Name:** Sales Management System

**Commercial Name:** TBD

> الاسم التجاري العربي سيتم تحديده لاحقًا، ولا يؤثر على الاسم البرمجي أو بنية المشروع.

**Project Type:** Cross-platform Sales Management System

### Target Platforms

* Windows
* Android
* iOS
* Web

### Terminology

عندما نستخدم في المشروع مصطلح:

* **Phone**
* **Mobile**
* **الهاتف**
* **الموبايل**

فالمقصود هو **Android + iOS** معًا، وليس Android فقط.

أما **Tablet** فهو فئة مستقلة من ناحية تجربة الاستخدام، مع إمكانية مشاركة نفس منطق التطبيق.

---

# 2. Product Vision

بناء نظام مبيعات:

* سريع
* خفيف
* قوي
* سهل الاستخدام
* قابل للتوسع
* مناسب للمستخدم غير المتخصص في المحاسبة
* يدعم شاشات اللمس وأجهزة نقاط البيع
* يعمل بواجهات مناسبة لكل نوع جهاز
* لا يفرض تعقيدًا محاسبيًا غير ضروري على المستخدم

### Priorities

**Speed + Reliability + Simplicity + Usability + Maintainability**

الأولوية ليست لإضافة أكبر عدد ممكن من الخصائص، وإنما لبناء أصغر نظام قوي يحل المشكلة الحقيقية للمستخدم ويمكن تطويره لاحقًا.

---

# 3. Development Principles

## Core Rules

1. البساطة قبل التعقيد.
2. لا نضيف Package إلا لسبب واضح.
3. لا نضيف Architecture معقدة دون حاجة حقيقية.
4. لا نعتمد أي تعديل دون اختبار مناسب.
5. لا نفترض أن الكود يعمل؛ نتحقق منه فعليًا.
6. نحافظ على Git history نظيفًا.
7. التغييرات الكبيرة تُنفذ على مراحل صغيرة.
8. عند ظهور خطأ، نعالج السبب أولًا ولا نغير أجزاء غير مرتبطة.
9. لا نكسر البيانات القديمة عند تطوير النظام.
10. أي تغيير في Database Schema يجب أن يكون عبر Migration.
11. لا نحذف البيانات التاريخية المرتبطة بالمبيعات حذفًا فعليًا دون سبب قوي.
12. واجهات Desktop وMobile قد تختلف في العرض والتفاعل، لكن يجب أن تشترك في نفس منطق النظام.
13. دعم Touch جزء أساسي من التصميم وليس إضافة لاحقة.
14. الأداء مهم منذ البداية، لكن دون premature optimization.
15. أي Feature لا تضيف قيمة حقيقية للمستخدم لا تُضاف لمجرد زيادة الإمكانيات.
16. لا نعيد بناء شيء موجود بالفعل.
17. لا نعمل Upgrade للحزم بشكل عشوائي لمجرد توفر إصدارات أحدث.
18. قبل أي تغيير كبير، نتحقق من الحالة الحالية للمشروع.
19. نعمل بطريقة:
    `Change → Run → Test → Fix → Continue`
20. لا نعتبر أي قرار معماري نهائيًا لمجرد أنه تم تطبيقه؛ إذا أثبت الاختبار أو الاستخدام أن القرار غير مناسب، تتم مراجعته وتغييره مع توثيق السبب.

---

# 4. Development Workflow

لكل تغيير مهم:

```text
1. Inspect current state
2. Make one focused change
3. Run analyzer/tests
4. Fix relevant issues only
5. Verify behavior
6. Continue
7. Commit completed milestone
```

لا يتم تنفيذ عدة تغييرات كبيرة دفعة واحدة إذا كان بالإمكان تقسيمها إلى مراحل قابلة للاختبار.

عند وجود مشكلة:

```text
Observe
   ↓
Analyze
   ↓
Identify root cause
   ↓
Make focused fix
   ↓
Test
```

ولا يتم تغيير أجزاء غير مرتبطة بالمشكلة لمجرد محاولة إصلاحها.

---

# 5. Architecture Direction

الهدف هو فصل طبقات النظام بحيث لا تعتمد الواجهة مباشرة على SQL:

```text
Presentation
    ↓
Business / Application Logic
    ↓
Repository
    ↓
Data Source
```

### Goals

* سهولة الاختبار
* تقليل الترابط بين المكونات
* فصل UI عن قاعدة البيانات
* إمكانية تغيير مصدر البيانات مستقبلًا
* تسهيل دعم Web والسيناريوهات المستقبلية
* الحفاظ على Architecture بسيطة وغير مبالغ فيها

لا يتم إدخال Frameworks أو Layers إضافية إلا عندما يكون لها سبب عملي واضح.

---

# 6. Current Technology

## Flutter

```text
Flutter: 3.47.1 stable
Dart: 3.13.1
```

## Development Environment

```text
Windows 10 Pro 64-bit
```

## Flutter Path

```text
C:\Development\flutter
```

## Project Path

```text
C:\Development\projects\sales_management_system
```

## Android SDK

```text
D:\Android\Sdk
```

## JDK

```text
D:\Java\jdk-17.0.20.1+1
```

---

# 7. Supported / Tested Platforms

## Desktop

* Windows — tested

## Web

* Chrome — tested
* Edge — tested

## Mobile

* Android — tested
* iOS — target platform، ولم يتم اختباره حاليًا في بيئة التطوير الحالية

## Tablet

Tablet جزء من نطاق التصميم responsive، وسيتم التعامل معه حسب حجم الشاشة وطريقة الاستخدام.

---

# 8. Repository Status

**Git Branch:**

```text
master
```

**Last Known Commit Before Current Uncommitted Work:**

```text
388ebf3 Establish project foundation and rules
```

### Current Working Tree

يحتوي حاليًا على تغييرات غير committed مرتبطة بمرحلة SQLite وProducts، وتشمل بشكل عام:

* SQLite foundation
* Migration V1
* Product Model
* Tests
* Products-related files

يجب دائمًا تنفيذ:

```text
git status
```

قبل أي Commit للتأكد من الملفات التي سيتم تضمينها.

لا يتم Commit لملفات أو تغييرات غير مرتبطة بالـmilestone الحالي.

---

# 9. Current Project Structure

```text
lib/
├── app/
│   └── theme/
│
├── core/
│   ├── responsive/
│   └── ui/
│
├── data/
│   └── database/
│       ├── migrations/
│       │   └── migration_v1.dart
│       └── app_database.dart
│
└── features/
    └── products/
        ├── data/
        │   └── product_model.dart
        └── presentation/
            └── products_page.dart

test/
├── database_test.dart
├── product_model_test.dart
└── widget_test.dart
```

---

# 10. Database

## Technology

SQLite

## Current Packages

```text
sqflite
sqflite_common_ffi
path
```

لا تتم إضافة Package جديدة إلا عند وجود حاجة واضحة ومثبتة.

## Database File

```text
sales_management.db
```

## Current Database Version

```text
1
```

## Database Implementation

```text
lib/data/database/app_database.dart
```

## Migration

```text
lib/data/database/migrations/migration_v1.dart
```

---

# 11. Migration V1

Migration V1 تنشئ الجداول:

```text
units
products
product_units
product_barcodes
```

وتضيف حاليًا:

```text
13 default units
```

### Database Test

```text
test/database_test.dart
```

الاختبار يتحقق من:

* إنشاء قاعدة البيانات
* وجود الجداول المطلوبة
* وجود الوحدات الافتراضية

آخر نتيجة معروفة لاختبار قاعدة البيانات:

```text
PASS
```

---

# 12. Database Schema — V1

## units

```text
id              TEXT PRIMARY KEY
name            TEXT NOT NULL
symbol          TEXT
type            TEXT NOT NULL
is_active       INTEGER NOT NULL DEFAULT 1
created_at      TEXT NOT NULL
updated_at      TEXT NOT NULL
```

## products

```text
id              TEXT PRIMARY KEY
name            TEXT NOT NULL
base_unit_id    TEXT NOT NULL
category_id     TEXT
default_price   REAL NOT NULL DEFAULT 0
is_active       INTEGER NOT NULL DEFAULT 1
created_at      TEXT NOT NULL
updated_at      TEXT NOT NULL
```

Relationship:

```text
products.base_unit_id → units.id
```

## product_units

```text
id                  TEXT PRIMARY KEY
product_id          TEXT NOT NULL
unit_id             TEXT NOT NULL
conversion_to_base  REAL NOT NULL
```

Relationships:

```text
product_id → products.id
unit_id    → units.id
```

Constraint:

```text
UNIQUE(product_id, unit_id)
```

## product_barcodes

```text
id                TEXT PRIMARY KEY
product_id        TEXT NOT NULL
product_unit_id   TEXT NOT NULL
barcode           TEXT NOT NULL UNIQUE
```

Relationships:

```text
product_id      → products.id
product_unit_id → product_units.id
```

---

# 13. Product Data Model

المنتج يحتوي حاليًا على:

* Product ID
* Name
* Base Unit
* Category
* Default Price
* Active / Inactive
* Created timestamp
* Updated timestamp

## Units

المنتج له وحدة أساسية.

ويمكن أن يكون له عدة وحدات بيع.

مثال:

```text
Product:
Water 500ml

Base Unit:
Piece

Selling Unit:
Carton

Conversion:
1 Carton = 24 Pieces
```

## Barcodes

يمكن أن يكون لكل وحدة بيع Barcode مختلف.

مثال:

```text
Piece Barcode
Carton Barcode
```

---

# 14. Pricing Philosophy

سعر البيع ليس بالضرورة نتيجة حساب آلي من التكلفة.

يجب أن يستطيع المستخدم:

* تحديد سعر البيع يدويًا.
* تغيير السعر حسب السوق.
* البيع بسعر أقل من التكلفة إذا قرر ذلك.
* التعامل مع منتجات قاربت على التلف.
* التعامل مع المنافسة وتغير الأسعار.

النظام يمكن أن يقدم معلومات أو تحذيرات مناسبة، لكنه لا يمنع المستخدم من اتخاذ قرار البيع لمجرد أن السعر أقل من التكلفة.

---

# 15. Offers / Bundles Direction

النظام يجب أن يدعم لاحقًا:

* عروض البيع
* Bundles / Packages
* بيع مجموعة منتجات كسعر واحد
* عروض مرتبطة بكمية
* عروض لفترة زمنية
* أسعار خاصة للوحدات

التفاصيل النهائية لم تُنفذ بعد.

لا يتم تصميم نظام عروض معقد قبل الحاجة الفعلية إليه.

---

# 16. Data Deletion Policy

لا يتم حذف السجلات التي أصبحت جزءًا من التاريخ التشغيلي للنظام حذفًا فعليًا إذا كان ذلك سيؤثر على:

* الفواتير
* المبيعات
* التقارير
* المخزون
* العلاقات التاريخية
* أي سجل تشغيلي يعتمد عليها

يفضل استخدام:

```text
is_active
```

أو Soft Delete عند الحاجة.

الحذف الفيزيائي يستخدم فقط عندما يكون آمنًا ولا يؤثر على البيانات التاريخية.

---

# 17. UI / UX Direction

## Desktop

واجهة تستفيد من المساحة الكبيرة، مثل:

* Tables
* Side navigation
* Multiple panels
* Keyboard + Mouse

## Mobile — Android + iOS

واجهة مصممة للمس والاستخدام السريع، مثل:

* Cards
* Large touch targets
* Simplified navigation
* Floating actions عند الحاجة

لا نريد تصميم Desktop مصغرًا على الهاتف.

## Tablet

يتم استغلال المساحة المتوسطة بطريقة تختلف عن الهاتف عند الحاجة.

## POS / Touch

يجب أن تكون العناصر:

* كبيرة بما يكفي للمس
* واضحة
* سريعة الوصول
* قليلة الخطوات
* مناسبة للاستخدام المتكرر

---

# 18. Responsive Philosophy

الـResponsive ليس مجرد تغيير حجم العناصر.

قد تختلف طريقة عرض الشاشة والتفاعل حسب:

```text
Phone
Tablet
Desktop
POS
```

لكن يجب أن يبقى:

```text
Business Logic
Application Rules
Data Model
```

مشتركًا قدر الإمكان.

الاختلاف يكون أساسًا في Presentation وInteraction وليس في منطق النظام نفسه.

---

# 19. Completed Work

## Foundation

* Flutter project
* Git repository
* Basic project structure
* Responsive direction
* Initial Products screen
* Android toolchain verification
* Android device connection
* SQLite dependencies
* SQLite foundation
* Migration V1
* Database test

## Products

* Product Model
* Product Model serialization/deserialization
* Product Model test

---

# 20. Current Development Stage

## Products

### Completed

```text
Product Model              ✅
Product Model Test         ✅
```

### Next

```text
Product Repository         ⏳
```

### Planned Product Flow

```text
Product Repository
        ↓
Create Product
        ↓
Save to SQLite
        ↓
Read Products
        ↓
Display real data
        ↓
Update Product
        ↓
Activate / Deactivate
        ↓
Product Units
        ↓
Product Barcodes
        ↓
Persistence Verification
```

---

# 21. Not Started

* Sales / POS
* Cart
* Customers
* Suppliers
* Inventory
* Purchasing
* Offers
* Bundles
* Expenses
* Reports
* Users & Permissions
* Backup / Restore
* Web-specific data strategy
* Release builds
* Advanced pricing rules
* Advanced promotions

هذه العناصر ليست جزءًا من المرحلة الحالية.

---

# 22. Testing Policy

قبل اعتبار Feature مكتملة:

```text
flutter analyze
        ↓
Unit / Widget tests
        ↓
Functional test
        ↓
Platform verification
        ↓
Git commit
```

نوع الاختبار يعتمد على طبيعة الـFeature.

### Persistence

أي Feature تتعامل مع البيانات يجب اختبارها على قاعدة البيانات الفعلية، وليس فقط اختبار الكود نظريًا.

### Regression

بعد التغييرات المهمة يجب التأكد من عدم كسر الاختبارات الموجودة مسبقًا.

---

# 23. Current Verification Status

آخر حالة مؤكدة:

### Flutter Analyze

```text
No issues found!
```

### Flutter Tests

```text
00:20 +3: All tests passed!
```

الاختبارات الحالية:

```text
database_test.dart
product_model_test.dart
widget_test.dart
```

---

# 24. Known Issues / Informational Notes

Flutter حاليًا يعرض وجود إصدارات أحدث لبعض Packages، ولكنها غير متوافقة مع قيود الإصدارات الحالية.

هذا ليس خطأ.

Current approach:

```text
Do not upgrade blindly.
```

يتم Upgrade فقط عند وجود سبب واضح مثل:

* Bug
* Security issue
* Required feature
* Compatibility problem
* Performance issue
* Required platform support

---

# 25. Important Architectural Decisions

## Decision 1 — Programming Identity

استخدام:

```text
Sales Management System
```

كهوية برمجية للمشروع.

الاسم التجاري العربي سيتم تحديده لاحقًا.

---

## Decision 2 — Cross Platform

النظام يستهدف:

```text
Windows
Android
iOS
Web
```

وعندما نستخدم كلمة **Mobile / Phone / هاتف** فنحن نقصد:

```text
Android + iOS
```

---

## Decision 3 — Database

استخدام SQLite للبيانات المحلية المنظمة في المرحلة الحالية.

---

## Decision 4 — Database Evolution

أي تغيير في Schema يتم عبر Migration.

لا يتم تعديل قاعدة البيانات القديمة بطريقة تكسر المستخدمين أو البيانات الموجودة.

---

## Decision 5 — Pricing

لا يتم إجبار المستخدم على سعر بيع محسوب آليًا من التكلفة.

السعر النهائي قرار تجاري للمستخدم.

---

## Decision 6 — Deletion

حماية البيانات التاريخية والمعاملات.

يفضل Active / Inactive أو Soft Delete عند الحاجة.

---

## Decision 7 — UI

Desktop وTablet وMobile يمكن أن تستخدم Layouts وInteraction مختلفة، مع مشاركة منطق التطبيق والبيانات.

---

## Decision 8 — Architecture Complexity

نستخدم Architecture منظمة وقابلة للاختبار، ولكن لا نضيف طبقات أو Frameworks لمجرد اتباع Pattern معروف.

---

## Decision 9 — Scope Control

لا يتم توسيع المشروع لمجرد زيادة عدد الخصائص.

الهدف:

```text
Build the smallest strong product
that solves the real sales-management problem.
```

---

## Decision 10 — Architectural Re-evaluation

أي قرار يمكن مراجعته إذا أثبت الاختبار أو الاستخدام أن الحل الحالي غير مناسب.

عند تغييره يجب توثيق:

```text
What changed?
Why?
What problem did the old approach have?
What is the replacement?
```

---

# 26. Current Milestone

```text
Foundation + Database V1 + Product Model
```

**Status:**

```text
🟢 Working
```

### Verified

```text
SQLite Foundation      PASS
Migration V1           PASS
Product Model          PASS
Product Model Test     PASS
Flutter Analyze        PASS
Flutter Test           PASS
```

### Immediate Next Task

```text
Product Repository
```

---

# 27. Change Log

## 2026-09-02

* Verified existing Flutter project foundation.
* Verified Git repository state.
* Verified SQLite foundation.
* Verified Migration V1.
* Added / verified Product Model.
* Added Product Model serialization/deserialization test.
* Fixed unnecessary SQLite import in database test.
* `flutter analyze` → No issues found.
* `flutter test` → 3 tests passed.
* Established `PROJECT_STATE.md` as the project state and engineering decisions record.

> ملاحظة: لا يُقصد بهذا القسم أن يكون سجل Git بديلًا. Git هو المصدر الأساسي لتاريخ التغييرات.

---

# 28. How To Continue

عند بدء جلسة تطوير جديدة:

1. اقرأ `PROJECT_STATE.md`.
2. نفّذ `git status`.
3. افحص الملفات المتعلقة بالمهمة الحالية.
4. لا تعِد بناء شيء موجود.
5. تابع من `Current Milestone` و`Immediate Next Task`.
6. نفّذ تغييرًا واحدًا مركزًا.
7. شغّل `flutter analyze`.
8. شغّل الاختبارات المناسبة.
9. اختبر السلوك الفعلي عند الحاجة.
10. حدّث `PROJECT_STATE.md` فقط إذا تغيرت حالة المشروع أو تم اتخاذ قرار مهم.
11. اعمل Commit عند اكتمال Milestone منطقي.
12. حافظ على Git history واضحًا وقابلًا للفهم.

---

# 29. Source of Truth

ترتيب مصادر الحقيقة في المشروع:

```text
1. Git + actual project files
        ↓
2. Database migrations / schema
        ↓
3. PROJECT_STATE.md
        ↓
4. Conversation history
```

`PROJECT_STATE.md` يوثق الحالة والقرارات، لكنه لا يحل محل الكود أو Git.

إذا تعارض وصف في هذا الملف مع الكود الفعلي، يجب:

1. فحص الحالة الفعلية.
2. تحديد أيهما أحدث وصحيح.
3. تصحيح `PROJECT_STATE.md` أو الكود حسب الحالة الصحيحة.
4. عدم الاستمرار اعتمادًا على افتراض قديم.
