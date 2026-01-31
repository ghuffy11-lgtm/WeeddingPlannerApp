import { Router } from 'express';
import * as categoryController from '../controllers/category.controller';

const router = Router();

// Public routes
// GET /api/v1/categories
router.get('/', categoryController.listCategories);

// GET /api/v1/categories/:id
router.get('/:id', categoryController.getCategory);

// GET /api/v1/categories/:id/vendors
router.get('/:id/vendors', categoryController.getCategoryVendors);

export default router;
