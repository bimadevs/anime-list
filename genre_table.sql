-- Membuat tabel untuk menyimpan genre
CREATE TABLE public.genres (
  id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);

-- Mengaktifkan Row Level Security
ALTER TABLE public.genres ENABLE ROW LEVEL SECURITY;

-- Policy untuk membaca genre - semua orang bisa melihat
CREATE POLICY "Genre dapat dilihat semua orang" 
ON public.genres FOR SELECT 
USING (true);

-- Policy untuk menambah genre - hanya admin
CREATE POLICY "Hanya admin yang dapat menambah genre" 
ON public.genres FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Policy untuk menghapus genre - hanya admin
CREATE POLICY "Hanya admin yang dapat menghapus genre" 
ON public.genres FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);
