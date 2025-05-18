-- Membuat tabel comments untuk menyimpan komentar terpisah
CREATE TABLE public.comments (
  id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  anime_id UUID REFERENCES public.animes(id),
  author TEXT NOT NULL,
  text TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_admin BOOLEAN DEFAULT false,
  user_id UUID REFERENCES auth.users(id)
);

-- Mengaktifkan Row Level Security
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- Policy untuk membaca komentar - semua orang bisa melihat
CREATE POLICY "Komentar dapat dilihat semua orang" 
ON public.comments FOR SELECT 
USING (true);

-- Policy untuk menambah komentar - semua orang (bahkan yang tidak login)
CREATE POLICY "Semua orang dapat menambah komentar" 
ON public.comments FOR INSERT 
WITH CHECK (true);

-- Policy untuk menghapus komentar - hanya admin atau pembuat komentar
CREATE POLICY "Admin atau pembuat dapat menghapus komentar" 
ON public.comments FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  ) OR user_id = auth.uid()
);
