# TSF27 – Teaching Service Commission Form 27 Portal
**Papua New Guinea Teaching Service Commission**  
Teacher Admissions Management System (TSF27)

---

## 📋 Overview

A full-stack web application for managing TSF27 Teacher Admissions Management Forms. Teachers can register, submit their Form 27 digitally, and track their application status. TSC officers can review and process applications.

### Features
- ✅ Secure authentication (login / register / password reset)
- ✅ Complete digital TSF27 Form 27 (all sections)
- ✅ Save drafts and resume any time
- ✅ Multi-step form with validation
- ✅ Application status tracking dashboard
- ✅ Admin panel for TSC officers to review and decide
- ✅ Row Level Security — teachers see only their own data
- ✅ Mobile responsive

---

## 🗂 Project Structure

```
tsf27-app/
├── index.html          # Login page
├── register.html       # Create account
├── dashboard.html      # Teacher dashboard
├── form27.html         # TSF27 multi-step form
├── admin.html          # TSC Officer / Admin panel
├── css/
│   └── style.css       # Global styles
├── js/
│   └── config.js       # Supabase client + shared utilities
├── database/
│   └── schema.sql      # PostgreSQL schema for Supabase
├── netlify.toml        # Netlify hosting config
└── README.md
```

---

## 🚀 Setup Guide

### Step 1 — Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a free account.
2. Click **New Project** — give it a name (e.g., `tsf27-portal`).
3. Choose a region close to Papua New Guinea (e.g., Singapore `ap-southeast-1`).
4. Set a strong database password and save it.

### Step 2 — Run the Database Schema

1. In Supabase, go to **SQL Editor**.
2. Copy the contents of `database/schema.sql`.
3. Paste and click **Run**.
4. This creates:
   - `teacher_profiles` table
   - `form27_submissions` table (all form fields)
   - Row Level Security policies
   - Auto-profile creation trigger

### Step 3 — Get Your Supabase Keys

1. In Supabase, go to **Settings → API**.
2. Copy:
   - **Project URL** (e.g., `https://abcdefgh.supabase.co`)
   - **anon / public key** (safe to use in frontend)

### Step 4 — Configure the App

Open `js/config.js` and replace the placeholder values:

```javascript
const SUPABASE_URL     = 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
```

### Step 5 — Configure Email Auth in Supabase

1. Go to **Authentication → Settings**.
2. Under **Email**, ensure **Enable Email Confirmations** is turned on.
3. Under **Site URL**, enter your Netlify domain (e.g., `https://tsf27.netlify.app`).
4. Under **Redirect URLs**, add:
   - `https://tsf27.netlify.app/**`
   - `http://localhost:*/**` (for local dev)

### Step 6 — Deploy to Netlify

**Option A: Drag & Drop**
1. Go to [netlify.com](https://netlify.com) and log in.
2. Drag the entire `tsf27-app/` folder onto the Netlify dashboard.
3. Your site is live! Copy the URL.

**Option B: GitHub + Netlify (recommended)**
1. Push your project to a GitHub repository.
2. In Netlify, click **Add New Site → Import from Git**.
3. Select your repo and branch.
4. Build command: (leave empty)
5. Publish directory: `.` (root)
6. Click **Deploy Site**.

### Step 7 — Create Admin User

After deploying:
1. Register a normal account via the app.
2. In Supabase, go to **Table Editor → teacher_profiles**.
3. Find your user row and change the `role` column from `teacher` to `admin` (or `tsc_officer`).
4. Now you can access `/admin.html`.

---

## 👥 User Roles

| Role         | Capabilities                                         |
|--------------|------------------------------------------------------|
| `teacher`    | Register, fill Form 27, save drafts, submit, track   |
| `tsc_officer`| View all submissions, make TSC decisions             |
| `admin`      | Full access: all submissions + user management       |

---

## 🔒 Security Notes

- All passwords are hashed by Supabase Auth (bcrypt).
- Row Level Security (RLS) ensures teachers can only access their own data.
- JWT tokens are handled automatically by the Supabase client.
- The anon key is safe to expose in frontend code — RLS enforces permissions.
- Never expose the **Service Role Key** in frontend code.

---

## 🛠 Local Development

Simply open `index.html` in a browser — no build step required.

For a local server (recommended to avoid CORS issues):

```bash
# Using Python
python3 -m http.server 8080

# Using Node.js
npx serve .
```

Then open `http://localhost:8080`.

---

## 📊 Database Tables

### `teacher_profiles`
Extends Supabase Auth users with name and role.

### `form27_submissions`
All Form 27 fields including:
- Personal Details (Section 1)
- Place of Origin (Section 2)
- Family / Dependents (Section 3)
- Qualifications (Section 4)
- Teaching Position (Section 5)
- Affirmation (Section 6)
- Certification (Section 7)
- TSC Decision (Section 8)

---

## 📧 Support

Teaching Service Commission — Papua New Guinea  
For technical issues, contact your ICT department.

---

*Built for PNG Teaching Service Commission TSF27 Digital Transformation Initiative.*
