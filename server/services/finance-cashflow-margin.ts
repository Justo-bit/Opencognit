// =============================================================================
// Finance — Commitments, Cashflow, Margin, Intelligence (PR-FIN-2+3+4+5)
// =============================================================================

import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import {
  projectCommitments, projectActualCosts, projectPayables,
  projectPayments, projectReceivables, clientPaymentReceipts,
  projectCashflowForecasts, projectMarginForecasts,
  costOverrunAlerts, financeReviews,
} from '../db/schema';
import { eq, and, desc } from 'drizzle-orm';

export const commitmentService = {
  createCommitment(params: {
    companyId: string; projectId: string; costCodeId: string;
    description: string; committedAmount: number;
    commitmentType?: string; poId?: string; subcontractId?: string;
    expectedPaymentDate?: string;
  }) {
    return db.insert(projectCommitments).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, costCodeId: params.costCodeId,
      description: params.description,
      committedAmount: params.committedAmount,
      commitmentType: params.commitmentType || 'po',
      poId: params.poId || null,
      subcontractId: params.subcontractId || null,
      expectedPaymentDate: params.expectedPaymentDate || null,
    }).returning().get();
  },

  releaseCommitment(commitmentId: string, amount: number) {
    const c = db.select().from(projectCommitments)
      .where(eq(projectCommitments.id, commitmentId)).get();
    if (!c) throw new Error('Commitment not found');
    const newReleased = (c.releasedAmount || 0) + amount;
    return db.update(projectCommitments).set({
      releasedAmount: newReleased,
      status: newReleased >= c.committedAmount ? 'released' : 'open',
      releasedDate: new Date().toISOString(), updatedAt: new Date().toISOString(),
    }).where(eq(projectCommitments.id, commitmentId)).returning().get();
  },

  getProjectCommitments(projectId: string) {
    return db.select().from(projectCommitments)
      .where(eq(projectCommitments.projectId, projectId)).all();
  },
};

export const actualCostService = {
  postActualCost(params: {
    companyId: string; projectId: string; costCodeId: string;
    costType: string; amount: number; description: string;
    costDate: string;
    sourceDocumentType?: string; sourceDocumentId?: string;
    postedBy?: string;
  }) {
    return db.insert(projectActualCosts).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, costCodeId: params.costCodeId,
      costType: params.costType, amount: params.amount,
      description: params.description, costDate: params.costDate,
      sourceDocumentType: params.sourceDocumentType || null,
      sourceDocumentId: params.sourceDocumentId || null,
      postedBy: params.postedBy || null,
    }).returning().get();
  },
};

export const payableService = {
  createPayable(params: {
    companyId: string; projectId: string; description: string;
    payableAmount: number;
    vendorId?: string; subcontractorId?: string; invoiceId?: string;
    dueDate?: string; priority?: string;
  }) {
    return db.insert(projectPayables).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, description: params.description,
      payableAmount: params.payableAmount,
      vendorId: params.vendorId || null,
      subcontractorId: params.subcontractorId || null,
      invoiceId: params.invoiceId || null,
      dueDate: params.dueDate || null,
      priority: params.priority || 'normal',
    }).returning().get();
  },

  recordPayment(params: {
    companyId: string; projectId: string; paymentType: string;
    amount: number; paymentDate: string; paidBy: string;
    payableId?: string; vendorId?: string; subcontractorId?: string;
    paymentMethod?: string; paymentRef?: string; approvedBy?: string;
  }) {
    const payment = db.insert(projectPayments).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, paymentType: params.paymentType,
      amount: params.amount, paymentDate: params.paymentDate,
      paidBy: params.paidBy,
      payableId: params.payableId || null,
      vendorId: params.vendorId || null,
      subcontractorId: params.subcontractorId || null,
      paymentMethod: params.paymentMethod || 'bank_transfer',
      paymentRef: params.paymentRef || null,
      approvedBy: params.approvedBy || null,
    }).returning().get();

    if (params.payableId) {
      const p = db.select().from(projectPayables)
        .where(eq(projectPayables.id, params.payableId)).get();
      if (p) {
        const newPaid = (p.paidAmount || 0) + params.amount;
        db.update(projectPayables).set({
          paidAmount: newPaid,
          status: newPaid >= p.payableAmount ? 'paid' : 'partial',
          updatedAt: new Date().toISOString(),
        }).where(eq(projectPayables.id, params.payableId)).run();
      }
    }

    return payment;
  },

  getPaymentPriorities(projectId: string) {
    return db.select().from(projectPayables)
      .where(and(
        eq(projectPayables.projectId, projectId),
        eq(projectPayables.status, 'pending'),
      )).orderBy(desc(projectPayables.priority)).all();
  },
};

export const revenueService = {
  createReceivable(params: {
    companyId: string; projectId: string; receivableType: string;
    description: string; billedAmount: number;
    ipcId?: string; variationId?: string; claimId?: string;
    retentionAmount?: number; dueDate?: string;
  }) {
    return db.insert(projectReceivables).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, receivableType: params.receivableType,
      description: params.description,
      billedAmount: params.billedAmount,
      ipcId: params.ipcId || null,
      variationId: params.variationId || null,
      claimId: params.claimId || null,
      retentionAmount: params.retentionAmount || 0,
      dueDate: params.dueDate || null,
    }).returning().get();
  },

  recordClientPayment(params: {
    companyId: string; projectId: string; amount: number;
    receiptDate: string; receivedBy: string;
    receivableId?: string; paymentMethod?: string; paymentRef?: string;
  }) {
    const receipt = db.insert(clientPaymentReceipts).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, amount: params.amount,
      receiptDate: params.receiptDate, receivedBy: params.receivedBy,
      receivableId: params.receivableId || null,
      paymentMethod: params.paymentMethod || 'bank_transfer',
      paymentRef: params.paymentRef || null,
    }).returning().get();

    if (params.receivableId) {
      const r = db.select().from(projectReceivables)
        .where(eq(projectReceivables.id, params.receivableId)).get();
      if (r) {
        const newReceived = (r.receivedAmount || 0) + params.amount;
        db.update(projectReceivables).set({
          receivedAmount: newReceived,
          status: newReceived >= r.billedAmount ? 'received' : 'partial',
          updatedAt: new Date().toISOString(),
        }).where(eq(projectReceivables.id, params.receivableId)).run();
      }
    }

    return receipt;
  },
};

export const cashflowService = {
  createForecast(params: {
    companyId: string; projectId: string;
    periodStart: string; periodEnd: string;
    expectedInflows: number; expectedOutflows: number;
    runningBalance: number; forecastType?: string; preparedBy?: string;
  }) {
    return db.insert(projectCashflowForecasts).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId,
      periodStart: params.periodStart, periodEnd: params.periodEnd,
      expectedInflows: params.expectedInflows,
      expectedOutflows: params.expectedOutflows,
      netCashflow: params.expectedInflows - params.expectedOutflows,
      runningBalance: params.runningBalance,
      forecastType: params.forecastType || 'weekly',
      preparedBy: params.preparedBy || null,
    }).returning().get();
  },

  getCashflowForecast(projectId: string) {
    return db.select().from(projectCashflowForecasts)
      .where(eq(projectCashflowForecasts.projectId, projectId))
      .orderBy(desc(projectCashflowForecasts.periodStart)).all();
  },
};

export const marginService = {
  createMarginForecast(params: {
    companyId: string; projectId: string;
    contractSum: number; forecastRevenue: number;
    approvedBudget: number; forecastFinalCost: number;
    committedCost?: number; actualCost?: number;
    costToComplete?: number; approvedVariations?: number;
    potentialClaims?: number; previousMarginPct?: number;
    preparedBy?: string;
  }) {
    const forecastMargin = params.forecastRevenue - params.forecastFinalCost;
    const marginPct = params.forecastRevenue > 0
      ? (forecastMargin / params.forecastRevenue) * 100 : 0;
    const marginVariance = params.previousMarginPct != null
      ? marginPct - params.previousMarginPct : null;

    return db.insert(projectMarginForecasts).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId,
      contractSum: params.contractSum,
      forecastRevenue: params.forecastRevenue,
      approvedBudget: params.approvedBudget,
      forecastFinalCost: params.forecastFinalCost,
      forecastMargin, marginPct,
      committedCost: params.committedCost || 0,
      actualCost: params.actualCost || 0,
      costToComplete: params.costToComplete || 0,
      approvedVariations: params.approvedVariations || 0,
      potentialClaims: params.potentialClaims || 0,
      previousMarginPct: params.previousMarginPct ?? null,
      marginVariance,
      preparedBy: params.preparedBy || null,
    }).returning().get();
  },

  getMarginHistory(projectId: string) {
    return db.select().from(projectMarginForecasts)
      .where(eq(projectMarginForecasts.projectId, projectId))
      .orderBy(desc(projectMarginForecasts.forecastDate)).all();
  },

  getLatestMargin(projectId: string) {
    return db.select().from(projectMarginForecasts)
      .where(eq(projectMarginForecasts.projectId, projectId))
      .orderBy(desc(projectMarginForecasts.forecastDate)).get();
  },
};

export const costAlertService = {
  flagOverrun(params: {
    companyId: string; projectId: string; costCodeId: string;
    budgetAmount: number; committedAmount?: number;
    actualAmount?: number; variancePct: number;
    severity: string; description: string;
  }) {
    return db.insert(costOverrunAlerts).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, costCodeId: params.costCodeId,
      budgetAmount: params.budgetAmount,
      committedAmount: params.committedAmount || 0,
      actualAmount: params.actualAmount || 0,
      variancePct: params.variancePct,
      severity: params.severity, description: params.description,
    }).returning().get();
  },

  acknowledgeAlert(alertId: string, acknowledgedBy: string) {
    return db.update(costOverrunAlerts).set({
      status: 'acknowledged', acknowledgedBy,
      acknowledgedAt: new Date().toISOString(), updatedAt: new Date().toISOString(),
    }).where(eq(costOverrunAlerts.id, alertId)).returning().get();
  },

  resolveAlert(alertId: string, resolution: string) {
    return db.update(costOverrunAlerts).set({
      status: 'resolved', resolution, updatedAt: new Date().toISOString(),
    }).where(eq(costOverrunAlerts.id, alertId)).returning().get();
  },
};

export const financeReviewService = {
  submitReview(params: {
    companyId: string; projectId: string;
    reviewedBy: string; reviewType?: string;
    decision?: string; periodStart?: string; periodEnd?: string;
    role?: string; comments?: string;
  }) {
    return db.insert(financeReviews).values({
      id: uuid(), companyId: params.companyId,
      projectId: params.projectId, reviewedBy: params.reviewedBy,
      reviewType: params.reviewType || 'monthly',
      decision: params.decision || 'no_action',
      periodStart: params.periodStart || null,
      periodEnd: params.periodEnd || null,
      role: params.role || 'finance_manager',
      comments: params.comments || null,
    }).returning().get();
  },

  getProjectReviews(projectId: string) {
    return db.select().from(financeReviews)
      .where(eq(financeReviews.projectId, projectId)).all();
  },
};
