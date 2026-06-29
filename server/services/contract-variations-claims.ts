// =============================================================================
// Contract Variations, Claims, Notices + Closeout — PR-CON-2+3+4+5
// =============================================================================

import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import {
  contractVariations, variationCostImpacts, variationTimeImpacts,
  contractClaims, claimEvidence,
  contractNotices, contractCorrespondence, contractReviews,
} from '../db/schema';
import { eq, and, desc } from 'drizzle-orm';

export const variationService = {
  createVariation(params: {
    companyId: string; contractId: string; title: string;
    variationType: string; initiatedBy: string;
    description?: string; costImpact?: number;
    timeImpactDays?: number; variationNumber?: string;
  }) {
    return db.insert(contractVariations).values({
      id: uuid(), companyId: params.companyId,
      contractId: params.contractId, title: params.title,
      variationType: params.variationType,
      initiatedBy: params.initiatedBy,
      description: params.description || null,
      costImpact: params.costImpact || 0,
      timeImpactDays: params.timeImpactDays || 0,
      variationNumber: params.variationNumber || null,
    }).returning().get();
  },

  addCostImpact(params: {
    variationId: string; description: string;
    quantity: number; unitRate: number;
    boqItemId?: string; unit?: string; costCode?: string;
  }) {
    return db.insert(variationCostImpacts).values({
      id: uuid(), variationId: params.variationId,
      description: params.description,
      quantity: params.quantity, unitRate: params.unitRate,
      totalAmount: params.quantity * params.unitRate,
      boqItemId: params.boqItemId || null,
      unit: params.unit || 'No.',
      costCode: params.costCode || null,
    }).returning().get();
  },

  addTimeImpact(params: {
    variationId: string; description: string;
    delayDays: number; activityId?: string;
    revisedCompletionDate?: string; justification?: string;
  }) {
    return db.insert(variationTimeImpacts).values({
      id: uuid(), variationId: params.variationId,
      description: params.description, delayDays: params.delayDays,
      activityId: params.activityId || null,
      revisedCompletionDate: params.revisedCompletionDate || null,
      justification: params.justification || null,
    }).returning().get();
  },

  submitVariation(variationId: string) {
    return db.update(contractVariations).set({
      status: 'submitted', updatedAt: new Date().toISOString(),
    }).where(eq(contractVariations.id, variationId)).returning().get();
  },

  approveVariation(variationId: string, approvedBy: string) {
    return db.update(contractVariations).set({
      status: 'approved', approvedBy,
      approvedDate: new Date().toISOString(), updatedAt: new Date().toISOString(),
    }).where(eq(contractVariations.id, variationId)).returning().get();
  },

  getVariationWithDetails(variationId: string) {
    const v = db.select().from(contractVariations)
      .where(eq(contractVariations.id, variationId)).get();
    if (!v) return null;
    const costs = db.select().from(variationCostImpacts)
      .where(eq(variationCostImpacts.variationId, variationId)).all();
    const times = db.select().from(variationTimeImpacts)
      .where(eq(variationTimeImpacts.variationId, variationId)).all();
    return { ...v, costImpacts: costs, timeImpacts: times };
  },
};

export const claimService = {
  createClaim(params: {
    companyId: string; contractId: string; title: string;
    claimType: string; claimedAmount: number;
    description?: string; entitlementBasis?: string;
    clauseReference?: string; variationId?: string;
  }) {
    return db.insert(contractClaims).values({
      id: uuid(), companyId: params.companyId,
      contractId: params.contractId, title: params.title,
      claimType: params.claimType, claimedAmount: params.claimedAmount,
      description: params.description || null,
      entitlementBasis: params.entitlementBasis || null,
      clauseReference: params.clauseReference || null,
      variationId: params.variationId || null,
    }).returning().get();
  },

  notifyClaim(claimId: string) {
    return db.update(contractClaims).set({
      status: 'notified', notifiedDate: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }).where(eq(contractClaims.id, claimId)).returning().get();
  },

  submitClaim(claimId: string) {
    return db.update(contractClaims).set({
      status: 'submitted', submittedDate: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }).where(eq(contractClaims.id, claimId)).returning().get();
  },

  determineClaim(claimId: string, determinedAmount: number) {
    return db.update(contractClaims).set({
      status: 'determined', determinedAmount,
      updatedAt: new Date().toISOString(),
    }).where(eq(contractClaims.id, claimId)).returning().get();
  },

  settleClaim(claimId: string, settlementAmount: number) {
    return db.update(contractClaims).set({
      status: 'settled', settlementAmount,
      settledDate: new Date().toISOString(), updatedAt: new Date().toISOString(),
    }).where(eq(contractClaims.id, claimId)).returning().get();
  },

  addEvidence(params: {
    claimId: string; evidenceType: string;
    description?: string; filePath?: string; submittedBy?: string;
  }) {
    return db.insert(claimEvidence).values({
      id: uuid(), claimId: params.claimId,
      evidenceType: params.evidenceType,
      description: params.description || null,
      filePath: params.filePath || null,
      submittedBy: params.submittedBy || null,
    }).returning().get();
  },
};

export const noticeService = {
  sendNotice(params: {
    companyId: string; contractId: string; noticeType: string;
    subject: string; sentBy: string;
    body?: string; receivedBy?: string; responseRequired?: boolean;
    responseDueDate?: string;
  }) {
    return db.insert(contractNotices).values({
      id: uuid(), companyId: params.companyId,
      contractId: params.contractId, noticeType: params.noticeType,
      subject: params.subject, sentBy: params.sentBy,
      body: params.body || null,
      receivedBy: params.receivedBy || null,
      responseRequired: params.responseRequired ? 1 : 0,
      responseDueDate: params.responseDueDate || null,
    }).returning().get();
  },

  recordResponse(noticeId: string) {
    return db.update(contractNotices).set({
      status: 'responded', respondedDate: new Date().toISOString(),
    }).where(eq(contractNotices.id, noticeId)).returning().get();
  },
};

export const correspondenceService = {
  logCorrespondence(params: {
    companyId: string; contractId: string;
    correspondenceType: string; subject: string;
    sender: string; recipient: string;
    direction?: string; referenceNumber?: string;
    linkedNoticeId?: string; linkedVariationId?: string;
    linkedClaimId?: string;
  }) {
    return db.insert(contractCorrespondence).values({
      id: uuid(), companyId: params.companyId,
      contractId: params.contractId,
      correspondenceType: params.correspondenceType,
      subject: params.subject,
      sender: params.sender, recipient: params.recipient,
      direction: params.direction || 'outgoing',
      referenceNumber: params.referenceNumber || null,
      linkedNoticeId: params.linkedNoticeId || null,
      linkedVariationId: params.linkedVariationId || null,
      linkedClaimId: params.linkedClaimId || null,
    }).returning().get();
  },

  getContractCorrespondence(contractId: string) {
    return db.select().from(contractCorrespondence)
      .where(eq(contractCorrespondence.contractId, contractId))
      .orderBy(desc(contractCorrespondence.createdAt)).all();
  },
};

export const contractReviewService = {
  submitReview(params: {
    companyId: string; contractId: string;
    reviewedBy: string; decision?: string;
    role?: string; comments?: string;
  }) {
    return db.insert(contractReviews).values({
      id: uuid(), companyId: params.companyId,
      contractId: params.contractId,
      reviewedBy: params.reviewedBy,
      decision: params.decision || 'no_action',
      role: params.role || 'contract_administrator',
      comments: params.comments || null,
    }).returning().get();
  },

  getContractReviews(contractId: string) {
    return db.select().from(contractReviews)
      .where(eq(contractReviews.contractId, contractId)).all();
  },
};
