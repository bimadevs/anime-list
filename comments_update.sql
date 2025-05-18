-- Menambahkan kolom comments ke tabel animes
ALTER TABLE public.animes 
ADD COLUMN IF NOT EXISTS comments JSONB DEFAULT '[]'::jsonb;

-- Menjelaskan tabel untuk memverifikasi perubahan
\d public.animes;
