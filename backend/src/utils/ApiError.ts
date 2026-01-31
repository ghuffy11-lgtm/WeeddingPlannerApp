export class ApiError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;
  public readonly code?: string;

  constructor(
    statusCode: number,
    message: string,
    isOperational = true,
    code?: string
  ) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.code = code;

    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(message: string, code?: string): ApiError {
    return new ApiError(400, message, true, code);
  }

  static unauthorized(message = 'Unauthorized'): ApiError {
    return new ApiError(401, message, true, 'UNAUTHORIZED');
  }

  static forbidden(message = 'Forbidden'): ApiError {
    return new ApiError(403, message, true, 'FORBIDDEN');
  }

  static notFound(message = 'Resource not found'): ApiError {
    return new ApiError(404, message, true, 'NOT_FOUND');
  }

  static conflict(message: string): ApiError {
    return new ApiError(409, message, true, 'CONFLICT');
  }

  static tooManyRequests(message = 'Too many requests'): ApiError {
    return new ApiError(429, message, true, 'TOO_MANY_REQUESTS');
  }

  static internal(message = 'Internal server error'): ApiError {
    return new ApiError(500, message, false, 'INTERNAL_ERROR');
  }
}
