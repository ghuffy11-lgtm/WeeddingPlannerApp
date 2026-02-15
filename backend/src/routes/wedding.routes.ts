import { Router } from 'express';
import * as weddingController from '../controllers/wedding.controller';
import { authenticate, requireUserType } from '../middleware/auth';

const router = Router();

// All routes require authentication
router.use(authenticate);

// GET /api/v1/weddings/me
router.get('/me', requireUserType('couple'), weddingController.getMyWedding);

// GET /api/v1/weddings/me/tasks - get tasks for current user's wedding
router.get('/me/tasks', requireUserType('couple'), weddingController.getMyTasks);

// GET /api/v1/weddings/me/tasks/stats - get task statistics for current user's wedding
router.get('/me/tasks/stats', requireUserType('couple'), weddingController.getMyTaskStats);

// POST /api/v1/weddings/me/tasks - create task for current user's wedding
router.post('/me/tasks', requireUserType('couple'), weddingController.createMyTask);

// PUT /api/v1/weddings/me/tasks/:taskId - update task for current user's wedding
router.put('/me/tasks/:taskId', requireUserType('couple'), weddingController.updateMyTask);

// DELETE /api/v1/weddings/me/tasks/:taskId - delete task for current user's wedding
router.delete('/me/tasks/:taskId', requireUserType('couple'), weddingController.deleteMyTask);

// GET /api/v1/weddings/me/budget/summary - get budget summary for current user's wedding
router.get('/me/budget/summary', requireUserType('couple'), weddingController.getMyBudgetSummary);

// POST /api/v1/weddings
router.post('/', requireUserType('couple'), weddingController.createWedding);

// PUT /api/v1/weddings/:id
router.put('/:id', requireUserType('couple'), weddingController.updateWedding);

// Guest management
// GET /api/v1/weddings/:id/guests
router.get('/:id/guests', requireUserType('couple'), weddingController.getGuests);

// POST /api/v1/weddings/:id/guests
router.post('/:id/guests', requireUserType('couple'), weddingController.addGuest);

// PUT /api/v1/weddings/:id/guests/:guestId
router.put('/:id/guests/:guestId', requireUserType('couple'), weddingController.updateGuest);

// DELETE /api/v1/weddings/:id/guests/:guestId
router.delete('/:id/guests/:guestId', requireUserType('couple'), weddingController.deleteGuest);

// Budget management
// GET /api/v1/weddings/:id/budget
router.get('/:id/budget', requireUserType('couple'), weddingController.getBudget);

// POST /api/v1/weddings/:id/budget
router.post('/:id/budget', requireUserType('couple'), weddingController.addBudgetItem);

// PUT /api/v1/weddings/:id/budget/:itemId
router.put('/:id/budget/:itemId', requireUserType('couple'), weddingController.updateBudgetItem);

// DELETE /api/v1/weddings/:id/budget/:itemId
router.delete('/:id/budget/:itemId', requireUserType('couple'), weddingController.deleteBudgetItem);

// Tasks management
// GET /api/v1/weddings/:id/tasks
router.get('/:id/tasks', requireUserType('couple'), weddingController.getTasks);

// POST /api/v1/weddings/:id/tasks
router.post('/:id/tasks', requireUserType('couple'), weddingController.addTask);

// PUT /api/v1/weddings/:id/tasks/:taskId
router.put('/:id/tasks/:taskId', requireUserType('couple'), weddingController.updateTask);

// DELETE /api/v1/weddings/:id/tasks/:taskId
router.delete('/:id/tasks/:taskId', requireUserType('couple'), weddingController.deleteTask);

export default router;
