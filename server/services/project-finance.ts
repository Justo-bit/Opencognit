// =============================================================================
// Project Finance Service — PR-FIN-1 Cost Code + Budget Ledger Backbone
// =============================================================================

import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import {
  costCodes, projectBudgetLines,
  financialLedgerEntries, financeAgentRecommendations,
} from '../db/schema';
import { eq, and, desc, sum } from 'drizzle-orm';

export const costCodeService = {
  createCostCode(params: {
    companyId: string; projectId: string; code: string;
    description: string; category?: string;
    parentCostCodeId?: string; level?: number;
  }) {
    return db.insert(costCodes).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, code: params.code,
      description: params.description,
      category: params.category || 'direct_cost',
      parentCostCodeId: params.parentCostCodeId || null,
      level: params.level || 1,
    }).returning().get();
  },

  getProjectCostCodes(projectId: string) {
    return db.select().from(costCodes)
      .where(eq(costCodes.projectId, projectId)).all();
  },

  getCostCodeTree(projectId: string) {
    const all = db.select().from(costCodes)
      .where(eq(costCodes.projectId, projectId)).all();
    const roots = all.filter(c => !c.parentCostCodeId);
    const build = (parent: any) => ({
      ...parent,
      children: all.filter(c => c.parentCostCodeId === parent.id).map(build),
    });
    return roots.map(build);
  },
};

export const budgetService = {
  createBudgetLine(params: {
    companyId: string; projectId: string; costCodeId: string;
    description: string; budgetAmount: number;
    boqItemId?: string; contingencyAmount?: number;
    currency?: string; fiscalYear?: string;
  }) {
    const contingency = params.contingencyAmount || 0;
    return db.insert(projectBudgetLines).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, costCodeId: params.costCodeId,
      description: params.description,
      budgetAmount: params.budgetAmount,
      contingencyAmount: contingency,
      totalBudget: params.budgetAmount + contingency,
      boqItemId: params.boqItemId || null,
      currency: params.currency || 'KES',
      fiscalYear: params.fiscalYear || null,
    }).returning().get();
  },

  approveBudget(budgetId: string, approvedBy: string) {
    return db.update(projectBudgetLines).set({
      status: 'approved', approvedBy,
      approvedAt: new Date().toISOString(), updatedAt: new Date().toISOString(),
    }).where(eq(projectBudgetLines.id, budgetId)).returning().get();
  },

  getProjectBudget(projectId: string) {
    return db.select().from(projectBudgetLines)
      .where(eq(projectBudgetLines.projectId, projectId)).all();
  },

  getBudgetVsActual(projectId: string) {
    const budget = db.select().from(projectBudgetLines)
      .where(and(
        eq(projectBudgetLines.projectId, projectId),
        eq(projectBudgetLines.status, 'approved'),
      )).all();

    const entries = db.select().from(financialLedgerEntries)
      .where(eq(financialLedgerEntries.projectId, projectId)).all();

    return budget.map(line => {
      const actuals = entries.filter(e => e.costCodeId === line.costCodeId);
      const committed = actuals.filter(e => e.transactionType === 'commitment')
        .reduce((s, e) => s + e.amount, 0);
      const actual = actuals.filter(e =>
        ['grn_actual', 'invoice_actual', 'payroll_actual', 'equipment_actual', 'subcontract_certified'].includes(e.transactionType)
      ).reduce((s, e) => s + e.amount, 0);
      const paid = actuals.filter(e => e.transactionType === 'payment')
        .reduce((s, e) => s + e.amount, 0);

      return {
        ...line,
        committed,
        actual,
        paid,
        remaining: line.totalBudget - committed,
        variancePct: line.totalBudget > 0 ? ((actual - line.totalBudget) / line.totalBudget) * 100 : 0,
      };
    });
  },
};

export const ledgerService = {
  postEntry(params: {
    companyId: string; projectId: string; costCodeId: string;
    transactionType: string; amount: number; description: string;
    entryDate: string;
    boqItemId?: string; activityId?: string;
    sourceDocumentType?: string; sourceDocumentId?: string;
    vendorId?: string; subcontractorId?: string;
    workerId?: string; equipmentId?: string;
    postedBy?: string; currency?: string;
  }) {
    if (params.amount === 0) {
      throw new Error('Cannot post zero-amount ledger entry');
    }

    return db.insert(financialLedgerEntries).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, costCodeId: params.costCodeId,
      transactionType: params.transactionType,
      amount: params.amount, description: params.description,
      entryDate: params.entryDate,
      boqItemId: params.boqItemId || null,
      activityId: params.activityId || null,
      sourceDocumentType: params.sourceDocumentType || null,
      sourceDocumentId: params.sourceDocumentId || null,
      vendorId: params.vendorId || null,
      subcontractorId: params.subcontractorId || null,
      workerId: params.workerId || null,
      equipmentId: params.equipmentId || null,
      postedBy: params.postedBy || null,
      currency: params.currency || 'KES',
    }).returning().get();
  },

  reverseEntry(entryId: string, postedBy: string, reason: string) {
    const original = db.select().from(financialLedgerEntries)
      .where(eq(financialLedgerEntries.id, entryId)).get();
    if (!original) throw new Error('Entry not found');

    const reversal = db.insert(financialLedgerEntries).values({
      id: uuid(), companyId: original.companyId,
      projectId: original.projectId, costCodeId: original.costCodeId,
      transactionType: 'reversal',
      amount: -original.amount,
      description: `Reversal of ${entryId}: ${reason}`,
      entryDate: new Date().toISOString(),
      sourceDocumentType: original.sourceDocumentType,
      sourceDocumentId: original.sourceDocumentId,
      reversalOf: entryId, postedBy,
    }).returning().get();

    db.update(financialLedgerEntries).set({
      reversedByEntry: reversal.id,
    }).where(eq(financialLedgerEntries.id, entryId)).run();

    return reversal;
  },

  getCostCodeBalance(projectId: string, costCodeId: string) {
    const entries = db.select().from(financialLedgerEntries)
      .where(and(
        eq(financialLedgerEntries.projectId, projectId),
        eq(financialLedgerEntries.costCodeId, costCodeId),
      )).all();

    const total = entries.reduce((s, e) => s + e.amount, 0);
    const commitments = entries.filter(e => e.transactionType === 'commitment')
      .reduce((s, e) => s + e.amount, 0);
    const actuals = entries.filter(e =>
      ['grn_actual', 'invoice_actual', 'payroll_actual', 'equipment_actual', 'subcontract_certified'].includes(e.transactionType)
    ).reduce((s, e) => s + e.amount, 0);
    const payments = entries.filter(e => e.transactionType === 'payment')
      .reduce((s, e) => s + e.amount, 0);
    const reversals = entries.filter(e => e.transactionType === 'reversal')
      .reduce((s, e) => s + Math.abs(e.amount), 0);

    return { total, commitments, actuals, payments, reversals, entries };
  },

  getProjectLedger(projectId: string) {
    return db.select().from(financialLedgerEntries)
      .where(eq(financialLedgerEntries.projectId, projectId))
      .orderBy(desc(financialLedgerEntries.entryDate)).all();
  },

  getLedgerByType(projectId: string, transactionType: string) {
    return db.select().from(financialLedgerEntries)
      .where(and(
        eq(financialLedgerEntries.projectId, projectId),
        eq(financialLedgerEntries.transactionType, transactionType),
      )).orderBy(desc(financialLedgerEntries.entryDate)).all();
  },
};

export const financeAgentService = {
  createRecommendation(params: {
    companyId: string; projectId: string;
    issue: string; recommendedAction: string;
    costCodeId?: string; evidence?: string;
    riskLevel?: string; financialImpact?: number; owner?: string;
  }) {
    return db.insert(financeAgentRecommendations).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, issue: params.issue,
      recommendedAction: params.recommendedAction,
      costCodeId: params.costCodeId || null,
      evidence: params.evidence || null,
      riskLevel: params.riskLevel || 'medium',
      financialImpact: params.financialImpact || 0,
      owner: params.owner || null,
    }).returning().get();
  },

  reviewRecommendation(recId: string) {
    return db.update(financeAgentRecommendations).set({
      status: 'reviewed', reviewedAt: new Date().toISOString(),
    }).where(eq(financeAgentRecommendations.id, recId)).returning().get();
  },

  getProjectRecommendations(projectId: string) {
    return db.select().from(financeAgentRecommendations)
      .where(eq(financeAgentRecommendations.projectId, projectId)).all();
  },
};
