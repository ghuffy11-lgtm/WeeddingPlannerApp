import { Router } from 'express';
import { authenticate, requireUserType } from '../middleware/auth';
import * as budgetController from '../controllers/budget.controller';

const router = Router();

// All routes require authentication and couple user type
router.use(authenticate, requireUserType('couple'));

// GET /api/v1/budget - Get budget overview
router.get('/', budgetController.getBudget);

// GET /api/v1/budget/summary - Get budget summary
router.get('/summary', budgetController.getBudgetSummary);

// PUT /api/v1/budget/total - Update total budget
router.put('/total', budgetController.updateTotalBudget);

// GET /api/v1/budget/expenses - List expenses
router.get('/expenses', budgetController.getExpenses);

// POST /api/v1/budget/expenses - Create expense
router.post('/expenses', budgetController.createExpense);

// GET /api/v1/budget/expenses/upcoming - Get upcoming payments
router.get('/expenses/upcoming', budgetController.getUpcomingPayments);

// GET /api/v1/budget/expenses/overdue - Get overdue payments
router.get('/expenses/overdue', budgetController.getOverduePayments);

// GET /api/v1/budget/expenses/:id - Get single expense
router.get('/expenses/:id', budgetController.getExpense);

// PUT /api/v1/budget/expenses/:id - Update expense
router.put('/expenses/:id', budgetController.updateExpense);

// DELETE /api/v1/budget/expenses/:id - Delete expense
router.delete('/expenses/:id', budgetController.deleteExpense);

// PATCH /api/v1/budget/expenses/:id/payment - Update payment status
router.patch('/expenses/:id/payment', budgetController.updatePaymentStatus);

export default router;
