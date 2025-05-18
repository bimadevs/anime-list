-- Hapus kebijakan INSERT yang lama
DROP POLICY IF EXISTS "Semua user yang login dapat menambah komentar" ON public.comments;

-- Buat kebijakan baru yang memperbolehkan semua orang (bahkan yang tidak login) untuk menambah komentar
CREATE POLICY "Semua orang dapat menambah komentar" 
ON public.comments FOR INSERT 
WITH CHECK (true);
