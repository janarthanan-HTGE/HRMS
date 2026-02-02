-- Drop the security definer view as it has security concerns
DROP VIEW IF EXISTS public.profiles_secure;

-- Instead, we'll handle sensitive data visibility through RLS and application logic
-- The sensitive fields (bank details, PAN, Aadhar) will be masked at the application level
-- based on user role, which is already implemented in the frontend

-- Create a helper function to mask sensitive data for display
CREATE OR REPLACE FUNCTION public.mask_sensitive_value(value text, visible_chars int DEFAULT 4)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
  IF value IS NULL OR length(value) <= visible_chars THEN
    RETURN '****';
  END IF;
  RETURN repeat('*', length(value) - visible_chars) || right(value, visible_chars);
END;
$$;