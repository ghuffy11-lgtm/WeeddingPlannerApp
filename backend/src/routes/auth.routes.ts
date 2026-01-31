import { Router } from 'express';
import * as authController from '../controllers/auth.controller';
import { validate } from '../middleware/validate';
import { registerSchema, loginSchema, refreshTokenSchema } from '../validators/auth.validator';

const router = Router();

// POST /api/v1/auth/register
router.post('/register', validate(registerSchema), authController.register);

// POST /api/v1/auth/login
router.post('/login', validate(loginSchema), authController.login);

// POST /api/v1/auth/refresh
router.post('/refresh', validate(refreshTokenSchema), authController.refreshToken);

// POST /api/v1/auth/forgot-password
router.post('/forgot-password', authController.forgotPassword);

// POST /api/v1/auth/reset-password
router.post('/reset-password', authController.resetPassword);

// POST /api/v1/auth/verify-email
router.post('/verify-email', authController.verifyEmail);

export default router;
