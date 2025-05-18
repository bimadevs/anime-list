-- Membuat tabel anime untuk menyimpan data anime
CREATE TABLE public.animes (
  id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  image TEXT, 
  episodes INTEGER,
  status TEXT CHECK (status IN ('Ongoing', 'Finished')),
  rating DECIMAL(3,1),
  genres TEXT[], -- Array untuk menyimpan genre
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id), -- referensi ke user yang menambahkan
  facebook_link TEXT, -- Link Facebook untuk anime
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mengaktifkan Row Level Security
ALTER TABLE public.animes ENABLE ROW LEVEL SECURITY;

-- Policy untuk membaca anime - semua orang bisa melihat
CREATE POLICY "Anime dapat dilihat semua orang" 
ON public.animes FOR SELECT 
USING (true);

-- Policy untuk menambah anime - hanya admin
CREATE POLICY "Hanya admin yang dapat menambah anime" 
ON public.animes FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Policy untuk update anime - hanya admin
CREATE POLICY "Hanya admin yang dapat mengubah anime" 
ON public.animes FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Policy untuk menghapus anime - hanya admin
CREATE POLICY "Hanya admin yang dapat menghapus anime" 
ON public.animes FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Fungsi untuk auto-update timestamp ketika data diupdate
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk auto-update timestamp
CREATE TRIGGER update_animes_timestamp
BEFORE UPDATE ON public.animes
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();

-- Membuat tabel untuk comments
CREATE TABLE public.anime_comments (
  id UUID DEFAULT extensions.uuid_generate_v4() PRIMARY KEY,
  anime_id UUID REFERENCES public.animes(id) ON DELETE CASCADE,
  author_id UUID REFERENCES auth.users(id),
  text TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mengaktifkan Row Level Security untuk comments
ALTER TABLE public.anime_comments ENABLE ROW LEVEL SECURITY;

-- Policy untuk membaca komentar - semua orang bisa melihat
CREATE POLICY "Komentar dapat dilihat semua orang" 
ON public.anime_comments FOR SELECT 
USING (true);

-- Policy untuk menambah komentar - user yang login
CREATE POLICY "User yang login dapat menambah komentar" 
ON public.anime_comments FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Policy untuk update komentar - hanya pemilik komentar
CREATE POLICY "Hanya pemilik yang dapat mengubah komentar" 
ON public.anime_comments FOR UPDATE 
USING (author_id = auth.uid());

-- Policy untuk menghapus komentar - pemilik atau admin
CREATE POLICY "Pemilik atau admin dapat menghapus komentar" 
ON public.anime_comments FOR DELETE 
USING (
  author_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Trigger untuk auto-update timestamp pada comments
CREATE TRIGGER update_anime_comments_timestamp
BEFORE UPDATE ON public.anime_comments
FOR EACH ROW
EXECUTE PROCEDURE update_modified_column();
