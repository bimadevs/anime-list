-- Mengubah constraint foreign key pada tabel comments untuk menghapus komentar saat anime dihapus

-- 1. Pertama, identifikasi constraint foreign key yang ada
SELECT conname, pg_get_constraintdef(oid) AS constraint_def
FROM pg_constraint
WHERE conrelid = 'public.comments'::regclass AND contype = 'f';

-- 2. Drop constraint yang ada
ALTER TABLE public.comments DROP CONSTRAINT IF EXISTS comments_anime_id_fkey;

-- 3. Buat ulang constraint dengan ON DELETE CASCADE
ALTER TABLE public.comments
ADD CONSTRAINT comments_anime_id_fkey 
FOREIGN KEY (anime_id) REFERENCES public.animes(id) ON DELETE CASCADE;

-- Informasi tambahan
COMMENT ON CONSTRAINT comments_anime_id_fkey ON public.comments IS 'Constraint ini akan menghapus semua komentar terkait saat anime dihapus';
