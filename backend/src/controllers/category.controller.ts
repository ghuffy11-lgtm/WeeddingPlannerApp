import { Request, Response, NextFunction } from 'express';
import { prisma } from '../config/database';
import { cache } from '../config/redis';
import { ApiError } from '../utils/ApiError';
import { sendSuccess, sendPaginated } from '../utils/response';

const CACHE_TTL = 3600; // 1 hour

export const listCategories = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { lang = 'en' } = req.query;

    // Try cache first
    const cacheKey = `categories:${lang}`;
    const cached = await cache.get(cacheKey);

    if (cached) {
      sendSuccess(res, cached);
      return;
    }

    const categories = await prisma.categories.findMany({
      where: { is_active: true },
      orderBy: { display_order: 'asc' },
      select: {
        id: true,
        name: true,
        name_ar: true,
        name_fr: true,
        name_es: true,
        icon: true,
        display_order: true,
      },
    });

    // Map to include localized name based on language
    const localizedCategories = categories.map((cat) => {
      let localizedName = cat.name;

      switch (lang) {
        case 'ar':
          localizedName = cat.name_ar || cat.name;
          break;
        case 'fr':
          localizedName = cat.name_fr || cat.name;
          break;
        case 'es':
          localizedName = cat.name_es || cat.name;
          break;
      }

      return {
        id: cat.id,
        name: localizedName,
        originalName: cat.name,
        icon: cat.icon,
      };
    });

    // Cache the result
    await cache.set(cacheKey, localizedCategories, CACHE_TTL);

    sendSuccess(res, localizedCategories);
  } catch (error) {
    next(error);
  }
};

export const getCategory = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;

    const category = await prisma.categories.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        name_ar: true,
        name_fr: true,
        name_es: true,
        icon: true,
        display_order: true,
        _count: {
          select: { vendors: true },
        },
      },
    });

    if (!category) {
      throw ApiError.notFound('Category not found');
    }

    sendSuccess(res, {
      ...category,
      vendorCount: category._count.vendors,
    });
  } catch (error) {
    next(error);
  }
};

export const getCategoryVendors = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const {
      page = '1',
      limit = '20',
      sortBy = 'rating_avg',
      sortOrder = 'desc',
      city,
      priceRange,
    } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    // Build where clause
    const where: Record<string, unknown> = {
      category_id: id,
      status: 'approved',
    };

    if (city) {
      where.location_city = city;
    }

    if (priceRange) {
      where.price_range = priceRange;
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
          portfolio: {
            take: 1,
            orderBy: { display_order: 'asc' },
            select: { image_url: true },
          },
        },
      }),
      prisma.vendors.count({ where }),
    ]);

    // Format response
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
