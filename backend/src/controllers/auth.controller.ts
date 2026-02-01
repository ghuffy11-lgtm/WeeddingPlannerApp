import { Request, Response, NextFunction } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../config/database';
import { jwtConfig } from '../config/jwt';
import { cache } from '../config/redis';
import { ApiError } from '../utils/ApiError';
import { sendSuccess } from '../utils/response';
import { AuthPayload } from '../middleware/auth';

const generateTokens = (payload: AuthPayload) => {
  const accessToken = jwt.sign(payload, jwtConfig.accessToken.secret, {
    expiresIn: jwtConfig.accessToken.expiresIn as string,
  } as jwt.SignOptions);

  const refreshToken = jwt.sign(
    { ...payload, tokenId: uuidv4() },
    jwtConfig.refreshToken.secret,
    { expiresIn: jwtConfig.refreshToken.expiresIn as string } as jwt.SignOptions
  );

  return { accessToken, refreshToken };
};

export const register = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password, phone, userType } = req.body;

    // Check if user already exists
    const existingUser = await prisma.users.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw ApiError.conflict('User with this email already exists');
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Create user
    const user = await prisma.users.create({
      data: {
        email,
        password_hash: passwordHash,
        phone,
        user_type: userType,
      },
    });

    // Generate tokens
    const payload: AuthPayload = {
      userId: user.id,
      userType: user.user_type as 'couple' | 'vendor' | 'guest',
      email: user.email,
    };

    const tokens = generateTokens(payload);

    sendSuccess(
      res,
      {
        user: {
          id: user.id,
          email: user.email,
          userType: user.user_type,
        },
        ...tokens,
      },
      201,
      'Registration successful'
    );
  } catch (error) {
    next(error);
  }
};

export const login = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = await prisma.users.findUnique({
      where: { email },
    });

    if (!user || !user.password_hash) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    if (!user.is_active) {
      throw ApiError.unauthorized('Account is deactivated');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);

    if (!isValidPassword) {
      throw ApiError.unauthorized('Invalid email or password');
    }

    // Generate tokens
    const payload: AuthPayload = {
      userId: user.id,
      userType: user.user_type as 'couple' | 'vendor' | 'guest',
      email: user.email,
    };

    const tokens = generateTokens(payload);

    sendSuccess(res, {
      user: {
        id: user.id,
        email: user.email,
        userType: user.user_type,
        emailVerified: user.email_verified,
      },
      ...tokens,
    });
  } catch (error) {
    next(error);
  }
};

export const refreshToken = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { refreshToken } = req.body;

    // Verify refresh token
    const decoded = jwt.verify(
      refreshToken,
      jwtConfig.refreshToken.secret
    ) as AuthPayload & { tokenId: string };

    // Check if token is blacklisted
    const isBlacklisted = await cache.get(`blacklist:${decoded.tokenId}`);
    if (isBlacklisted) {
      throw ApiError.unauthorized('Token has been revoked');
    }

    // Verify user still exists
    const user = await prisma.users.findUnique({
      where: { id: decoded.userId },
    });

    if (!user || !user.is_active) {
      throw ApiError.unauthorized('User not found or inactive');
    }

    // Generate new tokens
    const payload: AuthPayload = {
      userId: user.id,
      userType: user.user_type as 'couple' | 'vendor' | 'guest',
      email: user.email,
    };

    const tokens = generateTokens(payload);

    sendSuccess(res, tokens);
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      next(ApiError.unauthorized('Invalid refresh token'));
    } else {
      next(error);
    }
  }
};

export const forgotPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email } = req.body;

    const user = await prisma.users.findUnique({
      where: { email },
    });

    // Don't reveal if user exists
    if (user) {
      // Generate reset token
      const resetToken = uuidv4();

      // Store in Redis with 1 hour expiry
      await cache.set(`reset:${resetToken}`, user.id, 3600);

      // TODO: Send email with reset link
      // await sendResetPasswordEmail(user.email, resetToken);
    }

    sendSuccess(
      res,
      null,
      200,
      'If an account with that email exists, a password reset link has been sent'
    );
  } catch (error) {
    next(error);
  }
};

export const resetPassword = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token, password } = req.body;

    // Get user ID from token
    const userId = await cache.get<string>(`reset:${token}`);

    if (!userId) {
      throw ApiError.badRequest('Invalid or expired reset token');
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    // Update password
    await prisma.users.update({
      where: { id: userId },
      data: { password_hash: passwordHash },
    });

    // Delete reset token
    await cache.del(`reset:${token}`);

    sendSuccess(res, null, 200, 'Password reset successful');
  } catch (error) {
    next(error);
  }
};

export const verifyEmail = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { token } = req.body;

    // Get user ID from token
    const userId = await cache.get<string>(`verify:${token}`);

    if (!userId) {
      throw ApiError.badRequest('Invalid or expired verification token');
    }

    // Update user
    await prisma.users.update({
      where: { id: userId },
      data: { email_verified: true },
    });

    // Delete verification token
    await cache.del(`verify:${token}`);

    sendSuccess(res, null, 200, 'Email verified successfully');
  } catch (error) {
    next(error);
  }
};
