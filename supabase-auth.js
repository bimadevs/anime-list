// Supabase Auth Integration
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm'

// Supabase konfigurasi - ganti dengan kredensial Supabase Anda
const SUPABASE_URL = 'https://lupprdxmaraogkumuewl.supabase.co';
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx1cHByZHhtYXJhb2drdW11ZXdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc1NDc0NTIsImV4cCI6MjA2MzEyMzQ1Mn0.H6MDU-sO4v5PfY2NaUM6YEyt2lmFMeHQyjWm6nL6gcc';

// Initialize Supabase client
const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

// Variable untuk menyimpan state autentikasi
let currentUser = null;

// Fungsi untuk mendaftarkan pengguna baru
async function signUp(email, password, username) {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          username: username
        }
      }
    });

    if (error) throw error;
    
    return { success: true, data };
  } catch (error) {
    console.error('Error signing up:', error.message);
    return { success: false, error: error.message };
  }
}

// Fungsi untuk login
async function signIn(email, password) {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) throw error;
    
    currentUser = data.user;
    return { success: true, user: data.user };
  } catch (error) {
    console.error('Error signing in:', error.message);
    return { success: false, error: error.message };
  }
}

// Fungsi untuk logout
async function signOut() {
  try {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    
    currentUser = null;
    return { success: true };
  } catch (error) {
    console.error('Error signing out:', error.message);
    return { success: false, error: error.message };
  }
}

// Fungsi untuk mendapatkan sesi saat ini
async function getCurrentSession() {
  try {
    const { data, error } = await supabase.auth.getSession();
    
    if (error) throw error;
    
    if (data.session) {
      currentUser = data.session.user;
      return { success: true, user: data.session.user };
    }
    
    return { success: false, user: null };
  } catch (error) {
    console.error('Error getting session:', error.message);
    return { success: false, error: error.message };
  }
}

// Fungsi untuk mengirim reset password
async function resetPassword(email) {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/index.html?reset=true`
    });

    if (error) throw error;
    
    return { success: true };
  } catch (error) {
    console.error('Error resetting password:', error.message);
    return { success: false, error: error.message };
  }
}

// Fungsi untuk mengubah password
async function updatePassword(newPassword) {
  try {
    const { error } = await supabase.auth.updateUser({
      password: newPassword
    });

    if (error) throw error;
    
    return { success: true };
  } catch (error) {
    console.error('Error updating password:', error.message);
    return { success: false, error: error.message };
  }
}

// Fungsi untuk cek apakah user adalah admin
async function isUserAdmin() {
  if (!currentUser) return false;

  try {
    // Dapatkan data user dari tabel profiles atau roles (perlu dibuat di Supabase)
    const { data, error } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', currentUser.id)
      .single();

    if (error) throw error;
    
    return data.role === 'admin';
  } catch (error) {
    console.error('Error checking admin status:', error.message);
    return false;
  }
}

// Fungsi untuk mendapatkan user saat ini
function getCurrentUser() {
  return currentUser;
}

// Fungsi untuk mendeteksi perubahan status autentikasi
function setupAuthListener(callback) {
  return supabase.auth.onAuthStateChange((event, session) => {
    if (session) {
      currentUser = session.user;
    } else {
      currentUser = null;
    }
    
    callback(event, currentUser);
  });
}

// Export fungsi-fungsi auth
export {
  signUp,
  signIn,
  signOut,
  getCurrentSession,
  getCurrentUser,
  resetPassword,
  updatePassword,
  isUserAdmin,
  setupAuthListener
};
