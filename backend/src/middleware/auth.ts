import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { jwtConfig } from '../config/jwt';
import { ApiError } from '../utils/ApiError';
import { prisma } from '../config/database';

export interface AuthPayload {
  userId: string;
  userType: 'couple' | 'vendor' | 'guest';
  email: string;
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthPayload;
    }
  }
}

export const authenticate = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw ApiError.unauthorized('No token provided');
    }

    const token = authHeader.substring(7);

    const decoded = jwt.verify(token, jwtConfig.accessToken.secret) as AuthPayload;

    // Verify user still exists and is active
    const user = await prisma.users.findUnique({
      where: { id: decoded.userId },
      select: { id: true, is_active: true },
    });

    if (!user || !user.is_active) {
      throw ApiError.unauthorized('User not found or inactive');
    }

    req.user = decoded;
    next();
  } catch (error) {
    if (error instanceof ApiError) {
      next(error);
    } else if (error instanceof jwt.JsonWebTokenError) {
      next(ApiError.unauthorized('Invalid token'));
    } else if (error instanceof jwt.TokenExpiredError) {
      next(ApiError.unauthorized('Token expired'));
    } else {
      next(error);
    }
  }
};

export const requireUserType = (...types: ('couple' | 'vendor' | 'guest')[]) => {
  return (req: Request, _res: Response, next: NextFunction): void => {
    if (!req.user) {
      next(ApiError.unauthorized());
      return;
    }

    if (!types.includes(req.user.userType)) {
      next(ApiError.forbidden('You do not have permission to access this resource'));
      return;
    }

    next();
  };
};

// Admin authentication (separate from user auth)
export interface AdminPayload {
  adminId: string;
  role: 'admin' | 'super_admin';
  email: string;
}

declare global {
  namespace Express {
    interface Request {
      admin?: AdminPayload;
    }
  }
}

export const authenticateAdmin = async (
  req: Request,
  _res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw ApiError.unauthorized('No token provided');
    }

    const token = authHeader.substring(7);

    const decoded = jwt.verify(token, jwtConfig.accessToken.secret) as AdminPayload;

    // Verify admin still exists and is active
    const admin = await prisma.admins.findUnique({
      where: { id: decoded.adminId },
      select: { id: true, is_active: true },
    });

    if (!admin || !admin.is_active) {
      throw ApiError.unauthorized('Admin not found or inactive');
    }

    req.admin = decoded;
    next();
  } catch (error) {
    if (error instanceof ApiError) {
      next(error);
    } else if (error instanceof jwt.JsonWebTokenError) {
      next(ApiError.unauthorized('Invalid token'));
    } else if (error instanceof jwt.TokenExpiredError) {
      next(ApiError.unauthorized('Token expired'));
    } else {
      next(error);
    }
  }
};

export const requireSuperAdmin = (
  req: Request,
  _res: Response,
  next: NextFunction
): void => {
  if (!req.admin || req.admin.role !== 'super_admin') {
    next(ApiError.forbidden('Super admin access required'));
    return;
  }
  next();
};
