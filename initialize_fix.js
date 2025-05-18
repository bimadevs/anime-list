// Tambahkan kode ini di dalam fungsi initialize() 
// di bawah bagian "console.log('Initializing app...', new Date().toLocaleTimeString());"

// Ambil daftar genre dari Supabase
try {
    console.log('Mengambil daftar genre dari Supabase...');
    const supabaseGenres = await fetchGenresFromSupabase();
    
    if (supabaseGenres && supabaseGenres.length > 0) {
        console.log('Berhasil mendapatkan', supabaseGenres.length, 'genre dari Supabase');
        // Merge genre dari Supabase dengan genre default
        // Pastikan tidak ada duplikat
        supabaseGenres.forEach(genre => {
            if (!availableGenres.includes(genre)) {
                availableGenres.push(genre);
            }
        });
        // Update UI untuk filter genre
        updateGenreFilter();
        updateGenreTags();
    } else {
        console.log('Tidak ada genre di Supabase, menggunakan genre default saja');
    }
    
    // Ambil data anime dari Supabase
    console.log('Mengambil data anime dari Supabase...');
    const supabaseAnimeData = await fetchAnimesFromSupabase();
    
    if (supabaseAnimeData && supabaseAnimeData.length > 0) {
        console.log('Berhasil mendapatkan', supabaseAnimeData.length, 'anime dari Supabase');
        animeData = supabaseAnimeData;
    } else {
        // Jika tidak ada data di Supabase, gunakan data dari localStorage
        console.log('Tidak ada data anime di Supabase, menggunakan data dari localStorage...');
        loadFromLocalStorage();
    }
} catch (error) {
    console.error('Error saat mengambil data dari Supabase:', error);
    // Jika ada error, gunakan data dari localStorage
    loadFromLocalStorage();
}
