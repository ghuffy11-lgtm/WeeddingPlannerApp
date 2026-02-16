import { Request, Response, NextFunction } from 'express';
import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { sendSuccess, sendPaginated } from '../utils/response';

// Public endpoints

export const listVendors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const {
      page = '1',
      limit = '20',
      categoryId,
      city,
      country,
      priceRange,
      minRating,
      sortBy = 'rating_avg',
      sortOrder = 'desc',
      featured,
      search,
    } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    // Build where clause
    const where: Record<string, unknown> = {
      status: 'approved',
    };

    if (categoryId) where.category_id = categoryId;
    if (city) where.location_city = { contains: city, mode: 'insensitive' };
    if (country) where.location_country = { contains: country, mode: 'insensitive' };
    if (priceRange) where.price_range = priceRange;
    if (minRating) where.rating_avg = { gte: parseFloat(minRating as string) };
    if (featured === 'true') where.is_featured = true;
    if (search) {
      where.OR = [
        { business_name: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [vendors, total] = await Promise.all([
      prisma.vendors.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { [sortBy as string]: sortOrder },
        select: {
          id: true,
          business_name: true,
          description: true,
          location_city: true,
          location_country: true,
          price_range: true,
          rating_avg: true,
          review_count: true,
          is_verified: true,
          is_featured: true,
          response_time_hours: true,
          category: {
            select: { id: true, name: true, icon: true },
          },
          portfolio: {
            take: 1,
            orderBy: { display_order: 'asc' },
            select: { image_url: true },
          },
        },
      }),
      prisma.vendors.count({ where }),
    ]);

    const formattedVendors = vendors.map((vendor) => ({
      ...vendor,
      thumbnail: vendor.portfolio[0]?.image_url || null,
      portfolio: undefined,
    }));

    sendPaginated(res, formattedVendors, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

export const getVendor = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const vendor = await prisma.vendors.findUnique({
      where: { id },
      include: {
        category: {
          select: { id: true, name: true, icon: true },
        },
        packages: {
          where: { is_active: true },
          orderBy: { price: 'asc' },
        },
        portfolio: {
          orderBy: { display_order: 'asc' },
        },
      },
    });

    if (!vendor || vendor.status !== 'approved') {
      throw ApiError.notFound('Vendor not found');
    }

    sendSuccess(res, vendor);
  } catch (error) {
    next(error);
  }
};

export const getVendorPackages = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const packages = await prisma.vendor_packages.findMany({
      where: { vendor_id: id, is_active: true },
      orderBy: { price: 'asc' },
    });

    sendSuccess(res, packages);
  } catch (error) {
    next(error);
  }
};

export const getVendorReviews = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const { page = '1', limit = '10' } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const [reviews, total] = await Promise.all([
      prisma.reviews.findMany({
        where: { vendor_id: id },
        skip,
        take: limitNum,
        orderBy: { created_at: 'desc' },
      }),
      prisma.reviews.count({ where: { vendor_id: id } }),
    ]);

    sendPaginated(res, reviews, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

export const getVendorPortfolio = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const portfolio = await prisma.vendor_portfolio.findMany({
      where: { vendor_id: id },
      orderBy: { display_order: 'asc' },
    });

    sendSuccess(res, portfolio);
  } catch (error) {
    next(error);
  }
};

// Protected endpoints (vendor)

export const registerAsVendor = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { businessName, categoryId, description, city, country, priceRange } = req.body;

    // Validate required fields
    if (!businessName || typeof businessName !== 'string' || businessName.trim().length === 0) {
      throw ApiError.badRequest('Business name is required');
    }

    if (!categoryId || typeof categoryId !== 'string') {
      throw ApiError.badRequest('Category is required');
    }

    // Validate categoryId exists in database
    const category = await prisma.categories.findUnique({
      where: { id: categoryId },
    });

    if (!category) {
      throw ApiError.badRequest('Invalid category. Please select a valid category.');
    }

    // Check if user is already a vendor
    const existingVendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (existingVendor) {
      throw ApiError.conflict('User is already registered as a vendor');
    }

    // Map frontend values to database constraint values
    const priceRangeMap: Record<string, string> = {
      'budget': '$',
      'moderate': '$$',
      'premium': '$$$',
      'luxury': '$$$$',
    };
    const mappedPriceRange = priceRange ? (priceRangeMap[priceRange] || '$$') : '$$';

    // Create vendor profile
    const vendor = await prisma.vendors.create({
      data: {
        user_id: userId,
        business_name: businessName,
        category_id: categoryId,
        description,
        location_city: city,
        location_country: country,
        price_range: mappedPriceRange,
        status: 'pending', // Requires admin approval
      },
    });

    // Update user type to vendor
    await prisma.users.update({
      where: { id: userId },
      data: { user_type: 'vendor' },
    });

    sendSuccess(res, vendor, 201, 'Vendor registration submitted for approval');
  } catch (error) {
    next(error);
  }
};

export const getMyVendorProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
      include: {
        category: true,
        packages: {
          where: { is_active: true },
          orderBy: { created_at: 'desc' },
        },
        portfolio: {
          orderBy: { display_order: 'asc' },
        },
      },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found. Please register as a vendor first.');
    }

    sendSuccess(res, vendor);
  } catch (error) {
    next(error);
  }
};

export const getVendorDashboard = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
      include: {
        category: true,
      },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    // Get booking stats
    const [pendingBookings, completedBookings, totalEarnings] = await Promise.all([
      prisma.bookings.count({
        where: { vendor_id: vendor.id, status: 'pending' },
      }),
      prisma.bookings.count({
        where: { vendor_id: vendor.id, status: 'completed' },
      }),
      prisma.bookings.aggregate({
        where: { vendor_id: vendor.id, status: 'completed' },
        _sum: { vendor_payout: true },
      }),
    ]);

    // Get recent bookings
    const recentBookings = await prisma.bookings.findMany({
      where: { vendor_id: vendor.id },
      take: 5,
      orderBy: { created_at: 'desc' },
      include: {
        wedding: {
          select: {
            partner1_name: true,
            partner2_name: true,
            wedding_date: true,
          },
        },
      },
    });

    sendSuccess(res, {
      vendor: {
        ...vendor,
        totalEarnings: totalEarnings._sum.vendor_payout || 0,
      },
      stats: {
        pendingBookings,
        completedBookings,
        totalBookings: pendingBookings + completedBookings,
        rating: vendor.rating_avg,
        reviewCount: vendor.review_count,
      },
      recentBookings,
    });
  } catch (error) {
    next(error);
  }
};

export const updateVendorProfile = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { businessName, description, city, country, priceRange } = req.body;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const updatedVendor = await prisma.vendors.update({
      where: { id: vendor.id },
      data: {
        business_name: businessName,
        description,
        location_city: city,
        location_country: country,
        price_range: priceRange,
        updated_at: new Date(),
      },
    });

    sendSuccess(res, updatedVendor, 200, 'Profile updated successfully');
  } catch (error) {
    next(error);
  }
};

export const createPackage = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { name, description, price, features, durationHours, isPopular } = req.body;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const pkg = await prisma.vendor_packages.create({
      data: {
        vendor_id: vendor.id,
        name,
        description,
        price,
        features,
        duration_hours: durationHours,
        is_popular: isPopular || false,
      },
    });

    sendSuccess(res, pkg, 201, 'Package created successfully');
  } catch (error) {
    next(error);
  }
};

export const updatePackage = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { packageId } = req.params;
    const { name, description, price, features, durationHours, isPopular, isActive } = req.body;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    // Verify package belongs to vendor
    const pkg = await prisma.vendor_packages.findFirst({
      where: { id: packageId, vendor_id: vendor.id },
    });

    if (!pkg) {
      throw ApiError.notFound('Package not found');
    }

    const updatedPkg = await prisma.vendor_packages.update({
      where: { id: packageId },
      data: {
        name,
        description,
        price,
        features,
        duration_hours: durationHours,
        is_popular: isPopular,
        is_active: isActive,
      },
    });

    sendSuccess(res, updatedPkg, 200, 'Package updated successfully');
  } catch (error) {
    next(error);
  }
};

export const deletePackage = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { packageId } = req.params;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    // Verify package belongs to vendor
    const pkg = await prisma.vendor_packages.findFirst({
      where: { id: packageId, vendor_id: vendor.id },
    });

    if (!pkg) {
      throw ApiError.notFound('Package not found');
    }

    // Soft delete by deactivating
    await prisma.vendor_packages.update({
      where: { id: packageId },
      data: { is_active: false },
    });

    sendSuccess(res, null, 200, 'Package deleted successfully');
  } catch (error) {
    next(error);
  }
};

export const addPortfolioItem = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { imageUrl, caption, displayOrder } = req.body;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const item = await prisma.vendor_portfolio.create({
      data: {
        vendor_id: vendor.id,
        image_url: imageUrl,
        caption,
        display_order: displayOrder || 0,
      },
    });

    sendSuccess(res, item, 201, 'Portfolio item added successfully');
  } catch (error) {
    next(error);
  }
};

export const deletePortfolioItem = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { itemId } = req.params;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    // Verify item belongs to vendor
    const item = await prisma.vendor_portfolio.findFirst({
      where: { id: itemId, vendor_id: vendor.id },
    });

    if (!item) {
      throw ApiError.notFound('Portfolio item not found');
    }

    await prisma.vendor_portfolio.delete({
      where: { id: itemId },
    });

    sendSuccess(res, null, 200, 'Portfolio item deleted successfully');
  } catch (error) {
    next(error);
  }
};
