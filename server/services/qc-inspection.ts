// =============================================================================
// QA/QC Service — PR-QC-1 Inspection + Test Plan Backbone
// =============================================================================

import { v4 as uuid } from 'uuid';
import { db } from '../db/client';
import { inspectionTestPlans, itpCheckpoints, materialInspections, workInspections, qcAgentRecommendations } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const itpService = {
  createITP(params: { companyId: string; projectId: string; title: string; preparedBy: string; discipline?: string; activityId?: string; boqItemId?: string; itpNumber?: string; specificationRef?: string; drawingRef?: string; description?: string }) {
    return db.insert(inspectionTestPlans).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, title: params.title, preparedBy: params.preparedBy, discipline: params.discipline || 'civil', activityId: params.activityId || null, boqItemId: params.boqItemId || null, itpNumber: params.itpNumber || null, specificationRef: params.specificationRef || null, drawingRef: params.drawingRef || null, description: params.description || null }).returning().get();
  },
  addCheckpoint(params: { itpId: string; sequenceNumber: number; description: string; checkpointType?: string; acceptanceCriteria?: string; testMethod?: string; frequency?: string; responsibleParty?: string; witnessRequired?: boolean; witnessRole?: string }) {
    return db.insert(itpCheckpoints).values({ id: uuid(), itpId: params.itpId, sequenceNumber: params.sequenceNumber, description: params.description, checkpointType: params.checkpointType || 'hold_point', acceptanceCriteria: params.acceptanceCriteria || null, testMethod: params.testMethod || null, frequency: params.frequency || null, responsibleParty: params.responsibleParty || null, witnessRequired: params.witnessRequired ? 1 : 0, witnessRole: params.witnessRole || null }).returning().get();
  },
  approveITP(itpId: string, approvedBy: string) {
    return db.update(inspectionTestPlans).set({ status: 'approved', approvedBy, approvedAt: new Date().toISOString(), updatedAt: new Date().toISOString() }).where(eq(inspectionTestPlans.id, itpId)).returning().get();
  },
  inspectCheckpoint(checkpointId: string, inspectedBy: string, result: string, comments?: string) {
    return db.update(itpCheckpoints).set({ status: 'inspected', inspectedBy, inspectedAt: new Date().toISOString(), result, comments: comments || null }).where(eq(itpCheckpoints.id, checkpointId)).returning().get();
  },
  getITPWithCheckpoints(itpId: string) {
    const itp = db.select().from(inspectionTestPlans).where(eq(inspectionTestPlans.id, itpId)).get();
    if (!itp) return null;
    const checkpoints = db.select().from(itpCheckpoints).where(eq(itpCheckpoints.itpId, itpId)).all();
    return { ...itp, checkpoints };
  },
};

export const materialInspectionService = {
  inspectMaterial(params: { companyId: string; projectId: string; materialName: string; quantityInspected: number; inspectedBy: string; quantityPassed: number; quantityRejected?: number; grnId?: string; grnItemId?: string; batchNumber?: string; inspectionType?: string; testResults?: string; standardRef?: string; rejectionReason?: string }) {
    const result = (params.quantityRejected || 0) > 0 ? 'partial_reject' : params.quantityPassed >= params.quantityInspected ? 'passed' : 'partial_reject';
    return db.insert(materialInspections).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, materialName: params.materialName, quantityInspected: params.quantityInspected, quantityPassed: params.quantityPassed, quantityRejected: params.quantityRejected || 0, inspectedBy: params.inspectedBy, result, grnId: params.grnId || null, grnItemId: params.grnItemId || null, batchNumber: params.batchNumber || null, inspectionType: params.inspectionType || 'visual', testResults: params.testResults || null, standardRef: params.standardRef || null, rejectionReason: params.rejectionReason || null }).returning().get();
  },
};

export const workInspectionService = {
  inspectWork(params: { companyId: string; projectId: string; description: string; inspectedBy: string; result: string; activityId?: string; dailyWorkPackId?: string; itpCheckpointId?: string; inspectionType?: string; location?: string; defectsFound?: number; reworkRequired?: boolean; witnessPresent?: string }) {
    return db.insert(workInspections).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, description: params.description, inspectedBy: params.inspectedBy, result: params.result, activityId: params.activityId || null, dailyWorkPackId: params.dailyWorkPackId || null, itpCheckpointId: params.itpCheckpointId || null, inspectionType: params.inspectionType || 'in_process', location: params.location || null, defectsFound: params.defectsFound || 0, reworkRequired: params.reworkRequired ? 1 : 0, witnessPresent: params.witnessPresent || null }).returning().get();
  },
};

export const qcAgentService = {
  createRecommendation(params: { companyId: string; projectId: string; issue: string; recommendedAction: string; itpId?: string; inspectionId?: string; evidence?: string; riskLevel?: string; owner?: string }) {
    return db.insert(qcAgentRecommendations).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, issue: params.issue, recommendedAction: params.recommendedAction, itpId: params.itpId || null, inspectionId: params.inspectionId || null, evidence: params.evidence || null, riskLevel: params.riskLevel || 'medium', owner: params.owner || null }).returning().get();
  },
  reviewRecommendation(recId: string) {
    return db.update(qcAgentRecommendations).set({ status: 'reviewed', reviewedAt: new Date().toISOString() }).where(eq(qcAgentRecommendations.id, recId)).returning().get();
  },
};
