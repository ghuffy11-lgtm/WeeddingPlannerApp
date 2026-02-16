-- Migration: Fix guest rsvp_status constraint
-- Changes 'accepted' to 'confirmed' to match frontend expectations

-- Step 1: Update any existing 'accepted' status to 'confirmed'
UPDATE guests SET rsvp_status = 'confirmed' WHERE rsvp_status = 'accepted';

-- Step 2: Drop the old constraint
ALTER TABLE guests DROP CONSTRAINT IF EXISTS guests_rsvp_status_check;

-- Step 3: Add the new constraint with 'confirmed' instead of 'accepted'
ALTER TABLE guests ADD CONSTRAINT guests_rsvp_status_check
  CHECK (rsvp_status IN ('pending', 'confirmed', 'declined'));

-- Verify the change
DO $$
BEGIN
    RAISE NOTICE 'Migration complete: guest rsvp_status constraint updated to use confirmed instead of accepted';
END $$;
