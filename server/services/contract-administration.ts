// =============================================================================
// Contract Administration Service — PR-CON-1 Register + Obligations Backbone
// =============================================================================

import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import {
  contracts, contractParties, contractClauses,
  contractObligations, contractDocuments,
  contractAgentRecommendations,
} from '../db/schema';
import { eq, and, desc, lte } from 'drizzle-orm';

export const contractService = {
  registerContract(params: {
    companyId: string; projectId: string; title: string;
    counterpartyName: string;
    startDate: string; endDate: string; contractSum: number;
    contractType?: string; awardId?: string; contractNumber?: string;
    counterpartyId?: string; scopeOfWork?: string;
    contingencySum?: number; currency?: string;
    originalCompletionDate?: string; signedDate?: string;
    governingLaw?: string; disputeResolution?: string;
    bondType?: string; bondAmount?: number; bondExpiry?: string;
    retentionPct?: number; retentionCap?: number;
    defectsLiabilityMonths?: number;
  }) {
    return db.insert(contracts).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, title: params.title,
      counterpartyName: params.counterpartyName,
      startDate: params.startDate, endDate: params.endDate,
      contractSum: params.contractSum,
      contractType: params.contractType || 'main_contract',
      awardId: params.awardId || null,
      contractNumber: params.contractNumber || null,
      counterpartyId: params.counterpartyId || null,
      scopeOfWork: params.scopeOfWork || null,
      contingencySum: params.contingencySum || 0,
      currency: params.currency || 'KES',
      originalCompletionDate: params.originalCompletionDate || params.endDate,
      currentCompletionDate: params.endDate,
      signedDate: params.signedDate || null,
      governingLaw: params.governingLaw || null,
      disputeResolution: params.disputeResolution || null,
      bondType: params.bondType || null,
      bondAmount: params.bondAmount ?? null,
      bondExpiry: params.bondExpiry || null,
      retentionPct: params.retentionPct ?? 0,
      retentionCap: params.retentionCap ?? null,
      defectsLiabilityMonths: params.defectsLiabilityMonths ?? 12,
    }).returning().get();
  },

  executeContract(contractId: string, signedDate: string) {
    return db.update(contracts).set({
      status: 'active', signedDate,
      updatedAt: new Date().toISOString(),
    }).where(eq(contracts.id, contractId)).returning().get();
  },

  addParty(params: {
    contractId: string; partyName: string;
    partyRole?: string; contactPerson?: string;
    contactEmail?: string; contactPhone?: string;
    address?: string; signingAuthority?: string; signedDate?: string;
  }) {
    return db.insert(contractParties).values({
      id: uuid(), contractId: params.contractId,
      partyName: params.partyName,
      partyRole: params.partyRole || 'contractor',
      contactPerson: params.contactPerson || null,
      contactEmail: params.contactEmail || null,
      contactPhone: params.contactPhone || null,
      address: params.address || null,
      signingAuthority: params.signingAuthority || null,
      signedDate: params.signedDate || null,
    }).returning().get();
  },

  addClause(params: {
    contractId: string; clauseNumber: string; clauseTitle: string;
    clauseText?: string; clauseType?: string;
    isCritical?: boolean; deviationFromStandard?: string;
    riskLevel?: string;
  }) {
    return db.insert(contractClauses).values({
      id: uuid(), contractId: params.contractId,
      clauseNumber: params.clauseNumber,
      clauseTitle: params.clauseTitle,
      clauseText: params.clauseText || null,
      clauseType: params.clauseType || 'general',
      isCritical: params.isCritical ? 1 : 0,
      deviationFromStandard: params.deviationFromStandard || null,
      riskLevel: params.riskLevel || 'low',
    }).returning().get();
  },

  addObligation(params: {
    contractId: string; obligationType: string;
    description: string; responsibleParty: string;
    clauseId?: string; dueDate?: string; reminderDays?: number;
  }) {
    return db.insert(contractObligations).values({
      id: uuid(), contractId: params.contractId,
      obligationType: params.obligationType,
      description: params.description,
      responsibleParty: params.responsibleParty,
      clauseId: params.clauseId || null,
      dueDate: params.dueDate || null,
      reminderDays: params.reminderDays ?? 7,
    }).returning().get();
  },

  fulfillObligation(obligationId: string, fulfilledBy: string, evidence?: string) {
    return db.update(contractObligations).set({
      fulfilled: 1, fulfilledBy,
      fulfilledDate: new Date().toISOString(),
      evidence: evidence || null,
      updatedAt: new Date().toISOString(),
    }).where(eq(contractObligations.id, obligationId)).returning().get();
  },

  addDocument(params: {
    contractId: string; documentType: string; documentTitle: string;
    filePath?: string; uploadedBy?: string;
  }) {
    db.update(contractDocuments).set({ isCurrent: 0 })
      .where(and(
        eq(contractDocuments.contractId, params.contractId),
        eq(contractDocuments.documentType, params.documentType),
      )).run();

    return db.insert(contractDocuments).values({
      id: uuid(), contractId: params.contractId,
      documentType: params.documentType,
      documentTitle: params.documentTitle,
      filePath: params.filePath || null,
      uploadedBy: params.uploadedBy || null,
    }).returning().get();
  },

  getDueObligations(companyId: string, daysAhead: number = 7) {
    const threshold = new Date();
    threshold.setDate(threshold.getDate() + daysAhead);
    const thresholdStr = threshold.toISOString();

    return db.select().from(contractObligations)
      .where(and(
        eq(contractObligations.fulfilled, 0),
      )).all()
      .filter(o => o.dueDate && o.dueDate <= thresholdStr);
  },

  getContractWithDetails(contractId: string) {
    const contract = db.select().from(contracts)
      .where(eq(contracts.id, contractId)).get();
    if (!contract) return null;
    const parties = db.select().from(contractParties)
      .where(eq(contractParties.contractId, contractId)).all();
    const clauses = db.select().from(contractClauses)
      .where(eq(contractClauses.contractId, contractId)).all();
    const obligations = db.select().from(contractObligations)
      .where(eq(contractObligations.contractId, contractId)).all();
    const documents = db.select().from(contractDocuments)
      .where(eq(contractDocuments.contractId, contractId)).all();
    return { ...contract, parties, clauses, obligations, documents };
  },

  listContractsByProject(projectId: string) {
    return db.select().from(contracts)
      .where(eq(contracts.projectId, projectId))
      .orderBy(desc(contracts.createdAt)).all();
  },

  getCriticalClauses(contractId: string) {
    return db.select().from(contractClauses)
      .where(and(
        eq(contractClauses.contractId, contractId),
        eq(contractClauses.isCritical, 1),
      )).all();
  },
};

export const contractAgentService = {
  createRecommendation(params: {
    companyId: string; contractId: string;
    issue: string; recommendedAction: string;
    evidence?: string; riskLevel?: string; owner?: string;
  }) {
    return db.insert(contractAgentRecommendations).values({
      id: uuid(), companyId: params.companyId,
      contractId: params.contractId, issue: params.issue,
      recommendedAction: params.recommendedAction,
      evidence: params.evidence || null,
      riskLevel: params.riskLevel || 'medium',
      owner: params.owner || null,
    }).returning().get();
  },

  reviewRecommendation(recId: string) {
    return db.update(contractAgentRecommendations).set({
      status: 'reviewed', reviewedAt: new Date().toISOString(),
    }).where(eq(contractAgentRecommendations.id, recId)).returning().get();
  },

  getPendingRecommendations(companyId: string) {
    return db.select().from(contractAgentRecommendations)
      .where(and(
        eq(contractAgentRecommendations.companyId, companyId),
        eq(contractAgentRecommendations.status, 'pending_review'),
      )).all();
  },
};
