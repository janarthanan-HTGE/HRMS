-- Fix search_path for mask_sensitive_value function
DROP FUNCTION IF EXISTS public.mask_sensitive_value(text, int);

CREATE OR REPLACE FUNCTION public.mask_sensitive_value(value text, visible_chars int DEFAULT 4)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
SET search_path = public
AS $$
BEGIN
  IF value IS NULL OR length(value) <= visible_chars THEN
    RETURN '****';
  END IF;
  RETURN repeat('*', length(value) - visible_chars) || right(value, visible_chars);
END;
$$;

-- Also fix the encrypt/decrypt functions search_path
DROP FUNCTION IF EXISTS public.encrypt_sensitive_data(text);
DROP FUNCTION IF EXISTS public.decrypt_sensitive_data(text);

-- Recreate encrypt function with proper search_path
CREATE OR REPLACE FUNCTION public.encrypt_sensitive_data(data text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF data IS NULL OR data = '' THEN
    RETURN NULL;
  END IF;
  RETURN encode(
    pgp_sym_encrypt(
      data,
      current_setting('app.encryption_key', true)
    ),
    'base64'
  );
END;
$$;

-- Recreate decrypt function with proper search_path  
CREATE OR REPLACE FUNCTION public.decrypt_sensitive_data(encrypted_data text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF encrypted_data IS NULL OR encrypted_data = '' THEN
    RETURN NULL;
  END IF;
  
  IF NOT (public.is_admin_or_hr()) THEN
    RETURN '***HIDDEN***';
  END IF;
  
  RETURN pgp_sym_decrypt(
    decode(encrypted_data, 'base64'),
    current_setting('app.encryption_key', true)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN encrypted_data;
END;
$$;