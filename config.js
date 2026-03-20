// ============================================================
// TSF27 – Shared JS Utilities
// config.js  — loaded first on every page
// ============================================================

// ----- Supabase Configuration --------------------------------
// Replace with your actual Supabase project URL and anon key
const SUPABASE_URL = window.SUPABASE_URL || 'https://YOUR_PROJECT.supabase.co';
const SUPABASE_ANON_KEY = window.SUPABASE_ANON_KEY || 'YOUR_ANON_KEY_HERE';

// ----- Initialise Supabase client ----------------------------
const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ----- Auth helpers ------------------------------------------
const Auth = {
  async getSession() {
    const { data } = await db.auth.getSession();
    return data.session;
  },
  async getUser() {
    const { data } = await db.auth.getUser();
    return data.user;
  },
  async requireAuth() {
    const session = await this.getSession();
    if (!session) {
      window.location.href = '/index.html';
      return null;
    }
    return session.user;
  },
  async requireGuest() {
    const session = await this.getSession();
    if (session) {
      window.location.href = '/dashboard.html';
    }
  },
  async signOut() {
    await db.auth.signOut();
    window.location.href = '/index.html';
  }
};

// ----- Toast notifications -----------------------------------
function showToast(message, type = 'info') {
  let container = document.getElementById('toast-container');
  if (!container) {
    container = document.createElement('div');
    container.id = 'toast-container';
    document.body.appendChild(container);
  }
  const icons = { success: '✅', error: '❌', info: 'ℹ️' };
  const toast = document.createElement('div');
  toast.className = `toast ${type}`;
  toast.innerHTML = `<span>${icons[type] || 'ℹ️'}</span><span>${message}</span>`;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(12px)';
    toast.style.transition = 'all .3s ease';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// ----- Format helpers ----------------------------------------
function formatDate(dateStr) {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleDateString('en-PG', {
    day: '2-digit', month: 'short', year: 'numeric'
  });
}

function formatDateTime(dateStr) {
  if (!dateStr) return '—';
  return new Date(dateStr).toLocaleString('en-PG', {
    day: '2-digit', month: 'short', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  });
}

function capitalize(str) {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

// ----- Status badge ------------------------------------------
function statusBadge(status) {
  const map = {
    draft:     'badge-draft',
    submitted: 'badge-submitted',
    approved:  'badge-approved',
    rejected:  'badge-rejected',
  };
  return `<span class="badge ${map[status] || 'badge-draft'}">${capitalize(status)}</span>`;
}

// ----- Navbar user info --------------------------------------
async function initNavbar() {
  const user = await Auth.getUser();
  if (!user) return;

  const { data: profile } = await db
    .from('teacher_profiles')
    .select('full_name, role')
    .eq('id', user.id)
    .single();

  const name = profile?.full_name || user.email;
  const initials = name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);

  const el = document.getElementById('nav-user');
  if (el) {
    el.innerHTML = `
      <div class="avatar">${initials}</div>
      <span>${name}</span>
      ${profile?.role === 'admin' || profile?.role === 'tsc_officer'
        ? `<span class="badge badge-submitted" style="margin-left:.25rem">${capitalize(profile.role)}</span>`
        : ''}
    `;
  }

  // Show admin link if applicable
  if (profile?.role === 'admin' || profile?.role === 'tsc_officer') {
    document.querySelectorAll('.admin-only').forEach(el => el.style.display = '');
  }
}
