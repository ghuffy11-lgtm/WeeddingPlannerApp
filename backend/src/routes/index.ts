import { Router } from 'express';
import authRoutes from './auth.routes';
import userRoutes from './user.routes';
import vendorRoutes from './vendor.routes';
import weddingRoutes from './wedding.routes';
import bookingRoutes from './booking.routes';
import categoryRoutes from './category.routes';

const router = Router();

// Public routes
router.use('/auth', authRoutes);
router.use('/categories', categoryRoutes);
router.use('/vendors', vendorRoutes);

// Protected routes
router.use('/users', userRoutes);
router.use('/weddings', weddingRoutes);
router.use('/bookings', bookingRoutes);

export default router;
