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

// GET /budget - Get budget overview
export const getBudget = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);

    const budgetItems = await prisma.budget_items.findMany({
      where: { wedding_id: wedding.id },
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
        acc.paid += item.is_paid ? Number(item.actual_amount) || 0 : 0;
        return acc;
      },
      { estimated: 0, actual: 0, paid: 0 }
    );

    sendSuccess(res, {
      items: budgetItems,
      summary: {
        budgetTotal: Number(wedding.budget_total) || 0,
        estimatedTotal: totals.estimated,
        actualTotal: totals.actual,
        paidTotal: totals.paid,
        remaining: (Number(wedding.budget_total) || 0) - totals.actual,
        unpaid: totals.actual - totals.paid,
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /budget/summary - Get budget summary with category breakdown
export const getBudgetSummary = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);

    const budgetItems = await prisma.budget_items.findMany({
      where: { wedding_id: wedding.id },
    });

    // Group by category and calculate totals
    const categoryMap = new Map<string, { estimated: number; actual: number; paid: number; count: number }>();

    for (const item of budgetItems) {
      const category = item.category || 'Other';
      const existing = categoryMap.get(category) || { estimated: 0, actual: 0, paid: 0, count: 0 };
      categoryMap.set(category, {
        estimated: existing.estimated + (Number(item.estimated_amount) || 0),
        actual: existing.actual + (Number(item.actual_amount) || 0),
        paid: existing.paid + (item.is_paid ? Number(item.actual_amount) || 0 : 0),
        count: existing.count + 1,
      });
    }

    const categories = Array.from(categoryMap.entries()).map(([category, data]) => ({
      category,
      estimatedAmount: data.estimated,
      actualAmount: data.actual,
      paidAmount: data.paid,
      itemCount: data.count,
    }));

    const totals = categories.reduce(
      (acc, cat) => ({
        estimated: acc.estimated + cat.estimatedAmount,
        actual: acc.actual + cat.actualAmount,
        paid: acc.paid + cat.paidAmount,
      }),
      { estimated: 0, actual: 0, paid: 0 }
    );

    sendSuccess(res, {
      categories,
      summary: {
        budgetTotal: Number(wedding.budget_total) || 0,
        estimatedTotal: totals.estimated,
        actualTotal: totals.actual,
        paidTotal: totals.paid,
        remaining: (Number(wedding.budget_total) || 0) - totals.actual,
        unpaid: totals.actual - totals.paid,
      },
    });
  } catch (error) {
    next(error);
  }
};

// PUT /budget/total - Update total budget
export const updateTotalBudget = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { budgetTotal } = req.body;

    if (budgetTotal === undefined || budgetTotal < 0) {
      throw ApiError.badRequest('Please provide a valid budget total');
    }

    const updatedWedding = await prisma.weddings.update({
      where: { id: wedding.id },
      data: {
        budget_total: budgetTotal,
        updated_at: new Date(),
      },
    });

    sendSuccess(res, { budgetTotal: updatedWedding.budget_total }, 200, 'Budget total updated successfully');
  } catch (error) {
    next(error);
  }
};

// GET /budget/expenses - List expenses
export const getExpenses = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { page = '1', limit = '50', category, isPaid } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const where: Record<string, unknown> = { wedding_id: wedding.id };

    if (category) where.category = category;
    if (isPaid !== undefined) where.is_paid = isPaid === 'true';

    const [expenses, total] = await Promise.all([
      prisma.budget_items.findMany({
        where,
        skip,
        take: limitNum,
        include: {
          vendor: {
            select: { id: true, business_name: true },
          },
        },
        orderBy: [{ category: 'asc' }, { created_at: 'desc' }],
      }),
      prisma.budget_items.count({ where }),
    ]);

    sendPaginated(res, expenses, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

// POST /budget/expenses - Create expense
export const createExpense = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const {
      category,
      description,
      estimatedAmount,
      actualAmount,
      vendorId,
      notes,
    } = req.body;

    const expense = await prisma.budget_items.create({
      data: {
        wedding_id: wedding.id,
        category,
        description,
        estimated_amount: estimatedAmount,
        actual_amount: actualAmount,
        vendor_id: vendorId,
        notes,
      },
    });

    sendSuccess(res, expense, 201, 'Expense created successfully');
  } catch (error) {
    next(error);
  }
};

// GET /budget/expenses/upcoming - Get unpaid expenses
export const getUpcomingPayments = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);

    // Returns all unpaid expenses (due_date not in current schema)
    const upcomingPayments = await prisma.budget_items.findMany({
      where: {
        wedding_id: wedding.id,
        is_paid: false,
      },
      include: {
        vendor: {
          select: { id: true, business_name: true },
        },
      },
      orderBy: { created_at: 'desc' },
    });

    sendSuccess(res, upcomingPayments);
  } catch (error) {
    next(error);
  }
};

// GET /budget/expenses/overdue - Get overdue payments
export const getOverduePayments = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);

    // Note: due_date column not in current schema, returning empty array
    // When due_date is added, this will filter by past due dates
    sendSuccess(res, []);
  } catch (error) {
    next(error);
  }
};

// GET /budget/expenses/:id - Get single expense
export const getExpense = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    const expense = await prisma.budget_items.findFirst({
      where: { id, wedding_id: wedding.id },
      include: {
        vendor: {
          select: { id: true, business_name: true },
        },
      },
    });

    if (!expense) {
      throw ApiError.notFound('Expense not found');
    }

    sendSuccess(res, expense);
  } catch (error) {
    next(error);
  }
};

// PUT /budget/expenses/:id - Update expense
export const updateExpense = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;
    const {
      category,
      description,
      estimatedAmount,
      actualAmount,
      isPaid,
      notes,
    } = req.body;

    // Verify expense belongs to user's wedding
    const existingExpense = await prisma.budget_items.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingExpense) {
      throw ApiError.notFound('Expense not found');
    }

    const expense = await prisma.budget_items.update({
      where: { id },
      data: {
        category,
        description,
        estimated_amount: estimatedAmount,
        actual_amount: actualAmount,
        is_paid: isPaid,
        paid_date: isPaid ? new Date() : isPaid === false ? null : undefined,
        notes,
      },
    });

    sendSuccess(res, expense, 200, 'Expense updated successfully');
  } catch (error) {
    next(error);
  }
};

// DELETE /budget/expenses/:id - Delete expense
export const deleteExpense = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    // Verify expense belongs to user's wedding
    const existingExpense = await prisma.budget_items.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingExpense) {
      throw ApiError.notFound('Expense not found');
    }

    await prisma.budget_items.delete({
      where: { id },
    });

    sendSuccess(res, null, 200, 'Expense deleted successfully');
  } catch (error) {
    next(error);
  }
};

// PATCH /budget/expenses/:id/payment - Update payment status
export const updatePaymentStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;
    const { isPaid, paidAmount } = req.body;

    // Verify expense belongs to user's wedding
    const existingExpense = await prisma.budget_items.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingExpense) {
      throw ApiError.notFound('Expense not found');
    }

    const expense = await prisma.budget_items.update({
      where: { id },
      data: {
        is_paid: isPaid,
        actual_amount: paidAmount !== undefined ? paidAmount : undefined,
        paid_date: isPaid ? new Date() : null,
      },
    });

    sendSuccess(res, expense, 200, isPaid ? 'Payment recorded successfully' : 'Payment status updated');
  } catch (error) {
    next(error);
  }
};
