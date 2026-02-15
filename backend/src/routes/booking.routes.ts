import { Router } from 'express';
import * as bookingController from '../controllers/booking.controller';
import { authenticate, requireUserType } from '../middleware/auth';

const router = Router();

// All routes require authentication
router.use(authenticate);

// Couple routes
// GET /api/v1/bookings - alias for my-bookings (used by Flutter app)
router.get('/', requireUserType('couple'), bookingController.getMyBookings);

// GET /api/v1/bookings/my-bookings
router.get('/my-bookings', requireUserType('couple'), bookingController.getMyBookings);

// POST /api/v1/bookings
router.post('/', requireUserType('couple'), bookingController.createBooking);

// GET /api/v1/bookings/:id
router.get('/:id', bookingController.getBooking);

// PUT /api/v1/bookings/:id/cancel
router.put('/:id/cancel', requireUserType('couple'), bookingController.cancelBooking);

// POST /api/v1/bookings/:id/review
router.post('/:id/review', requireUserType('couple'), bookingController.addReview);

// Vendor routes
// GET /api/v1/bookings/vendor/requests
router.get('/vendor/requests', requireUserType('vendor'), bookingController.getVendorRequests);

// GET /api/v1/bookings/vendor/all
router.get('/vendor/all', requireUserType('vendor'), bookingController.getVendorBookings);

// POST /api/v1/bookings/:id/accept - Accept booking (changed from PUT to POST per API docs)
router.post('/:id/accept', requireUserType('vendor'), bookingController.acceptBooking);

// POST /api/v1/bookings/:id/decline - Decline booking (changed from PUT to POST per API docs)
router.post('/:id/decline', requireUserType('vendor'), bookingController.declineBooking);

// POST /api/v1/bookings/:id/complete - Complete booking (changed from PUT to POST per API docs)
router.post('/:id/complete', requireUserType('vendor'), bookingController.completeBooking);

export default router;
