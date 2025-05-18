-- Membuat tabel profiles untuk menyimpan data pengguna
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  username TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Membuat fungsi yang akan dijalankan oleh trigger
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, role)
  VALUES (new.id, new.raw_user_meta_data->>'username', 'user');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Membuat trigger yang menjalankan fungsi setiap kali user baru dibuat
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Memberikan kebijakan akses
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policy untuk membaca profil
CREATE POLICY "Profil dapat dibaca oleh semua pengguna yang login" 
ON public.profiles FOR SELECT 
USING (auth.role() = 'authenticated');

-- Policy untuk mengupdate profil sendiri
CREATE POLICY "Pengguna dapat mengupdate profil mereka sendiri" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id);

-- Khusus untuk admin, agar dapat mengubah role pengguna lain
CREATE POLICY "Admin dapat mengubah semua profil" 
ON public.profiles FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Menambahkan admin pertama
-- Jalankan SQL ini setelah Anda mendaftarkan user admin pertama
-- CATATAN: Ganti dengan email yang Anda gunakan saat registrasi
UPDATE public.profiles 
SET role = 'admin' 
WHERE id IN (SELECT id FROM auth.users);