# VEHICA - Car Rental Mobile Application & Backend Platform

**PRM393 Final Project - Mobile Programming (Flutter & Spring Boot)**

Vehica is an enterprise-grade car rental platform built with **Clean Architecture**, featuring a modern **Flutter** mobile client (**Material 3 + Riverpod + Dio**) and a scalable **Spring Boot 3** REST API backend (**Java 21 + Spring Data JPA + Spring Security + JWT + PostgreSQL**).

---

## 👥 Project Team Members

| No. | Full Name | Student ID | Role |
| :---: | :--- | :---: | :--- |
| 1 | **Nguyễn Văn Đức Long** | `CS190175` | **Team Leader** |
| 2 | **Nguyễn Hoàng Thái Vinh** | `CE190384` | **Developer** |
| 3 | **Nguyễn Việt Tân** | `CE191195` | **Developer** |
| 4 | **Lê Khánh Đăng** | `CE180954` | **Developer** |
| 5 | **Nguyễn Quốc Kiệt** | `CE191198` | **Developer** |

---

## 🏛️ System Architecture Diagram

The system is designed following **Clean Architecture & Layered Enterprise Architecture**, strictly decoupling the Presentation Layer (Mobile Client), Business Logic & API Layer (Backend Platform), and Cloud Infrastructure (Database & CDN Storage):

```mermaid
graph TB
    subgraph Mobile_App ["📱 FLUTTER MOBILE CLIENT (Clean Architecture)"]
        direction TB
        subgraph Presentation_Layer ["Presentation Layer"]
            UI["UI Pages / Screens (S01 - S14)"]
            Widgets["Vehica Custom Widgets & Design System"]
            Controllers["Riverpod Controllers (StateNotifier / AsyncNotifier)"]
        end
        
        subgraph Domain_Layer ["Domain Layer (Business Core)"]
            Entities["Domain Entities"]
            RepoInterfaces["Repository Interfaces"]
            UseCases["Use Cases / Business Rules"]
        end
        
        subgraph Data_Layer ["Data Layer"]
            RepoImpl["Repository Implementations"]
            DataSources["Remote Data Sources (Dio HTTP)"]
            LocalStore["Secure Storage (Encrypted JWT & Session)"]
        end
        
        UI --> Controllers
        Widgets --> UI
        Controllers --> UseCases
        UseCases --> RepoInterfaces
        RepoImpl -.->|Implements| RepoInterfaces
        RepoImpl --> DataSources
        RepoImpl --> LocalStore
    end

    subgraph Backend_App ["💻 SPRING BOOT 3 BACKEND PLATFORM"]
        direction TB
        SecurityFilter["Spring Security Filter Chain & JWT Validator"]
        ControllersAPI["REST Controllers (v1 APIs)"]
        ServiceLayer["Service Layer (Domain Logic & State Machine)"]
        RepoJPA["Spring Data JPA Repositories"]
        UUIDv7["UUIDv7 Generator & Custom Mappers"]
        
        SecurityFilter --> ControllersAPI
        ControllersAPI --> ServiceLayer
        ServiceLayer --> RepoJPA
        ServiceLayer --> UUIDv7
    end

    subgraph Cloud_Services ["☁️ CLOUD INFRASTRUCTURE (Supabase & PostgreSQL)"]
        DB[(PostgreSQL Database)]
        CDN[(Supabase Storage CDN Bucket)]
    end

    %% Inter-tier connections
    DataSources -->|HTTPS / REST API + JWT Bearer| SecurityFilter
    RepoJPA -->|JDBC / SSL Connection Pooling| DB
    ServiceLayer -->|Multipart CDN Upload| CDN
    UI -->|Image Caching / Shimmer| CDN
```

---

## 🔄 Core Business Workflows

### 1. Authentication & Password Reset Flow

```mermaid
sequenceDiagram
    autonumber
    actor User as Customer / User
    participant Mobile as Mobile App (Flutter)
    participant AuthAPI as Auth Controller & Service
    participant DB as PostgreSQL Database
    participant SecureStore as Flutter Secure Storage

    %% Login Flow
    Note over User, SecureStore: 🔐 JWT AUTHENTICATION FLOW
    User->>Mobile: Enters Email & Password
    Mobile->>AuthAPI: POST /api/v1/auth/login
    AuthAPI->>DB: Query User by Email & Verify BCrypt Hash
    alt Login Successful
        AuthAPI-->>Mobile: 200 OK + JWT Bearer Token + Role + User Info
        Mobile->>SecureStore: Persist JWT Token securely
        Mobile-->>User: Navigate to Home / Admin Dashboard
    else Account Blocked (BLOCKED)
        AuthAPI-->>Mobile: 403 Forbidden (Account is deactivated)
        Mobile-->>User: Display Account Blocked Notification
    end

    %% Forgot Password Flow
    Note over User, SecureStore: 🔑 FORGOT PASSWORD & OTP FLOW
    User->>Mobile: Request Password Reset via Email
    Mobile->>AuthAPI: POST /api/v1/auth/forgot-password
    AuthAPI->>DB: Generate 6-digit OTP & Store in password_reset_otps (15m expiry)
    AuthAPI-->>Mobile: 200 OK (OTP Sent)
    User->>Mobile: Enters OTP & New Password (≥ 8 chars)
    Mobile->>AuthAPI: POST /api/v1/auth/reset-password
    AuthAPI->>DB: Verify OTP Validity -> Encode with BCrypt & Update Password
    AuthAPI-->>Mobile: 200 OK (Password Reset Successfully)
```

---

### 2. Vehicle Discovery & Real-Time Availability Check Flow

```mermaid
flowchart TD
    Start([User opens Catalog]) --> Search[Search by Vehicle Name / Brand / Type / Seat Filter]
    Search --> Filter[Send Filter Criteria to Backend]
    Filter --> Catalog[Display Infinite Scroll Vehicle List S03B]
    Catalog --> Select[Select Vehicle for Details S04]
    Select --> DateRange[Select Rental Date Range: StartDate to EndDate]
    DateRange --> CheckAvailability{Call API:\ncheckAvailability}
    
    CheckAvailability -->|Date Overlap Detected| Conflict[Conflict Warning: Dates Unavailable]
    Conflict --> DateRange
    
    CheckAvailability -->|Vehicle Available| Available[Display Pricing Snapshot & Enable Booking]
    Available --> BookingFlow([Proceed to Create Booking Page S05])
```

> **Booking Conflict Prevention Algorithm:**
> $$\text{isConflict} \iff (\text{existingStart} < \text{requestedEnd}) \land (\text{existingEnd} > \text{requestedStart})$$
> *Applied to bookings with statuses:* `PENDING`, `CONFIRMED`, `PICKED_UP`.

---

### 3. Booking Lifecycle & Finite State Machine (FSM)

The rental lifecycle strictly adheres to a **Finite State Machine (FSM)**:

```mermaid
stateDiagram-v2
    [*] --> PENDING: Customer creates booking (Price & Date Snapshot)
    
    PENDING --> CONFIRMED: Admin approves & confirms booking
    PENDING --> CANCELLED: Customer or Admin cancels booking
    
    CONFIRMED --> PICKED_UP: Customer receives car at Central Hub
    CONFIRMED --> CANCELLED: Customer or Admin cancels booking
    
    PICKED_UP --> COMPLETED: Customer returns car successfully
    
    CANCELLED --> [*]: Terminal State (No further action)
    COMPLETED --> [*]: Completed & Revenue Recorded
```

- **Snapshot Data Integrity:** When a booking is created (`PENDING`), `pricePerDay`, `rentalDays`, and `totalAmount` are snapshotted permanently, guaranteeing accounting integrity even if base vehicle rates change later.
- **Audit Logging:** Every state transition automatically generates an immutable audit record in the `booking_status_history` table.

---

### 4. Admin Operations & Fleet Management Workflow

```mermaid
graph LR
    Admin([Administrator]) --> Dashboard[S10 Admin KPI Dashboard]
    
    Dashboard --> Hub1[S07 Fleet Management\n- Vehicle CRUD\n- CDN Image Upload\n- Operational Status]
    Dashboard --> Hub2[S13 Brand Management\n- Partner Brands CRUD\n- Brand Logo Upload]
    Dashboard --> Hub3[S12 Booking Management\n- Approve / Pickup / Complete\n- Status Transition Audit]
    Dashboard --> Hub4[S09 User Management\n- Lock / Unlock Toggle\n- Admin Role Assignment]
    Dashboard --> Hub5[S08 Fleet Calendar\n- Maintenance & Availability]
```

---

## 📁 Project Structure

```
Vehica/
├── backend/                               # Spring Boot 3 REST API Application
│   ├── pom.xml                            # Maven Dependencies (Java 21, Spring Boot 3)
│   ├── mvnw & mvnw.cmd                    # Maven Wrapper scripts
│   ├── src/main/java/com/vehica/
│   │   ├── config/                        # SecurityConfig, CorsConfig, OpenApiConfig
│   │   ├── common/                        # ApiResponse, PageResponse, Exceptions & Utils (UUIDv7)
│   │   ├── security/                      # JwtTokenProvider, JwtAuthenticationFilter, UserPrincipal
│   │   ├── user/                          # User Entity, OTP, DTOs, Service & Controllers
│   │   ├── vehicle/                       # Vehicle, Brand, Type, Image Entities, Availability Engine
│   │   ├── booking/                       # Booking & Audit History Entities, State Machine Service
│   │   └── statistics/                    # Revenue, Fleet Occupancy & KPI Analytics
│   └── src/main/resources/
│       ├── application.yml                # Base configuration & environment bindings
│       └── application-dev.yml            # PostgreSQL & Hibernate profiles
│
├── mobile/                                # Flutter Mobile Application
│   ├── pubspec.yaml                       # Dependencies (Riverpod, Dio, GoRouter, Material 3)
│   ├── lib/
│   │   ├── app/                           # App initialization, GoRouter routes & global providers
│   │   ├── core/                          # Constants, Material 3 Theme, ApiClient, Failures, Base Widgets
│   │   │   ├── theme/                     # Dark Slate & Emerald Teal themes & typography
│   │   │   └── widgets/                   # Reusable UI components (Buttons, Fields, Badges, Pickers)
│   │   └── features/                      # Feature-First Clean Architecture
│   │       ├── auth/                      # Login, Register, Forgot Password OTP flow
│   │       ├── profile/                   # Customer profile & account details
│   │       ├── vehicles/                  # Home Hub, Search Catalog, Vehicle Details & Availability
│   │       ├── bookings/                  # Booking creation, Customer history & Admin Management
│   │       ├── users/                     # Admin User Administration & Role management
│   │       └── dashboard/                 # Admin KPI Dashboard, Vehicle CRUD & Fleet Calendar
│   └── test/                              # Unit, Widget & Integration Tests
│
├── .gitignore                             # Global Git exclusion rules
└── .env                                   # Environment configuration & DB secrets
```

---

## 🚀 Quick Start Guide

### 1. Database & Environment Configuration
Configure PostgreSQL database credentials and environment parameters in the root `.env` file:
```bash
SPRING_DATASOURCE_URL=jdbc:postgresql://<HOST>:5432/<DATABASE>?sslmode=require
SPRING_DATASOURCE_USERNAME=<DB_USER>
SPRING_DATASOURCE_PASSWORD=<DB_PASSWORD>


---

### 2. Running the Backend (Spring Boot 3)

```bash
cd backend

# Windows:
.\mvnw.cmd spring-boot:run

# Linux / macOS:
./mvnw spring-boot:run
```

- **API Base URL:** `http://localhost:8080/api/v1`
- **Swagger UI Documentation:** `http://localhost:8080/swagger-ui.html`
- **OpenAPI Docs:** `http://localhost:8080/v3/api-docs`

---

### 3. Running the Mobile App (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## 🧪 Testing & Automated Quality Assurance

### Backend Unit & Integration Tests (JUnit 5 + Spring Boot Test)
```bash
cd backend
.\mvnw.cmd test
```

### Flutter Unit & Widget Tests
```bash
cd mobile
flutter test
```
