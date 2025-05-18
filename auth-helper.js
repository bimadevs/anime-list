// Fungsi untuk menangani autentikasi Supabase

// Fungsi handleAuth untuk menangani klik tombol auth
async function handleAuth() {
    if (currentUser) {
        // Logout jika sudah login
        const result = await signOut();
        if (result.success) {
            await updateAuthState(false, false);
        }
    } else {
        // Tampilkan modal login jika belum login
        loginModal.style.display = 'flex';
    }
}

// Fungsi untuk mengarahkan ke halaman auth
function redirectToAuthPage() {
    window.location.href = 'auth-ui.html';
}
