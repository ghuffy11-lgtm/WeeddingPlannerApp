import { Request, Response, NextFunction } from 'express';
import { prisma } from '../config/database';
import { ApiError } from '../utils/ApiError';
import { sendSuccess, sendPaginated } from '../utils/response';

// Couple endpoints

export const getMyBookings = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { status, page = '1', limit = '20' } = req.query;

    // Get user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const where: Record<string, unknown> = { wedding_id: wedding.id };
    if (status) where.status = status;

    const [bookings, total] = await Promise.all([
      prisma.bookings.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { created_at: 'desc' },
        include: {
          vendor: {
            select: {
              id: true,
              business_name: true,
              category: { select: { name: true, icon: true } },
            },
          },
          package: {
            select: { id: true, name: true, price: true },
          },
        },
      }),
      prisma.bookings.count({ where }),
    ]);

    sendPaginated(res, bookings, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

export const getBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;
    const userType = req.user!.userType;

    const booking = await prisma.bookings.findUnique({
      where: { id },
      include: {
        vendor: {
          select: {
            id: true,
            user_id: true,
            business_name: true,
            category: { select: { name: true, icon: true } },
          },
        },
        wedding: {
          select: {
            id: true,
            user_id: true,
            partner1_name: true,
            partner2_name: true,
            wedding_date: true,
          },
        },
        package: true,
      },
    });

    if (!booking) {
      throw ApiError.notFound('Booking not found');
    }

    // Verify access
    if (userType === 'couple' && booking.wedding?.user_id !== userId) {
      throw ApiError.forbidden('You do not have access to this booking');
    }

    if (userType === 'vendor' && booking.vendor?.user_id !== userId) {
      throw ApiError.forbidden('You do not have access to this booking');
    }

    sendSuccess(res, booking);
  } catch (error) {
    next(error);
  }
};

export const createBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { vendorId, packageId, bookingDate, notes } = req.body;

    // Get user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Please create a wedding first');
    }

    // Get vendor with commission rate
    const vendor = await prisma.vendors.findUnique({
      where: { id: vendorId },
    });

    if (!vendor || vendor.status !== 'approved') {
      throw ApiError.notFound('Vendor not found or not approved');
    }

    // Get package if specified
    let totalAmount = 0;
    if (packageId) {
      const pkg = await prisma.vendor_packages.findUnique({
        where: { id: packageId },
      });
      if (pkg) {
        totalAmount = Number(pkg.price);
      }
    }

    // Calculate commission
    const commissionRate = Number(vendor.commission_rate);
    const commissionAmount = (totalAmount * commissionRate) / 100;
    const vendorPayout = totalAmount - commissionAmount;

    const booking = await prisma.bookings.create({
      data: {
        wedding_id: wedding.id,
        vendor_id: vendorId,
        package_id: packageId,
        booking_date: new Date(bookingDate),
        total_amount: totalAmount,
        commission_rate: commissionRate,
        commission_amount: commissionAmount,
        vendor_payout: vendorPayout,
        couple_notes: notes,
        status: 'pending',
      },
      include: {
        vendor: {
          select: { id: true, business_name: true },
        },
        package: {
          select: { id: true, name: true },
        },
      },
    });

    // TODO: Send notification to vendor

    sendSuccess(res, booking, 201, 'Booking request sent successfully');
  } catch (error) {
    next(error);
  }
};

export const cancelBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    // Get user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    // Verify booking ownership
    const booking = await prisma.bookings.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!booking) {
      throw ApiError.notFound('Booking not found');
    }

    if (['completed', 'cancelled'].includes(booking.status)) {
      throw ApiError.badRequest('Cannot cancel this booking');
    }

    await prisma.bookings.update({
      where: { id },
      data: {
        status: 'cancelled',
        updated_at: new Date(),
      },
    });

    // TODO: Send notification to vendor

    sendSuccess(res, null, 200, 'Booking cancelled successfully');
  } catch (error) {
    next(error);
  }
};

export const addReview = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const { rating, reviewText } = req.body;

    // Get user's wedding
    const wedding = await prisma.weddings.findFirst({
      where: { user_id: userId },
    });

    if (!wedding) {
      throw ApiError.notFound('Wedding not found');
    }

    // Verify booking ownership and status
    const booking = await prisma.bookings.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!booking) {
      throw ApiError.notFound('Booking not found');
    }

    if (booking.status !== 'completed') {
      throw ApiError.badRequest('Can only review completed bookings');
    }

    // Check if already reviewed
    const existingReview = await prisma.reviews.findFirst({
      where: { booking_id: id },
    });

    if (existingReview) {
      throw ApiError.conflict('You have already reviewed this booking');
    }

    // Create review
    const review = await prisma.reviews.create({
      data: {
        vendor_id: booking.vendor_id,
        wedding_id: wedding.id,
        booking_id: id,
        rating,
        review_text: reviewText,
        is_verified: true,
      },
    });

    // Update vendor rating
    const vendorReviews = await prisma.reviews.aggregate({
      where: { vendor_id: booking.vendor_id },
      _avg: { rating: true },
      _count: { rating: true },
    });

    await prisma.vendors.update({
      where: { id: booking.vendor_id! },
      data: {
        rating_avg: vendorReviews._avg.rating || 0,
        review_count: vendorReviews._count.rating,
      },
    });

    sendSuccess(res, review, 201, 'Review added successfully');
  } catch (error) {
    next(error);
  }
};

// Vendor endpoints

export const getVendorRequests = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const pendingBookings = await prisma.bookings.findMany({
      where: { vendor_id: vendor.id, status: 'pending' },
      orderBy: { created_at: 'desc' },
      include: {
        wedding: {
          select: {
            partner1_name: true,
            partner2_name: true,
            wedding_date: true,
          },
        },
        package: {
          select: { name: true, price: true },
        },
      },
    });

    sendSuccess(res, pendingBookings);
  } catch (error) {
    next(error);
  }
};

export const getVendorBookings = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { status, page = '1', limit = '20' } = req.query;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const where: Record<string, unknown> = { vendor_id: vendor.id };
    if (status) where.status = status;

    const [bookings, total] = await Promise.all([
      prisma.bookings.findMany({
        where,
        skip,
        take: limitNum,
        orderBy: { booking_date: 'desc' },
        include: {
          wedding: {
            select: {
              partner1_name: true,
              partner2_name: true,
              wedding_date: true,
            },
          },
          package: {
            select: { name: true, price: true },
          },
        },
      }),
      prisma.bookings.count({ where }),
    ]);

    sendPaginated(res, bookings, pageNum, limitNum, total);
  } catch (error) {
    next(error);
  }
};

export const acceptBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const { vendorNotes } = req.body;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const booking = await prisma.bookings.findFirst({
      where: { id, vendor_id: vendor.id },
    });

    if (!booking) {
      throw ApiError.notFound('Booking not found');
    }

    if (booking.status !== 'pending') {
      throw ApiError.badRequest('Can only accept pending bookings');
    }

    await prisma.bookings.update({
      where: { id },
      data: {
        status: 'accepted',
        vendor_notes: vendorNotes,
        updated_at: new Date(),
      },
    });

    // TODO: Send notification to couple

    sendSuccess(res, null, 200, 'Booking accepted');
  } catch (error) {
    next(error);
  }
};

export const declineBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;
    const { reason } = req.body;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const booking = await prisma.bookings.findFirst({
      where: { id, vendor_id: vendor.id },
    });

    if (!booking) {
      throw ApiError.notFound('Booking not found');
    }

    if (booking.status !== 'pending') {
      throw ApiError.badRequest('Can only decline pending bookings');
    }

    await prisma.bookings.update({
      where: { id },
      data: {
        status: 'declined',
        vendor_notes: reason,
        updated_at: new Date(),
      },
    });

    // TODO: Send notification to couple

    sendSuccess(res, null, 200, 'Booking declined');
  } catch (error) {
    next(error);
  }
};

export const completeBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { id } = req.params;

    const vendor = await prisma.vendors.findFirst({
      where: { user_id: userId },
    });

    if (!vendor) {
      throw ApiError.notFound('Vendor profile not found');
    }

    const booking = await prisma.bookings.findFirst({
      where: { id, vendor_id: vendor.id },
    });

    if (!booking) {
      throw ApiError.notFound('Booking not found');
    }

    if (!['accepted', 'confirmed'].includes(booking.status)) {
      throw ApiError.badRequest('Can only complete accepted or confirmed bookings');
    }

    // Update booking
    await prisma.bookings.update({
      where: { id },
      data: {
        status: 'completed',
        updated_at: new Date(),
      },
    });

    // Create commission transaction
    await prisma.commission_transactions.create({
      data: {
        booking_id: id,
        vendor_id: vendor.id,
        gross_amount: booking.total_amount!,
        commission_rate: booking.commission_rate!,
        commission_amount: booking.commission_amount!,
        vendor_payout: booking.vendor_payout!,
        status: 'pending',
      },
    });

    // Update vendor stats
    await prisma.vendors.update({
      where: { id: vendor.id },
      data: {
        weddings_completed: { increment: 1 },
      },
    });

    // TODO: Send notification to couple

    sendSuccess(res, null, 200, 'Booking marked as completed');
  } catch (error) {
    next(error);
  }
};
