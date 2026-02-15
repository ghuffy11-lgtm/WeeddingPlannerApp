import { Router } from 'express';
import { authenticate, requireUserType } from '../middleware/auth';
import * as taskController from '../controllers/task.controller';

const router = Router();

// All routes require authentication and couple user type
router.use(authenticate, requireUserType('couple'));

// GET /api/v1/tasks - List tasks with filters
router.get('/', taskController.getTasks);

// POST /api/v1/tasks - Create task
router.post('/', taskController.createTask);

// GET /api/v1/tasks/stats - Get task statistics
router.get('/stats', taskController.getTaskStats);

// GET /api/v1/tasks/:id - Get single task
router.get('/:id', taskController.getTask);

// PUT /api/v1/tasks/:id - Update task
router.put('/:id', taskController.updateTask);

// DELETE /api/v1/tasks/:id - Delete task
router.delete('/:id', taskController.deleteTask);

// PATCH /api/v1/tasks/:id/complete - Mark task as complete
router.patch('/:id/complete', taskController.completeTask);

export default router;
