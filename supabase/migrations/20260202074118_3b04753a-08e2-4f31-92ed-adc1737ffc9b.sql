-- Allow HR to also delete goalsheets
DROP POLICY IF EXISTS "Only admin can delete goalsheets" ON public.goalsheets;
CREATE POLICY "Admin and HR can delete goalsheets" 
ON public.goalsheets 
FOR DELETE 
USING (is_admin_or_hr());

-- Allow HR to also delete goal items
DROP POLICY IF EXISTS "Only admin can delete goal items" ON public.goal_items;
CREATE POLICY "Admin and HR can delete goal items" 
ON public.goal_items 
FOR DELETE 
USING (is_admin_or_hr());

-- Update goal_items foreign key to cascade delete when goalsheet is deleted
ALTER TABLE public.goal_items 
DROP CONSTRAINT IF EXISTS goal_items_goalsheet_id_fkey;

ALTER TABLE public.goal_items 
ADD CONSTRAINT goal_items_goalsheet_id_fkey 
FOREIGN KEY (goalsheet_id) 
REFERENCES public.goalsheets(id) 
ON DELETE CASCADE;

-- Add cascade delete for all user-related tables when profile is deleted
-- First, add ON DELETE CASCADE to all tables that reference profiles

-- Attendance
ALTER TABLE public.attendance 
DROP CONSTRAINT IF EXISTS attendance_profile_id_fkey;
ALTER TABLE public.attendance 
ADD CONSTRAINT attendance_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Goalsheets
ALTER TABLE public.goalsheets 
DROP CONSTRAINT IF EXISTS goalsheets_profile_id_fkey;
ALTER TABLE public.goalsheets 
ADD CONSTRAINT goalsheets_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Leaves
ALTER TABLE public.leaves 
DROP CONSTRAINT IF EXISTS leaves_profile_id_fkey;
ALTER TABLE public.leaves 
ADD CONSTRAINT leaves_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Leave balances
ALTER TABLE public.leave_balances 
DROP CONSTRAINT IF EXISTS leave_balances_profile_id_fkey;
ALTER TABLE public.leave_balances 
ADD CONSTRAINT leave_balances_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Payroll
ALTER TABLE public.payroll 
DROP CONSTRAINT IF EXISTS payroll_profile_id_fkey;
ALTER TABLE public.payroll 
ADD CONSTRAINT payroll_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Payslips
ALTER TABLE public.payslips 
DROP CONSTRAINT IF EXISTS payslips_profile_id_fkey;
ALTER TABLE public.payslips 
ADD CONSTRAINT payslips_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Tasks
ALTER TABLE public.tasks 
DROP CONSTRAINT IF EXISTS tasks_assigned_to_fkey;
ALTER TABLE public.tasks 
ADD CONSTRAINT tasks_assigned_to_fkey 
FOREIGN KEY (assigned_to) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Timesheets
ALTER TABLE public.timesheets 
DROP CONSTRAINT IF EXISTS timesheets_profile_id_fkey;
ALTER TABLE public.timesheets 
ADD CONSTRAINT timesheets_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;

-- Training
ALTER TABLE public.training 
DROP CONSTRAINT IF EXISTS training_profile_id_fkey;
ALTER TABLE public.training 
ADD CONSTRAINT training_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES public.profiles(id) 
ON DELETE CASCADE;