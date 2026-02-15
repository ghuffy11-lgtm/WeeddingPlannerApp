import { Request, Response, NextFunction } from 'express';
import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { sendSuccess, sendPaginated } from '../utils/response';

// Helper function to get user's wedding
async function getUserWedding(userId: string) {
  const wedding = await prisma.weddings.findFirst({
    where: { user_id: userId },
  });

  if (!wedding) {
    throw ApiError.notFound('No wedding found. Please complete onboarding first.');
  }

  return wedding;
}

// GET /tasks - List tasks for current user's wedding
export const getTasks = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const {
      page = '1',
      limit = '20',
      status,
      category,
      priority,
      sort,
      order,
    } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const where: Record<string, unknown> = { wedding_id: wedding.id };

    // Handle status filter
    if (status === 'pending') {
      where.is_completed = false;
    } else if (status === 'completed') {
      where.is_completed = true;
    }

    if (category) where.category = category;
    if (priority) where.priority = priority;

    // Build orderBy
    const orderBy: Record<string, string>[] = [];
    if (sort) {
      const sortField = sort as string;
      const sortOrder = (order as string) || 'asc';
      orderBy.push({ [sortField]: sortOrder });
    } else {
      orderBy.push({ created_at: 'desc' });
    }

    const [tasks, total] = await Promise.all([
      prisma.tasks.findMany({
        where,
        skip,
        take: limitNum,
        orderBy,
      }),
      prisma.tasks.count({ where }),
    ]);

    sendPaginated(res, tasks, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

// POST /tasks - Create task
export const createTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { title, description, dueDate, priority, category, vendorId } = req.body;

    const task = await prisma.tasks.create({
      data: {
        wedding_id: wedding.id,
        title,
        description,
        due_date: dueDate ? new Date(dueDate) : null,
        priority: priority || 'medium',
        category,
        linked_vendor_id: vendorId,
        is_custom: true,
      },
    });

    sendSuccess(res, task, 201, 'Task created successfully');
  } catch (error) {
    next(error);
  }
};

// GET /tasks/stats - Get task statistics
export const getTaskStats = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);

    const [total, completed, overdue] = await Promise.all([
      prisma.tasks.count({ where: { wedding_id: wedding.id } }),
      prisma.tasks.count({ where: { wedding_id: wedding.id, is_completed: true } }),
      prisma.tasks.count({
        where: {
          wedding_id: wedding.id,
          is_completed: false,
          due_date: { lt: new Date() },
        },
      }),
    ]);

    sendSuccess(res, {
      total,
      completed,
      pending: total - completed,
      overdue,
    });
  } catch (error) {
    next(error);
  }
};

// GET /tasks/:id - Get single task
export const getTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    const task = await prisma.tasks.findFirst({
      where: { id, wedding_id: wedding.id },
      include: {
        vendor: {
          select: { id: true, business_name: true },
        },
      },
    });

    if (!task) {
      throw ApiError.notFound('Task not found');
    }

    sendSuccess(res, task);
  } catch (error) {
    next(error);
  }
};

// PUT /tasks/:id - Update task
export const updateTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;
    const { title, description, dueDate, priority, category, isCompleted } = req.body;

    // Verify task belongs to user's wedding
    const existingTask = await prisma.tasks.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingTask) {
      throw ApiError.notFound('Task not found');
    }

    const task = await prisma.tasks.update({
      where: { id },
      data: {
        title,
        description,
        due_date: dueDate ? new Date(dueDate) : undefined,
        priority,
        category,
        is_completed: isCompleted,
        completed_at: isCompleted ? new Date() : isCompleted === false ? null : undefined,
      },
    });

    sendSuccess(res, task, 200, 'Task updated successfully');
  } catch (error) {
    next(error);
  }
};

// DELETE /tasks/:id - Delete task
export const deleteTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    // Verify task belongs to user's wedding
    const existingTask = await prisma.tasks.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingTask) {
      throw ApiError.notFound('Task not found');
    }

    await prisma.tasks.delete({
      where: { id },
    });

    sendSuccess(res, null, 200, 'Task deleted successfully');
  } catch (error) {
    next(error);
  }
};

// PATCH /tasks/:id/complete - Mark task as complete
export const completeTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    // Verify task belongs to user's wedding
    const existingTask = await prisma.tasks.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingTask) {
      throw ApiError.notFound('Task not found');
    }

    const task = await prisma.tasks.update({
      where: { id },
      data: {
        is_completed: true,
        completed_at: new Date(),
      },
    });

    sendSuccess(res, task, 200, 'Task marked as complete');
  } catch (error) {
    next(error);
  }
};
