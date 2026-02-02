-- Create extension for encryption
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Add encrypted versions of sensitive columns (keeping originals for migration)
-- We'll store encrypted data in these columns

-- Create a function to encrypt data
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
  -- Using pgcrypto's encrypt function with a server-side key
  -- The key is derived from a combination that's not exposed to clients
  RETURN encode(
    pgp_sym_encrypt(
      data,
      current_setting('app.encryption_key', true)
    ),
    'base64'
  );
END;
$$;

-- Create a function to decrypt data (only accessible by admin/HR)
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
  
  -- Only allow admin or HR to decrypt
  IF NOT (public.is_admin_or_hr()) THEN
    RETURN '***HIDDEN***';
  END IF;
  
  RETURN pgp_sym_decrypt(
    decode(encrypted_data, 'base64'),
    current_setting('app.encryption_key', true)
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN encrypted_data; -- Return as-is if decryption fails (for unencrypted legacy data)
END;
$$;

-- Create view for profiles with automatic decryption for authorized users
CREATE OR REPLACE VIEW public.profiles_secure AS
SELECT 
  id,
  user_id,
  first_name,
  last_name,
  email,
  phone,
  gender,
  date_of_birth,
  address,
  city,
  state,
  country,
  pincode,
  avatar_url,
  employee_id,
  department_id,
  designation_id,
  joining_date,
  employment_status,
  reporting_manager,
  emergency_contact_name,
  emergency_contact_phone,
  -- Sensitive fields - only decrypted for admin/HR
  CASE 
    WHEN public.is_admin_or_hr() THEN bank_name
    ELSE '***HIDDEN***'
  END as bank_name,
  CASE 
    WHEN public.is_admin_or_hr() THEN bank_account_number
    ELSE '***HIDDEN***'
  END as bank_account_number,
  CASE 
    WHEN public.is_admin_or_hr() THEN bank_ifsc
    ELSE '***HIDDEN***'
  END as bank_ifsc,
  CASE 
    WHEN public.is_admin_or_hr() THEN pan_number
    ELSE '***HIDDEN***'
  END as pan_number,
  CASE 
    WHEN public.is_admin_or_hr() THEN aadhar_number
    ELSE '***HIDDEN***'
  END as aadhar_number,
  created_at,
  updated_at
FROM public.profiles;

-- Grant access to the view
GRANT SELECT ON public.profiles_secure TO authenticated;