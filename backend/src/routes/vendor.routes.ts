import { Router } from 'express';
import * as vendorController from '../controllers/vendor.controller';
import { authenticate, requireUserType } from '../middleware/auth';

const router = Router();

// Public routes
// GET /api/v1/vendors
router.get('/', vendorController.listVendors);

// GET /api/v1/vendors/search - alias for list with search/filter params
router.get('/search', vendorController.listVendors);

// Protected routes (vendor only) - MUST be before /:id routes
// POST /api/v1/vendors/register
router.post('/register', authenticate, vendorController.registerAsVendor);

// GET /api/v1/vendors/me - Get current vendor's profile
router.get('/me', authenticate, requireUserType('vendor'), vendorController.getMyVendorProfile);

// GET /api/v1/vendors/me/dashboard
router.get('/me/dashboard', authenticate, requireUserType('vendor'), vendorController.getVendorDashboard);

// PUT /api/v1/vendors/me
router.put('/me', authenticate, requireUserType('vendor'), vendorController.updateVendorProfile);

// POST /api/v1/vendors/me/packages
router.post('/me/packages', authenticate, requireUserType('vendor'), vendorController.createPackage);

// PUT /api/v1/vendors/me/packages/:packageId
router.put('/me/packages/:packageId', authenticate, requireUserType('vendor'), vendorController.updatePackage);

// DELETE /api/v1/vendors/me/packages/:packageId
router.delete('/me/packages/:packageId', authenticate, requireUserType('vendor'), vendorController.deletePackage);

// POST /api/v1/vendors/me/portfolio
router.post('/me/portfolio', authenticate, requireUserType('vendor'), vendorController.addPortfolioItem);

// DELETE /api/v1/vendors/me/portfolio/:itemId
router.delete('/me/portfolio/:itemId', authenticate, requireUserType('vendor'), vendorController.deletePortfolioItem);

// Public routes with :id parameter - MUST be after /me routes
// GET /api/v1/vendors/:id
router.get('/:id', vendorController.getVendor);

// GET /api/v1/vendors/:id/packages
router.get('/:id/packages', vendorController.getVendorPackages);

// GET /api/v1/vendors/:id/reviews
router.get('/:id/reviews', vendorController.getVendorReviews);

// GET /api/v1/vendors/:id/portfolio
router.get('/:id/portfolio', vendorController.getVendorPortfolio);

export default router;
