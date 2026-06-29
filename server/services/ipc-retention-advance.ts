import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { ipcRetentionRecords, advancePaymentRecords, subcontractorIpcClaims, ipcApprovals, ipcReviews } from '../db/schema';
import { eq } from 'drizzle-orm';

export const retentionService = {
  recordRetention(params: { ipcId: string; retentionPct: number; retentionAmount: number; cumulativeRetained: number }) {
    return db.insert(ipcRetentionRecords).values({ id: uuid(), ipcId: params.ipcId, retentionPct: params.retentionPct, retentionAmount: params.retentionAmount, cumulativeRetained: params.cumulativeRetained, releaseEligible: params.cumulativeRetained }).returning().get();
  },
  releaseRetention(retentionId: string, amount: number, releasedBy: string) {
    const r = db.select().from(ipcRetentionRecords).where(eq(ipcRetentionRecords.id, retentionId)).get();
    if (!r) throw new Error('Not found');
    return db.update(ipcRetentionRecords).set({ releasedAmount: (r.releasedAmount||0)+amount, status: 'released', releaseDate: new Date().toISOString(), releasedBy }).where(eq(ipcRetentionRecords.id, retentionId)).returning().get();
  },
};

export const advancePaymentService = {
  recordAdvance(params: { companyId: string; projectId: string; contractId: string; advanceAmount: number; advanceDate: string; recoveryPct?: number; bonded?: boolean; bondRef?: string; recoveryStartIpc?: string }) {
    return db.insert(advancePaymentRecords).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, contractId: params.contractId, advanceAmount: params.advanceAmount, advanceDate: params.advanceDate, remainingBalance: params.advanceAmount, recoveryPct: params.recoveryPct||0, bonded: params.bonded?1:0, bondRef: params.bondRef||null, recoveryStartIpc: params.recoveryStartIpc||null }).returning().get();
  },
  recordRecovery(advanceId: string, recoveryAmount: number) {
    const a = db.select().from(advancePaymentRecords).where(eq(advancePaymentRecords.id, advanceId)).get();
    if (!a) throw new Error('Not found');
    const newRecovered = (a.recoveredToDate||0)+recoveryAmount;
    const remaining = a.advanceAmount - newRecovered;
    return db.update(advancePaymentRecords).set({ recoveredToDate: newRecovered, remainingBalance: remaining, status: remaining<=0?'recovered':'active', updatedAt: new Date().toISOString() }).where(eq(advancePaymentRecords.id, advanceId)).returning().get();
  },
};

export const subcontractorClaimService = {
  createClaim(params: { companyId: string; projectId: string; subcontractorId: string; contractId: string; description: string; claimedAmount: number; ipcId?: string }) {
    return db.insert(subcontractorIpcClaims).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, subcontractorId: params.subcontractorId, contractId: params.contractId, description: params.description, claimedAmount: params.claimedAmount, amountDue: params.claimedAmount, ipcId: params.ipcId||null }).returning().get();
  },
  certifyClaim(claimId: string, certifiedAmount: number, certifiedBy: string, retentionDeducted?: number) {
    return db.update(subcontractorIpcClaims).set({ status: 'certified', certifiedAmount, certifiedBy, certifiedAt: new Date().toISOString(), retentionDeducted: retentionDeducted||0, amountDue: certifiedAmount-(retentionDeducted||0), updatedAt: new Date().toISOString() }).where(eq(subcontractorIpcClaims.id, claimId)).returning().get();
  },
};

export const ipcApprovalService = {
  logApproval(params: { ipcId: string; approvedBy: string; decision: string; role?: string; comments?: string }) {
    return db.insert(ipcApprovals).values({ id: uuid(), ipcId: params.ipcId, approvedBy: params.approvedBy, decision: params.decision, role: params.role||'qs', comments: params.comments||null }).returning().get();
  },
};

export const ipcReviewService = {
  submitReview(params: { companyId: string; projectId: string; ipcId: string; reviewedBy: string; decision?: string; role?: string; comments?: string }) {
    return db.insert(ipcReviews).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, ipcId: params.ipcId, reviewedBy: params.reviewedBy, decision: params.decision||'no_action', role: params.role||'project_manager', comments: params.comments||null }).returning().get();
  },
};
