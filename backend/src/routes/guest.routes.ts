import { Router } from 'express';
import { authenticate, requireUserType } from '../middleware/auth';
import * as guestController from '../controllers/guest.controller';

const router = Router();

// All routes require authentication and couple user type
router.use(authenticate, requireUserType('couple'));

// GET /api/v1/guests - List guests
router.get('/', guestController.getGuests);

// POST /api/v1/guests - Create guest
router.post('/', guestController.createGuest);

// GET /api/v1/guests/stats - Get guest statistics
router.get('/stats', guestController.getGuestStats);

// POST /api/v1/guests/invite-bulk - Send bulk invitations
router.post('/invite-bulk', guestController.sendBulkInvitations);

// GET /api/v1/guests/:id - Get single guest
router.get('/:id', guestController.getGuest);

// PUT /api/v1/guests/:id - Update guest
router.put('/:id', guestController.updateGuest);

// DELETE /api/v1/guests/:id - Delete guest
router.delete('/:id', guestController.deleteGuest);

// PATCH /api/v1/guests/:id/rsvp - Update RSVP status
router.patch('/:id/rsvp', guestController.updateRsvpStatus);

// POST /api/v1/guests/:id/invite - Send invitation to guest
router.post('/:id/invite', guestController.sendInvitation);

export default router;
