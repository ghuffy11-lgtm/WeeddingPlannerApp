import { Request, Response, NextFunction } from 'express';
import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { sendSuccess, sendPaginated } from '../utils/response';

// Helper function to recalculate and update wedding.budget_spent
export const updateBudgetSpent = async (weddingId: string): Promise<void> => {
  const budgetItems = await prisma.budget_items.findMany({
    where: { wedding_id: weddingId },
  });
  const totalSpent = budgetItems.reduce(
    (sum, item) => sum + (Number(item.actual_amount) || 0),
    0
  );
  await prisma.weddings.update({
    where: { id: weddingId },
    data: { budget_spent: totalSpent },
  });
};

export const getMyWedding = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
      include: {
        _count: {
          select: {
            guests: true,
            bookings: true,
            tasks: true,
          },
        },
      },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    // Calculate task completion
    const [completedTasks, totalTasks] = await Promise.all([
      prisma.tasks.count({
        where: { wedding_id: wedding.id, is_completed: true },
      }),
      prisma.tasks.count({
        where: { wedding_id: wedding.id },
      }),
    ]);

    sendSuccess(res, {
      ...wedding,
      taskProgress: totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0,
    });
  } catch (error) {
    next(error);
  }
};

export const getMyTasks = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { limit, status, sort, order } = req.query;

    // Find user's wedding first
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    const where: Record<string, unknown> = { wedding_id: wedding.id };
    if (status === 'pending') where.is_completed = false;
    if (status === 'completed') where.is_completed = true;

    const orderBy: Record<string, unknown>[] = [];
    if (sort === 'due_date') {
      orderBy.push({ due_date: order === 'desc' ? 'desc' : 'asc' });
    }
    orderBy.push({ created_at: 'desc' });

    const tasks = await prisma.tasks.findMany({
      where,
      orderBy,
      take: limit ? parseInt(limit as string, 10) : undefined,
    });

    sendSuccess(res, tasks);
  } catch (error) {
    next(error);
  }
};

export const getMyTaskStats = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    // Find user's wedding first
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

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

export const getMyBudgetSummary = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    // Find user's wedding first
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    const budgetItems = await prisma.budget_items.findMany({
      where: { wedding_id: wedding.id },
    });

    // Group by category and calculate totals
    const categoryMap = new Map<string, { estimated: number; actual: number; count: number }>();

    for (const item of budgetItems) {
      const category = item.category || 'Other';
      const existing = categoryMap.get(category) || { estimated: 0, actual: 0, count: 0 };
      categoryMap.set(category, {
        estimated: existing.estimated + (Number(item.estimated_amount) || 0),
        actual: existing.actual + (Number(item.actual_amount) || 0),
        count: existing.count + 1,
      });
    }

    const categories = Array.from(categoryMap.entries()).map(([category, data]) => ({
      category,
      estimatedAmount: data.estimated,
      actualAmount: data.actual,
      itemCount: data.count,
    }));

    const totals = categories.reduce(
      (acc, cat) => ({
        estimated: acc.estimated + cat.estimatedAmount,
        actual: acc.actual + cat.actualAmount,
      }),
      { estimated: 0, actual: 0 }
    );

    sendSuccess(res, {
      categories,
      summary: {
        budgetTotal: Number(wedding.budget_total) || 0,
        estimatedTotal: totals.estimated,
        actualTotal: totals.actual,
        remaining: (Number(wedding.budget_total) || 0) - totals.actual,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const createWedding = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const {
      partner1Name,
      partner2Name,
      weddingDate,
      budgetTotal,
      guestCountExpected,
      stylePreferences,
      culturalTraditions,
      region,
      currency,
    } = req.body;

    // Check if user already has a wedding
    const existingWedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (existingWedding) {
      throw ApiError.conflict('You already have a wedding. Update it instead.');
    }

    const wedding = await prisma.weddings.create({
      data: {
        user_id: userId,
        partner1_name: partner1Name,
        partner2_name: partner2Name,
        wedding_date: weddingDate ? new Date(weddingDate) : null,
        budget_total: budgetTotal,
        guest_count_expected: guestCountExpected,
        style_preferences: stylePreferences || [],
        cultural_traditions: culturalTraditions || [],
        region,
        currency: currency || 'USD',
      },
    });

    sendSuccess(res, wedding, 201, 'Wedding created successfully');
  } catch (error) {
    next(error);
  }
};

export const updateWedding = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const updates = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const updatedWedding = await prisma.weddings.update({
      where: { id },
      data: {
        partner1_name: updates.partner1Name,
        partner2_name: updates.partner2Name,
        wedding_date: updates.weddingDate ? new Date(updates.weddingDate) : undefined,
        budget_total: updates.budgetTotal,
        guest_count_expected: updates.guestCountExpected,
        style_preferences: updates.stylePreferences,
        cultural_traditions: updates.culturalTraditions,
        region: updates.region,
        currency: updates.currency,
        updated_at: new Date(),
      },
    });

    sendSuccess(res, updatedWedding, 200, 'Wedding updated successfully');
  } catch (error) {
    next(error);
  }
};

// Guest management

export const getGuests = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const { page = '1', limit = '50', group, rsvpStatus } = req.query;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const where: Record<string, unknown> = { wedding_id: id };
    if (group) where.group_name = group;
    if (rsvpStatus) where.rsvp_status = rsvpStatus;

    const [guests, total] = await Promise.all([
      prisma.guests.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { name: 'asc' },
      }),
      prisma.guests.count({ where }),
    ]);

    sendPaginated(res, guests, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

export const addGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const guestData = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const guest = await prisma.guests.create({
      data: {
        wedding_id: id,
        name: guestData.name,
        email: guestData.email,
        phone: guestData.phone,
        group_name: guestData.groupName,
        plus_one_allowed: guestData.plusOneAllowed || false,
        meal_preference: guestData.mealPreference,
        dietary_restrictions: guestData.dietaryRestrictions,
        table_assignment: guestData.tableAssignment,
      },
    });

    sendSuccess(res, guest, 201, 'Guest added successfully');
  } catch (error) {
    next(error);
  }
};

export const updateGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id, guestId } = req.params;
    const updates = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const guest = await prisma.guests.update({
      where: { id: guestId },
      data: {
        name: updates.name,
        email: updates.email,
        phone: updates.phone,
        group_name: updates.groupName,
        rsvp_status: updates.rsvpStatus,
        plus_one_allowed: updates.plusOneAllowed,
        plus_one_name: updates.plusOneName,
        plus_one_attending: updates.plusOneAttending,
        meal_preference: updates.mealPreference,
        dietary_restrictions: updates.dietaryRestrictions,
        song_request: updates.songRequest,
        message_to_couple: updates.messageToCouple,
        table_assignment: updates.tableAssignment,
        responded_at: updates.rsvpStatus ? new Date() : undefined,
      },
    });

    sendSuccess(res, guest, 200, 'Guest updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deleteGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id, guestId } = req.params;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    await prisma.guests.delete({
      where: { id: guestId },
    });

    sendSuccess(res, null, 200, 'Guest deleted successfully');
  } catch (error) {
    next(error);
  }
};

// Budget management

export const getBudget = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const budgetItems = await prisma.budget_items.findMany({
      where: { wedding_id: id },
      include: {
        vendor: {
          select: { id: true, business_name: true },
        },
      },
      orderBy: { category: 'asc' },
    });

    // Calculate totals
    const totals = budgetItems.reduce(
      (acc, item) => {
        acc.estimated += Number(item.estimated_amount) || 0;
        acc.actual += Number(item.actual_amount) || 0;
        return acc;
      },
      { estimated: 0, actual: 0 }
    );

    sendSuccess(res, {
      items: budgetItems,
      summary: {
        budgetTotal: wedding.budget_total,
        estimatedTotal: totals.estimated,
        actualTotal: totals.actual,
        remaining: Number(wedding.budget_total) - totals.actual,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const addBudgetItem = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const itemData = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const item = await prisma.budget_items.create({
      data: {
        wedding_id: id,
        category: itemData.category,
        description: itemData.description,
        estimated_amount: itemData.estimatedAmount,
        actual_amount: itemData.actualAmount,
        vendor_id: itemData.vendorId,
        notes: itemData.notes,
      },
    });

    // Update wedding.budget_spent
    await updateBudgetSpent(id);

    sendSuccess(res, item, 201, 'Budget item added successfully');
  } catch (error) {
    next(error);
  }
};

export const updateBudgetItem = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id, itemId } = req.params;
    const updates = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const item = await prisma.budget_items.update({
      where: { id: itemId },
      data: {
        category: updates.category,
        description: updates.description,
        estimated_amount: updates.estimatedAmount,
        actual_amount: updates.actualAmount,
        is_paid: updates.isPaid,
        paid_date: updates.isPaid ? new Date() : null,
        notes: updates.notes,
      },
    });

    // Update wedding.budget_spent
    await updateBudgetSpent(id);

    sendSuccess(res, item, 200, 'Budget item updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deleteBudgetItem = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id, itemId } = req.params;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    await prisma.budget_items.delete({
      where: { id: itemId },
    });

    // Update wedding.budget_spent
    await updateBudgetSpent(id);

    sendSuccess(res, null, 200, 'Budget item deleted successfully');
  } catch (error) {
    next(error);
  }
};

// Task management

export const getTasks = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const { completed, category, priority } = req.query;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const where: Record<string, unknown> = { wedding_id: id };
    if (completed !== undefined) where.is_completed = completed === 'true';
    if (category) where.category = category;
    if (priority) where.priority = priority;

    const tasks = await prisma.tasks.findMany({
      where,
      orderBy: [{ is_completed: 'asc' }, { due_date: 'asc' }, { priority: 'desc' }],
    });

    sendSuccess(res, tasks);
  } catch (error) {
    next(error);
  }
};

export const addTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const taskData = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    // Determine status and is_completed
    const status = taskData.status || 'pending';
    const isCompleted = taskData.isCompleted ?? status === 'completed';

    const task = await prisma.tasks.create({
      data: {
        wedding_id: id,
        title: taskData.title,
        description: taskData.description,
        due_date: taskData.dueDate ? new Date(taskData.dueDate) : null,
        priority: taskData.priority || 'medium',
        category: taskData.category,
        status: status,
        is_completed: isCompleted,
        completed_at: isCompleted ? new Date() : null,
        linked_vendor_id: taskData.vendorId,
        is_custom: true,
      },
    });

    sendSuccess(res, task, 201, 'Task added successfully');
  } catch (error) {
    next(error);
  }
};

export const updateTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id, taskId } = req.params;
    const updates = req.body;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    // Determine status and is_completed
    let status = updates.status;
    let isCompleted = updates.isCompleted;

    if (status !== undefined) {
      isCompleted = status === 'completed';
    } else if (isCompleted !== undefined) {
      status = isCompleted ? 'completed' : 'pending';
    }

    const task = await prisma.tasks.update({
      where: { id: taskId },
      data: {
        title: updates.title,
        description: updates.description,
        due_date: updates.dueDate ? new Date(updates.dueDate) : undefined,
        is_completed: isCompleted,
        status: status,
        completed_at: isCompleted ? new Date() : null,
        priority: updates.priority,
        category: updates.category,
      },
    });

    sendSuccess(res, task, 200, 'Task updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deleteTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id, taskId } = req.params;

    // Verify ownership
    const wedding = await prisma.weddings.findFirst({
      where: { id, user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    await prisma.tasks.delete({
      where: { id: taskId },
    });

    sendSuccess(res, null, 200, 'Task deleted successfully');
  } catch (error) {
    next(error);
  }
};

// Task management for /me routes

export const getMyTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { taskId } = req.params;

    // Find user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    // Find task that belongs to user's wedding
    const task = await prisma.tasks.findFirst({
      where: { id: taskId, wedding_id: wedding.id },
    });

    if (!task) {
      throw ApiError.notFound('Task not found');
    }

    sendSuccess(res, task);
  } catch (error) {
    next(error);
  }
};

export const createMyTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const taskData = req.body;

    // Find user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    // Determine status and is_completed
    const status = taskData.status || 'pending';
    const isCompleted = taskData.isCompleted ?? status === 'completed';

    const task = await prisma.tasks.create({
      data: {
        wedding_id: wedding.id,
        title: taskData.title,
        description: taskData.description,
        due_date: taskData.dueDate ? new Date(taskData.dueDate) : null,
        priority: taskData.priority || 'medium',
        category: taskData.category,
        status: status,
        is_completed: isCompleted,
        completed_at: isCompleted ? new Date() : null,
        linked_vendor_id: taskData.vendorId,
        is_custom: true,
      },
    });

    sendSuccess(res, task, 201, 'Task created successfully');
  } catch (error) {
    next(error);
  }
};

export const updateMyTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { taskId } = req.params;
    const updates = req.body;

    // Find user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    // Verify task belongs to user's wedding
    const existingTask = await prisma.tasks.findFirst({
      where: { id: taskId, wedding_id: wedding.id },
    });

    if (!existingTask) {
      throw ApiError.notFound('Task not found');
    }

    // Determine status and is_completed
    // If status is provided, derive is_completed from it
    // If only isCompleted is provided, derive status from it
    let status = updates.status;
    let isCompleted = updates.isCompleted;

    if (status !== undefined) {
      // Status provided - derive isCompleted from status
      isCompleted = status === 'completed';
    } else if (isCompleted !== undefined) {
      // Only isCompleted provided - derive status from it
      status = isCompleted ? 'completed' : existingTask.status || 'pending';
    }

    const task = await prisma.tasks.update({
      where: { id: taskId },
      data: {
        title: updates.title,
        description: updates.description,
        due_date: updates.dueDate ? new Date(updates.dueDate) : undefined,
        is_completed: isCompleted,
        status: status,
        completed_at: isCompleted ? new Date() : null,
        priority: updates.priority,
        category: updates.category,
      },
    });

    sendSuccess(res, task, 200, 'Task updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deleteMyTask = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { taskId } = req.params;

    // Find user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found. Please create one first.');
    }

    // Verify task belongs to user's wedding
    const existingTask = await prisma.tasks.findFirst({
      where: { id: taskId, wedding_id: wedding.id },
    });

    if (!existingTask) {
      throw ApiError.notFound('Task not found');
    }

    await prisma.tasks.delete({
      where: { id: taskId },
    });

    sendSuccess(res, null, 200, 'Task deleted successfully');
  } catch (error) {
    next(error);
  }
};
