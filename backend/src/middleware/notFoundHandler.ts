import { Request, Response } from 'express';
import { sendError } from '../utils/response';

export const notFoundHandler = (_req: Request, res: Response): Response => {
  return sendError(res, 404, 'Route not found', 'ROUTE_NOT_FOUND');
};
