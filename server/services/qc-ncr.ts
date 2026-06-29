// =============================================================================
// QA/QC — NCR, Corrective Actions, Test Results, Hold Points (PR-QC-2)
// =============================================================================
import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import { nonConformanceReports, ncrCorrectiveActions, testResults, qcHoldPoints, qcReviews } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const ncrService = {
  raiseNCR(params: { companyId: string; projectId: string; title: string; description: string; raisedBy: string; ncrType?: string; severity?: string; inspectionId?: string; activityId?: string; ncrNumber?: string }) {
    return db.insert(nonConformanceReports).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, title: params.title, description: params.description, raisedBy: params.raisedBy, ncrType: params.ncrType || 'minor', severity: params.severity || 'low', inspectionId: params.inspectionId || null, activityId: params.activityId || null, ncrNumber: params.ncrNumber || null }).returning().get();
  },
  setRootCause(ncrId: string, rootCause: string) {
    return db.update(nonConformanceReports).set({ rootCause, updatedAt: new Date().toISOString() }).where(eq(nonConformanceReports.id, ncrId)).returning().get();
  },
  setDisposition(ncrId: string, disposition: string, dispositionBy: string, costImpact?: number, scheduleImpactDays?: number) {
    return db.update(nonConformanceReports).set({ disposition, dispositionBy, dispositionAt: new Date().toISOString(), status: 'dispositioned', costImpact: costImpact || 0, scheduleImpactDays: scheduleImpactDays || 0, updatedAt: new Date().toISOString() }).where(eq(nonConformanceReports.id, ncrId)).returning().get();
  },
  closeNCR(ncrId: string, closedBy: string) {
    return db.update(nonConformanceReports).set({ status: 'closed', closedBy, closedAt: new Date().toISOString(), updatedAt: new Date().toISOString() }).where(eq(nonConformanceReports.id, ncrId)).returning().get();
  },
  addCorrectiveAction(params: { ncrId: string; sequenceNumber: number; actionDescription: string; responsibleParty: string; targetDate?: string }) {
    return db.insert(ncrCorrectiveActions).values({ id: uuid(), ncrId: params.ncrId, sequenceNumber: params.sequenceNumber, actionDescription: params.actionDescription, responsibleParty: params.responsibleParty, targetDate: params.targetDate || null }).returning().get();
  },
  completeCorrectiveAction(actionId: string, completedBy: string, evidence?: string) {
    return db.update(ncrCorrectiveActions).set({ completed: 1, completedBy, completedAt: new Date().toISOString(), evidence: evidence || null }).where(eq(ncrCorrectiveActions.id, actionId)).returning().get();
  },
  verifyCorrectiveAction(actionId: string, verifiedBy: string) {
    return db.update(ncrCorrectiveActions).set({ verifiedBy, verifiedAt: new Date().toISOString() }).where(eq(ncrCorrectiveActions.id, actionId)).returning().get();
  },
};

export const testResultService = {
  recordTest(params: { companyId: string; projectId: string; testName: string; testType: string; testValue: string; testedBy: string; passed: boolean; inspectionId?: string; itpCheckpointId?: string; testStandard?: string; sampleId?: string; acceptableRange?: string; equipmentUsed?: string; certificateRef?: string }) {
    return db.insert(testResults).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, testName: params.testName, testType: params.testType, testValue: params.testValue, testedBy: params.testedBy, passed: params.passed ? 1 : 0, inspectionId: params.inspectionId || null, itpCheckpointId: params.itpCheckpointId || null, testStandard: params.testStandard || null, sampleId: params.sampleId || null, acceptableRange: params.acceptableRange || null, equipmentUsed: params.equipmentUsed || null, certificateRef: params.certificateRef || null }).returning().get();
  },
};

export const holdPointService = {
  placeHold(params: { companyId: string; projectId: string; description: string; holdReason: string; placedBy: string; activityId?: string; itpCheckpointId?: string }) {
    return db.insert(qcHoldPoints).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, description: params.description, holdReason: params.holdReason, placedBy: params.placedBy, activityId: params.activityId || null, itpCheckpointId: params.itpCheckpointId || null }).returning().get();
  },
  releaseHold(holdId: string, releasedBy: string, releaseConditions?: string) {
    return db.update(qcHoldPoints).set({ status: 'released', releasedBy, releasedAt: new Date().toISOString(), releaseConditions: releaseConditions || null }).where(eq(qcHoldPoints.id, holdId)).returning().get();
  },
};

export const qcReviewService = {
  submitReview(params: { companyId: string; projectId: string; reviewedBy: string; reviewType?: string; decision?: string; role?: string; comments?: string }) {
    return db.insert(qcReviews).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, reviewedBy: params.reviewedBy, reviewType: params.reviewType || 'daily', decision: params.decision || 'no_action', role: params.role || 'qc_engineer', comments: params.comments || null }).returning().get();
  },
};
