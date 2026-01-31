import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/ApiError';
import { sendError } from '../utils/response';
import { logger } from '../utils/logger';
import { Prisma } from '@prisma/client';

export const errorHandler = (
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): Response => {
  // Log the error
  logger.error(err);

  // Handle known API errors
  if (err instanceof ApiError) {
    return sendError(res, err.statusCode, err.message, err.code);
  }

  // Handle Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    switch (err.code) {
      case 'P2002':
        return sendError(res, 409, 'A record with this value already exists', 'DUPLICATE_ENTRY');
      case 'P2025':
        return sendError(res, 404, 'Record not found', 'NOT_FOUND');
      case 'P2003':
        return sendError(res, 400, 'Invalid reference', 'INVALID_REFERENCE');
      default:
        return sendError(res, 400, 'Database error', 'DATABASE_ERROR');
    }
  }

  if (err instanceof Prisma.PrismaClientValidationError) {
    return sendError(res, 400, 'Invalid data provided', 'VALIDATION_ERROR');
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    return sendError(res, 401, 'Invalid token', 'INVALID_TOKEN');
  }

  if (err.name === 'TokenExpiredError') {
    return sendError(res, 401, 'Token expired', 'TOKEN_EXPIRED');
  }

  // Handle validation errors
  if (err.name === 'ValidationError') {
    return sendError(res, 400, err.message, 'VALIDATION_ERROR');
  }

  // Default to 500 internal server error
  const statusCode = 500;
  const message =
    process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message;

  return sendError(res, statusCode, message, 'INTERNAL_ERROR');
};
