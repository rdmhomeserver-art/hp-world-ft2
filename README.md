# 🚀 HP WORLD FT-2 — Sales Follow-Up Portal

A cloud-based customer follow-up management system for the HP WORLD FT-2 sales team.

**Stack:** Next.js 14 · Tailwind CSS · Supabase · Vercel

---

## ✅ Features

- **Customer Management** — Name, mobile, product/model, remarks, status, next follow-up date
- **Follow-up Timeline** — Full history with comments, status updates, and next follow-up scheduling
- **Live Dashboard** — Stats: total customers, hot today, today's follow-ups, overdue, recently added
- **Excel Export** — All customers / today's follow-ups / hot customers
- **WhatsApp Integration** — Click any mobile number to open WhatsApp chat
- **Search & Filters** — By name, mobile, product, status, date
- **Authentication** — Supabase Auth (email/password) for 3–5 users
- **Dark Mode** — Toggle with preference saved to localStorage
- **Mobile Responsive** — Optimized for phones and tablets

---

## 🗂 Project Structure

```
src/
├── app/
│   ├── auth/login/         # Login page
│   ├── auth/callback/      # OAuth callback route
│   ├── dashboard/          # Dashboard (server component)
│   ├── customers/          # Customers list, new, [id] detail
│   └── globals.css
├── components/
│   ├── layout/AppLayout    # Sidebar + mobile nav
│   ├── dashboard/          # Dashboard content
│   ├── customers/          # List, form, detail
│   └── ui/StatusBadge
├── lib/
│   ├── supabase/client.ts  # Browser Supabase client
│   ├── supabase/server.ts  # Server Supabase client
│   ├── utils.ts            # Helpers, date formatting
│   └── export.ts           # Excel export
├── types/index.ts          # TypeScript types
└── middleware.ts           # Auth protection
```

---

## 🛠 Setup Instructions

### Step 1 — Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Choose a region close to India (e.g., `ap-south-1` Mumbai or Singapore)
3. Note your **Project URL** and **anon/public key** from:  
   `Settings → API → Project URL + anon key`
4. Also copy the **service_role key** (keep this secret!)

### Step 2 — Run the Database Schema

1. In Supabase Dashboard → **SQL Editor** → **New Query**
2. Paste the entire contents of `supabase-schema.sql`
3. Click **Run** — you should see "Success"

### Step 3 — Create Your Team Users

1. In Supabase Dashboard → **Authentication → Users → Invite User**
2. Enter each team member's email address
3. They'll receive a link to set their password
4. Alternatively, go to **Authentication → Users → Add User** to manually create users with a password

> ⚠️ The app uses email/password login only. No self-signup — admin must create users.

### Step 4 — Configure Environment Variables

Copy `.env.local.example` to `.env.local`:

```bash
cp .env.local.example .env.local
```

Fill in your values:

```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...your-anon-key...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...your-service-role-key...
NEXT_PUBLIC_APP_NAME=Sales Follow-Up Portal
```

### Step 5 — Run Locally

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## ☁️ Deploy to Vercel

### Option A — Vercel CLI (Recommended)

```bash
# Install Vercel CLI
npm install -g vercel

# From the project folder
vercel

# Follow prompts, then set environment variables:
vercel env add NEXT_PUBLIC_SUPABASE_URL
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
vercel env add SUPABASE_SERVICE_ROLE_KEY

# Deploy to production
vercel --prod
```

### Option B — Vercel Dashboard (GitHub)

1. Push this project to a GitHub repository
2. Go to [vercel.com](https://vercel.com) → **New Project** → Import your repo
3. In **Environment Variables**, add:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
4. Click **Deploy**

### Set Supabase Redirect URL

After deployment, add your Vercel URL to Supabase:

1. Supabase Dashboard → **Authentication → URL Configuration**
2. **Site URL**: `https://your-app.vercel.app`
3. **Redirect URLs**: `https://your-app.vercel.app/auth/callback`

---

## 📊 Database Schema Overview

```sql
customers
  id                UUID (PK)
  name              TEXT
  mobile            TEXT
  product_model     TEXT
  remarks           TEXT
  status            TEXT  -- 'New' | 'Interested' | 'Hot' | 'Closed'
  next_followup_date DATE
  created_by        TEXT  -- user email
  created_at        TIMESTAMPTZ
  updated_at        TIMESTAMPTZ

follow_ups
  id                UUID (PK)
  customer_id       UUID (FK → customers.id)
  comment           TEXT
  status            TEXT
  next_followup_date DATE
  created_by        TEXT
  created_at        TIMESTAMPTZ
```

---

## 🔒 Security

- **Row Level Security (RLS)** enabled on all tables
- Only authenticated (logged-in) users can access data
- All team members share access to all customer data
- Passwords managed by Supabase Auth (bcrypt hashed)
- No sensitive keys exposed to the browser

---

## 📱 WhatsApp Integration

Phone numbers are automatically formatted for Indian numbers:
- `9876543210` → `https://wa.me/919876543210`
- `09876543210` → `https://wa.me/919876543210`
- `919876543210` → `https://wa.me/919876543210`

Click any mobile number in the app to open WhatsApp Web or app.

---

## 📦 Excel Export

Three export options available on the Customers page:
1. **Export Filtered** — exports whatever is currently filtered/searched
2. **Today's Follow-ups** — customers with today as next follow-up date
3. **Hot Customers** — all customers with "Hot" status

Files download as `.xlsx` with proper column widths.

---

## 🔮 Future Upgrade Ideas

- **Notifications** — Email/SMS reminders for overdue follow-ups (via Supabase Edge Functions + Resend/Twilio)
- **Team assignments** — Assign customers to specific sales reps
- **Analytics** — Conversion funnel, rep performance charts
- **Bulk import** — Upload customers via CSV
- **Notes/attachments** — Attach files to customer records
- **Custom fields** — Configurable product categories

---

## 💡 Free Tier Compatibility

| Service   | Free Tier Limit              | Usage           |
|-----------|------------------------------|-----------------|
| Supabase  | 500MB DB, 50K rows, 2GB egress | ✅ Well within  |
| Vercel    | 100GB bandwidth, unlimited deployments | ✅ Fine |

This app is designed to run entirely within free tiers for teams of 3–5 users.

---

## 🐛 Troubleshooting

**Login not working?**
- Check your Supabase URL and anon key are correct in `.env.local`
- Make sure the user was created in Supabase Auth dashboard

**Data not loading after deploy?**
- Verify all 3 environment variables are set in Vercel
- Check Supabase RLS policies were created (run the SQL schema again)

**WhatsApp not opening?**
- Ensure the mobile number is 10 digits (Indian format)
- Numbers starting with +91 or 91 also work

---

Built with ❤️ for retail sales teams
