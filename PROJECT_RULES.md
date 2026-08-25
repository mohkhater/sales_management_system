# Sales Management System — Project Rules

## 1. Project Goal

Sales Management System is a simple, fast, flexible, and reliable business management system designed for different types of commercial activities.

The system should simplify daily sales and business operations without forcing users to understand accounting concepts or complicated software workflows.

The primary principle is:

> Simple for the user, powerful under the hood.

---

## 2. Supported Business Types

The core system must support multiple business activities, including but not limited to:

- Grocery stores
- Retail stores
- Warehouses
- Store + warehouse
- Pharmacies
- Restaurants
- Clothing and shoes
- Mobile devices and accessories
- Household products
- Cleaning products
- Wholesale businesses
- Other commercial activities

The system must not be architecturally tied to one business type.

---

## 3. Supported Platforms

The system targets:

- Android
- iOS
- Windows
- Web

The UI must support:

- Phones
- Tablets
- Desktop computers
- Touch-screen POS devices
- Mouse and keyboard
- Touch interaction

The business logic and core application behavior must remain shared across platforms.

---

## 4. Offline First

The system must work without an Internet connection.

Core operations must not depend on permanent Internet availability.

Each device should maintain its own local data and continue operating when offline.

---

## 5. Local Database

SQLite is the primary local database.

Each device has its own local database.

The application must not depend on a remote database for normal daily operations.

Database structure must evolve through migrations without destroying existing user data.

---

## 6. Synchronization

The system is designed to support:

- Local synchronization over Wi-Fi
- Hotspot-based synchronization
- Cloud synchronization when Internet is available

Synchronization must be designed to avoid:

- Data loss
- Duplicate transactions
- Conflicting records
- Partial operations

Synchronization should remain as transparent and simple as possible for the user.

---

## 7. Data Identity

UUIDs should be used for entities that participate in synchronization or require globally unique identification.

Records created independently on different devices must be able to merge safely.

---

## 8. Architecture

The application must maintain a clear separation between:

- Presentation
- Application
- Domain
- Data

Business logic must not be embedded directly inside UI widgets.

UI changes must not require rewriting business logic or database logic.

---

## 9. Responsive UI

The application must use a responsive UI architecture.

The same business operation may have different layouts for:

- Mobile
- Tablet
- Desktop

Device type and screen size determine presentation.

Business type determines available features/capabilities.

These two concerns must remain separate.

---

## 10. UI Design System

The application should use a centralized design system containing reusable:

- Colors
- Typography
- Spacing
- Dimensions
- Components
- Layout helpers

Common UI patterns should be implemented as reusable components when repetition becomes clear.

Do not build a large custom UI framework before it is needed.

---

## 11. Simplicity

The simplest correct solution is preferred.

Do not add:

- Unnecessary features
- Unnecessary abstractions
- Unnecessary packages
- Unnecessary architecture layers

Every significant complexity must have a clear justification.

---

## 12. Performance

Performance is a core requirement.

The system should remain lightweight and responsive, especially on older devices.

Database operations, UI rebuilding, memory usage, synchronization, and application startup should be considered carefully.

Optimization should be based on real problems and measurements rather than premature optimization.

---

## 13. Business Philosophy

The system should simplify business operations rather than expose users to unnecessary accounting complexity.

Users should perform practical business actions such as:

- Sell
- Buy
- Return
- Receive payment
- Record expenses
- Manage stock

The system should perform the necessary calculations internally whenever possible.

---

## 14. Development Method

Development follows this cycle:

Analysis
→ Decision
→ Design
→ Implementation
→ Test
→ Commit

Features should be developed incrementally.

Each stable milestone should have a Git commit.

---

## 15. Vertical Development

When practical, features should be implemented as complete vertical slices:

Database
→ Data
→ Domain
→ Application
→ State
→ UI
→ Test

A working feature is preferred over building large incomplete layers in isolation.

---

## 16. Database Safety

Application updates must not delete or overwrite customer data.

Application files and customer data must remain conceptually separate.

Database migrations must preserve existing data whenever possible.

Backup and restore mechanisms must be considered part of the system architecture.

---

## 17. Dependencies

External packages should be added only when they provide meaningful value that cannot be reasonably achieved using existing Flutter/Dart capabilities.

Every important dependency should have a clear reason for inclusion.

---

## 18. Product Customization

Business-specific functionality should be controlled through business configuration/capabilities rather than creating separate codebases for every business type.

The same core system should support multiple business profiles.

---

## 19. Commercial Identity

The internal software project name is:

`sales_management_system`

The future commercial/product name is independent from the source-code architecture and may be changed without affecting the business logic or database architecture.

---

## 20. Core Principle

The goal is not to build the largest system.

The goal is:

> Build the simplest system that delivers the greatest practical value.

Fast, reliable, understandable, maintainable, offline-capable, and easy to use.