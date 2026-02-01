import { Response } from 'express';

interface SuccessResponse<T> {
  success: true;
  data: T;
  message?: string;
  meta?: {
    page?: number;
    limit?: number;
    total?: number;
    totalPages?: number;
  };
}

interface ErrorResponse {
  success: false;
  error: {
    code?: string;
    message: string;
    details?: unknown;
  };
}

export const sendSuccess = <T>(
  res: Response,
  data: T,
  statusCode = 200,
  message?: string,
  meta?: SuccessResponse<T>['meta']
): Response => {
  const response: SuccessResponse<T> = {
    success: true,
    data,
    ...(message && { message }),
    ...(meta && { meta }),
  };
  return res.status(statusCode).json(response);
};

export const sendError = (
  res: Response,
  statusCode: number,
  message: string,
  code?: string,
  details?: unknown
): Response => {
  const error: ErrorResponse['error'] = { message };
  if (code) error.code = code;
  if (details !== undefined) error.details = details;

  const response: ErrorResponse = {
    success: false,
    error,
  };
  return res.status(statusCode).json(response);
};

export const sendPaginated = <T>(
  res: Response,
  data: T[],
  page: number,
  limit: number,
  total: number
): Response => {
  return sendSuccess(res, data, 200, undefined, {
    page,
    limit,
    total,
    totalPages: Math.ceil(total / limit),
  });
};
