import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { sendSuccess } from '../utils/response';

export const getProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const user = await prisma.users.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        user_type: true,
        email_verified: true,
        phone_verified: true,
        created_at: true,
      },
    });

    if (!user) {
      throw ApiError.notFound('User not found');
    }

    sendSuccess(res, user);
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { phone } = req.body;

    const user = await prisma.users.update({
      where: { id: userId },
      data: {
        phone,
        updated_at: new Date(),
      },
      select: {
        id: true,
        email: true,
        phone: true,
        user_type: true,
        email_verified: true,
        phone_verified: true,
      },
    });

    sendSuccess(res, user, 200, 'Profile updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deleteAccount = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    // Soft delete - just deactivate the account
    await prisma.users.update({
      where: { id: userId },
      data: {
        is_active: false,
        updated_at: new Date(),
      },
    });

    sendSuccess(res, null, 200, 'Account deleted successfully');
  } catch (error) {
    next(error);
  }
};

export const changePassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { currentPassword, newPassword } = req.body;

    const user = await prisma.users.findUnique({
      where: { id: userId },
    });

    if (!user || !user.password_hash) {
      throw ApiError.notFound('User not found');
    }

    // Verify current password
    const isValidPassword = await bcrypt.compare(
      currentPassword,
      user.password_hash
    );

    if (!isValidPassword) {
      throw ApiError.badRequest('Current password is incorrect');
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(newPassword, salt);

    // Update password
    await prisma.users.update({
      where: { id: userId },
      data: {
        password_hash: passwordHash,
        updated_at: new Date(),
      },
    });

    sendSuccess(res, null, 200, 'Password changed successfully');
  } catch (error) {
    next(error);
  }
};
