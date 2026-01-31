import { Router } from 'express';
import * as userController from '../controllers/user.controller';
import { authenticate } from '../middleware/auth';

const router = Router();

// All routes require authentication
router.use(authenticate);

// GET /api/v1/users/me
router.get('/me', userController.getProfile);

// PUT /api/v1/users/me
router.put('/me', userController.updateProfile);

// DELETE /api/v1/users/me
router.delete('/me', userController.deleteAccount);

// PUT /api/v1/users/me/password
router.put('/me/password', userController.changePassword);

export default router;
