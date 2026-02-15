import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import vendorRoutes from './vendor.routes';
import weddingRoutes from './wedding.routes';
import bookingRoutes from './booking.routes';
import categoryRoutes from './category.routes';
import taskRoutes from './task.routes';
import guestRoutes from './guest.routes';
import budgetRoutes from './budget.routes';

const router = Router();

// Public routes
router.use('/auth', authRoutes);
router.use('/categories', categoryRoutes);
router.use('/vendors', vendorRoutes);

// Protected routes
router.use('/users', userRoutes);
router.use('/weddings', weddingRoutes);
router.use('/bookings', bookingRoutes);

// Root-level protected routes (as per API documentation)
router.use('/tasks', taskRoutes);
router.use('/guests', guestRoutes);
router.use('/budget', budgetRoutes);

export default router;
