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

// GET /guests - List guests for current user's wedding
export const getGuests = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const {
      page = '1',
      limit = '50',
      group,
      rsvpStatus,
      search,
    } = req.query;

    const pageNum = parseInt(page as string, 10);
    const limitNum = parseInt(limit as string, 10);
    const skip = (pageNum - 1) * limitNum;

    const where: Record<string, unknown> = { wedding_id: wedding.id };

    if (group) where.group_name = group;
    if (rsvpStatus) where.rsvp_status = rsvpStatus;
    if (search) {
      where.OR = [
        { name: { contains: search as string, mode: 'insensitive' } },
        { email: { contains: search as string, mode: 'insensitive' } },
      ];
    }

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

// POST /guests - Create guest
export const createGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const {
      name,
      email,
      phone,
      groupName,
      plusOneAllowed,
      mealPreference,
      dietaryRestrictions,
      tableAssignment,
    } = req.body;

    const guest = await prisma.guests.create({
      data: {
        wedding_id: wedding.id,
        name,
        email,
        phone,
        group_name: groupName,
        plus_one_allowed: plusOneAllowed || false,
        meal_preference: mealPreference,
        dietary_restrictions: dietaryRestrictions,
        table_assignment: tableAssignment,
      },
    });

    sendSuccess(res, guest, 201, 'Guest created successfully');
  } catch (error) {
    next(error);
  }
};

// GET /guests/stats - Get guest statistics
export const getGuestStats = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);

    const [total, confirmed, declined, pending, plusOnes] = await Promise.all([
      prisma.guests.count({ where: { wedding_id: wedding.id } }),
      prisma.guests.count({ where: { wedding_id: wedding.id, rsvp_status: 'confirmed' } }),
      prisma.guests.count({ where: { wedding_id: wedding.id, rsvp_status: 'declined' } }),
      prisma.guests.count({ where: { wedding_id: wedding.id, rsvp_status: 'pending' } }),
      prisma.guests.count({ where: { wedding_id: wedding.id, plus_one_attending: true } }),
    ]);

    // Get meal preference breakdown
    const mealPreferences = await prisma.guests.groupBy({
      by: ['meal_preference'],
      where: { wedding_id: wedding.id, rsvp_status: 'confirmed' },
      _count: { meal_preference: true },
    });

    // Get group breakdown
    const groups = await prisma.guests.groupBy({
      by: ['group_name'],
      where: { wedding_id: wedding.id },
      _count: { group_name: true },
    });

    sendSuccess(res, {
      total,
      confirmed,
      declined,
      pending,
      plusOnes,
      attendingTotal: confirmed + plusOnes,
      mealPreferences: mealPreferences.map((mp) => ({
        preference: mp.meal_preference || 'Not specified',
        count: mp._count.meal_preference,
      })),
      groups: groups.map((g) => ({
        name: g.group_name || 'Ungrouped',
        count: g._count.group_name,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// GET /guests/:id - Get single guest
export const getGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    const guest = await prisma.guests.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!guest) {
      throw ApiError.notFound('Guest not found');
    }

    sendSuccess(res, guest);
  } catch (error) {
    next(error);
  }
};

// PUT /guests/:id - Update guest
export const updateGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;
    const {
      name,
      email,
      phone,
      groupName,
      rsvpStatus,
      plusOneAllowed,
      plusOneName,
      plusOneAttending,
      mealPreference,
      dietaryRestrictions,
      songRequest,
      messageToCouple,
      tableAssignment,
    } = req.body;

    // Verify guest belongs to user's wedding
    const existingGuest = await prisma.guests.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingGuest) {
      throw ApiError.notFound('Guest not found');
    }

    const guest = await prisma.guests.update({
      where: { id },
      data: {
        name,
        email,
        phone,
        group_name: groupName,
        rsvp_status: rsvpStatus,
        plus_one_allowed: plusOneAllowed,
        plus_one_name: plusOneName,
        plus_one_attending: plusOneAttending,
        meal_preference: mealPreference,
        dietary_restrictions: dietaryRestrictions,
        song_request: songRequest,
        message_to_couple: messageToCouple,
        table_assignment: tableAssignment,
        responded_at: rsvpStatus && rsvpStatus !== existingGuest.rsvp_status ? new Date() : undefined,
      },
    });

    sendSuccess(res, guest, 200, 'Guest updated successfully');
  } catch (error) {
    next(error);
  }
};

// DELETE /guests/:id - Delete guest
export const deleteGuest = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    // Verify guest belongs to user's wedding
    const existingGuest = await prisma.guests.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingGuest) {
      throw ApiError.notFound('Guest not found');
    }

    await prisma.guests.delete({
      where: { id },
    });

    sendSuccess(res, null, 200, 'Guest deleted successfully');
  } catch (error) {
    next(error);
  }
};

// PATCH /guests/:id/rsvp - Update RSVP status
export const updateRsvpStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;
    const { rsvpStatus, plusOneAttending, mealPreference, dietaryRestrictions } = req.body;

    // Verify guest belongs to user's wedding
    const existingGuest = await prisma.guests.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!existingGuest) {
      throw ApiError.notFound('Guest not found');
    }

    const guest = await prisma.guests.update({
      where: { id },
      data: {
        rsvp_status: rsvpStatus,
        plus_one_attending: plusOneAttending,
        meal_preference: mealPreference,
        dietary_restrictions: dietaryRestrictions,
        responded_at: new Date(),
      },
    });

    sendSuccess(res, guest, 200, 'RSVP updated successfully');
  } catch (error) {
    next(error);
  }
};

// POST /guests/:id/invite - Send invitation to guest
export const sendInvitation = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { id } = req.params;

    // Verify guest belongs to user's wedding
    const guest = await prisma.guests.findFirst({
      where: { id, wedding_id: wedding.id },
    });

    if (!guest) {
      throw ApiError.notFound('Guest not found');
    }

    if (!guest.email) {
      throw ApiError.badRequest('Guest does not have an email address');
    }

    // Update invitation sent timestamp
    await prisma.guests.update({
      where: { id },
      data: {
        invitation_sent_at: new Date(),
      },
    });

    // TODO: Actually send email invitation
    // await sendInvitationEmail(guest.email, wedding, guest);

    sendSuccess(res, { guestId: id, email: guest.email }, 200, 'Invitation sent successfully');
  } catch (error) {
    next(error);
  }
};

// POST /guests/invite-bulk - Send bulk invitations
export const sendBulkInvitations = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const wedding = await getUserWedding(req.user!.userId);
    const { guestIds } = req.body;

    if (!guestIds || !Array.isArray(guestIds) || guestIds.length === 0) {
      throw ApiError.badRequest('Please provide an array of guest IDs');
    }

    // Get guests that belong to this wedding and have emails
    const guests = await prisma.guests.findMany({
      where: {
        id: { in: guestIds },
        wedding_id: wedding.id,
        email: { not: null },
      },
    });

    if (guests.length === 0) {
      throw ApiError.badRequest('No valid guests found with email addresses');
    }

    // Update invitation sent timestamp for all guests
    await prisma.guests.updateMany({
      where: {
        id: { in: guests.map((g) => g.id) },
      },
      data: {
        invitation_sent_at: new Date(),
      },
    });

    // TODO: Actually send email invitations
    // await sendBulkInvitationEmails(guests, wedding);

    sendSuccess(
      res,
      {
        sent: guests.length,
        skipped: guestIds.length - guests.length,
        guests: guests.map((g) => ({ id: g.id, name: g.name, email: g.email })),
      },
      200,
      `Invitations sent to ${guests.length} guests`
    );
  } catch (error) {
    next(error);
  }
};
