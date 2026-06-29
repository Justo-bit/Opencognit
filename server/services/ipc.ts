// =============================================================================
// IPC + BOQ-vs-Actual Service — PR-IPC-1
// =============================================================================
import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import { ipcCertificates, ipcItems, measurementSheets, boqVsActualRecords, ipcAgentRecommendations } from '../db/schema';
import { eq, and, desc } from 'drizzle-orm';

export const ipcService = {
  createIPC(params: { companyId: string; projectId: string; contractId: string; periodStart: string; periodEnd: string; preparedBy: string; ipcNumber?: string; previouslyCertified?: number }) {
    return db.insert(ipcCertificates).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, contractId: params.contractId, periodStart: params.periodStart, periodEnd: params.periodEnd, preparedBy: params.preparedBy, ipcNumber: params.ipcNumber || null, previouslyCertified: params.previouslyCertified || 0 }).returning().get();
  },
  addIPCItem(params: { ipcId: string; boqItemId: string; itemDescription: string; boqQuantity: number; unitRate: number; thisPeriodQuantity: number; previousQuantity?: number; unit?: string; measurementBasis?: string }) {
    const cumulativeQuantity = (params.previousQuantity || 0) + params.thisPeriodQuantity;
    return db.insert(ipcItems).values({ id: uuid(), ipcId: params.ipcId, boqItemId: params.boqItemId, itemDescription: params.itemDescription, boqQuantity: params.boqQuantity, unitRate: params.unitRate, thisPeriodQuantity: params.thisPeriodQuantity, thisPeriodAmount: params.thisPeriodQuantity * params.unitRate, previousQuantity: params.previousQuantity || 0, cumulativeQuantity, remainingQuantity: params.boqQuantity - cumulativeQuantity, cumulativeAmount: cumulativeQuantity * params.unitRate, unit: params.unit || 'No.', measurementBasis: params.measurementBasis || null }).returning().get();
  },
  addMeasurement(params: { ipcItemId: string; description: string; quantity: number; measuredBy: string; measurementType?: string; location?: string; dimensionLength?: number; dimensionWidth?: number; dimensionHeight?: number; unit?: string; sketchRef?: string; photoRef?: string }) {
    return db.insert(measurementSheets).values({ id: uuid(), ipcItemId: params.ipcItemId, description: params.description, quantity: params.quantity, measuredBy: params.measuredBy, measurementType: params.measurementType || 'field_measure', location: params.location || null, dimensionLength: params.dimensionLength ?? null, dimensionWidth: params.dimensionWidth ?? null, dimensionHeight: params.dimensionHeight ?? null, unit: params.unit || 'm3', sketchRef: params.sketchRef || null, photoRef: params.photoRef || null }).returning().get();
  },
  submitIPC(ipcId: string) {
    const items = db.select().from(ipcItems).where(eq(ipcItems.ipcId, ipcId)).all();
    const thisPeriod = items.reduce((s, i) => s + i.thisPeriodAmount, 0);
    const cumulative = items.reduce((s, i) => s + i.cumulativeAmount, 0);
    return db.update(ipcCertificates).set({ status: 'submitted', workDoneThisPeriod: thisPeriod, cumulativeWorkDone: cumulative, amountDue: thisPeriod, updatedAt: new Date().toISOString() }).where(eq(ipcCertificates.id, ipcId)).returning().get();
  },
  certifyIPC(ipcId: string, certifiedBy: string, certifiedAmount: number, certificationRef?: string) {
    return db.update(ipcCertificates).set({ status: 'certified', certifiedBy, certifiedAt: new Date().toISOString(), certifiedAmount, certificationRef: certificationRef || null, updatedAt: new Date().toISOString() }).where(eq(ipcCertificates.id, ipcId)).returning().get();
  },
  getIPCWithDetails(ipcId: string) {
    const ipc = db.select().from(ipcCertificates).where(eq(ipcCertificates.id, ipcId)).get();
    if (!ipc) return null;
    const items = db.select().from(ipcItems).where(eq(ipcItems.ipcId, ipcId)).all();
    return { ...ipc, items };
  },
};

export const boqVsActualService = {
  recordComparison(params: { companyId: string; projectId: string; boqItemId: string; budgetQuantity: number; budgetAmount: number; actualQuantity: number; actualAmount: number; asOfDate: string }) {
    return db.insert(boqVsActualRecords).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, boqItemId: params.boqItemId, budgetQuantity: params.budgetQuantity, budgetAmount: params.budgetAmount, actualQuantity: params.actualQuantity, actualAmount: params.actualAmount, quantityVariance: params.actualQuantity - params.budgetQuantity, amountVariance: params.actualAmount - params.budgetAmount, variancePct: params.budgetAmount > 0 ? ((params.actualAmount - params.budgetAmount) / params.budgetAmount) * 100 : 0, asOfDate: params.asOfDate }).returning().get();
  },
  getProjectVariances(projectId: string) {
    return db.select().from(boqVsActualRecords).where(eq(boqVsActualRecords.projectId, projectId)).orderBy(desc(boqVsActualRecords.asOfDate)).all();
  },
};

export const ipcAgentService = {
  createRecommendation(params: { companyId: string; projectId: string; issue: string; recommendedAction: string; ipcId?: string; boqItemId?: string; evidence?: string; riskLevel?: string; owner?: string }) {
    return db.insert(ipcAgentRecommendations).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, issue: params.issue, recommendedAction: params.recommendedAction, ipcId: params.ipcId || null, boqItemId: params.boqItemId || null, evidence: params.evidence || null, riskLevel: params.riskLevel || 'medium', owner: params.owner || null }).returning().get();
  },
  reviewRecommendation(recId: string) { return db.update(ipcAgentRecommendations).set({ status: 'reviewed', reviewedAt: new Date().toISOString() }).where(eq(ipcAgentRecommendations.id, recId)).returning().get(); },
};
