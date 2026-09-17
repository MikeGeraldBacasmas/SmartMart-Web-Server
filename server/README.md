# SmartMart Backend API

## Stack
- **Database**: MySQL 8.0 (managed via SQLyog)
- **Runtime**: Node.js
- **Framework**: Express.js
- **Auth**: JWT (jsonwebtoken)
- **Password hashing**: bcryptjs

---

## Setup

### 1. Database (SQLyog / MySQL Client)
1. Open SQLyog (or any MySQL client) and connect to your MySQL server
2. Run `sql/smartmart_db_full.sql` — creates the database, all tables, seed data, and all 34 stored procedures

### 2. Server
```bash
cd server
npm install
cp .env.example .env        # fill in your DB credentials and JWT secret
npm run dev                 # development with auto-reload
npm start                   # production
```

---

## API Reference

### Auth
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/auth/login` | Login with username + password | Public |

**Login body:**
```json
{ "username": "admin", "password": "admin123" }
```
**Response:** `{ token, user: { id, username, role, name } }`

---

### Dashboard
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/api/dashboard` | Admin |

---

### Staff
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/staff` | List all staff | Admin |
| POST | `/api/staff` | Create staff account | Admin |
| PATCH | `/api/staff/:id/toggle-status` | Activate / Deactivate | Admin |

**Create staff body:**
```json
{ "username": "maria", "password": "pass123", "full_name": "Maria Santos", "role": "Cashier" }
```

---

### Customers
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/customers` | Registered customers | Admin/Staff |
| GET | `/api/customers/pending` | Pending registrations | Admin |
| POST | `/api/customers/register` | Submit registration form | Public |
| POST | `/api/customers/:id/approve` | Approve + assign credentials | Admin |
| POST | `/api/customers/:id/deny` | Deny registration | Admin |

**Register body:**
```json
{
  "last_name": "Dela Cruz", "first_name": "Juan", "middle_name": "Santos",
  "address": "Brgy. Poblacion, Bilar, Bohol",
  "date_of_birth": "1995-06-15",
  "civil_status": "Single", "gender": "Male", "phone": "09171234567"
}
```

**Approve body:**
```json
{ "username": "juan.delacruz", "password": "temp1234" }
```

---

### Categories
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/api/categories` | All roles |
| POST | `/api/categories` | Admin |

**Create body:** `{ "name": "Coffee & Tea" }`

---

### Products
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/products` | All active products | All roles |
| GET | `/api/products/low-stock` | Low stock products | Admin/Staff |
| POST | `/api/products` | Add product | Admin |
| PATCH | `/api/products/:id/stock` | Update stock | Admin |

**Create body:**
```json
{ "name": "Chippy BBQ 110g", "category_id": 1, "price": 15.00, "stock": 50 }
```

---

### Transactions
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | `/api/transactions?from=YYYY-MM-DD&to=YYYY-MM-DD` | List transactions | Admin/Staff |
| GET | `/api/transactions/:id/items` | Items in a transaction | Admin/Staff |
| POST | `/api/transactions` | Create transaction | Admin/Staff |

**Create transaction body:**
```json
{
  "customer_id": 1,
  "cashier_id": 1,
  "cash_tendered": 200.00,
  "items": [
    { "product_id": 5, "quantity": 2 },
    { "product_id": 12, "quantity": 1 }
  ]
}
```

---

### Settings
| Method | Endpoint | Auth |
|--------|----------|------|
| GET | `/api/settings` | Admin |
| PATCH | `/api/settings` | Admin |

**Update body:**
```json
{ "store_name": "SmartMart", "store_address": "Zamora, Bilar, Bohol" }
```

---

## Authentication
All protected routes require:
```
Authorization: Bearer <token>
```

## Default Demo Credentials
| Role | Username | Password |
|------|----------|----------|
| Admin | admin | admin123 |
| Staff | staff | admin123 |
| Customer | customer | admin123 |

> **Note:** Seed passwords in `01_schema.sql` are placeholder hashes. Run the server once and use the `/api/auth/login` endpoint — or update the hashes by running `bcrypt.hash("admin123", 10)` in Node.js and inserting the result manually via SQLyog.
