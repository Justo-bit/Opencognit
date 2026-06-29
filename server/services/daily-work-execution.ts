// =============================================================================
// Daily Work Execution Service — PR-DWE-1 Work Pack + Execution Record
// =============================================================================
import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { dailyWorkPacks, workPackItems, dailyWorkExecutionRecords, workExecutionResources, dweAgentRecommendations } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const workPackService = {
  createWorkPack(params: { companyId: string; projectId: string; title: string; workDate: string; description?: string; activityId?: string; shift?: string; foremanId?: string; packNumber?: string; plannedOutput?: string }) {
    return db.insert(dailyWorkPacks).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, title: params.title, workDate: params.workDate, description: params.description||null, activityId: params.activityId||null, shift: params.shift||'day', foremanId: params.foremanId||null, packNumber: params.packNumber||null, plannedOutput: params.plannedOutput||null }).returning().get();
  },
  addWorkPackItem(params: { workPackId: string; description: string; plannedQuantity: number; boqItemId?: string; unit?: string; crewId?: string; equipmentId?: string }) {
    return db.insert(workPackItems).values({ id: uuid(), workPackId: params.workPackId, description: params.description, plannedQuantity: params.plannedQuantity, boqItemId: params.boqItemId||null, unit: params.unit||'No.', crewId: params.crewId||null, equipmentId: params.equipmentId||null }).returning().get();
  },
  setReadiness(packId: string, readiness: { materials?: boolean; equipment?: boolean; labour?: boolean; drawings?: boolean; permits?: boolean; method?: boolean; qaHse?: boolean; subcontractor?: boolean }) {
    const r: any = {}; if (readiness.materials!==undefined) r.readinessMaterials = readiness.materials?1:0; if (readiness.equipment!==undefined) r.readinessEquipment = readiness.equipment?1:0; if (readiness.labour!==undefined) r.readinessLabour = readiness.labour?1:0; if (readiness.drawings!==undefined) r.readinessDrawings = readiness.drawings?1:0; if (readiness.permits!==undefined) r.readinessPermits = readiness.permits?1:0; if (readiness.method!==undefined) r.readinessMethod = readiness.method?1:0; if (readiness.qaHse!==undefined) r.readinessQaHse = readiness.qaHse?1:0; if (readiness.subcontractor!==undefined) r.readinessSubcontractor = readiness.subcontractor?1:0;
    const dimensions = ['readinessMaterials','readinessEquipment','readinessLabour','readinessDrawings','readinessPermits','readinessMethod','readinessQaHse','readinessSubcontractor'];
    const pack = db.select().from(dailyWorkPacks).where(eq(dailyWorkPacks.id, packId)).get();
    const values: any = {};
    for (const d of dimensions) values[d] = r[d]!==undefined ? r[d] : (pack?.[d as keyof typeof pack]||0);
    values.readinessOverall = dimensions.every(d=>values[d]===1)?1:0;
    values.updatedAt = new Date().toISOString();
    return db.update(dailyWorkPacks).set(values).where(eq(dailyWorkPacks.id, packId)).returning().get();
  },
  releaseWorkPack(packId: string, releasedBy: string) {
    return db.update(dailyWorkPacks).set({ status: 'released', releasedBy, releasedAt: new Date().toISOString(), updatedAt: new Date().toISOString() }).where(eq(dailyWorkPacks.id, packId)).returning().get();
  },
};

export const executionRecordService = {
  recordExecution(params: { companyId: string; projectId: string; workPackId: string; recordDate: string; description: string; actualQuantity: number; recordedBy: string; boqItemId?: string; activityId?: string; unit?: string; crewSize?: number; hoursWorked?: number; equipmentUsed?: string; materialsConsumed?: string; weatherConditions?: string; delaysEncountered?: string; hseIncidents?: number; qualityIssues?: number; foremanId?: string }) {
    return db.insert(dailyWorkExecutionRecords).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, workPackId: params.workPackId, recordDate: params.recordDate, description: params.description, actualQuantity: params.actualQuantity, recordedBy: params.recordedBy, boqItemId: params.boqItemId||null, activityId: params.activityId||null, unit: params.unit||'No.', crewSize: params.crewSize||0, hoursWorked: params.hoursWorked||0, equipmentUsed: params.equipmentUsed||null, materialsConsumed: params.materialsConsumed||null, weatherConditions: params.weatherConditions||null, delaysEncountered: params.delaysEncountered||null, hseIncidents: params.hseIncidents||0, qualityIssues: params.qualityIssues||0, foremanId: params.foremanId||null }).returning().get();
  },
  addResource(params: { executionRecordId: string; resourceType: string; resourceId: string; quantity: number; unit?: string; hoursUsed?: number }) {
    return db.insert(workExecutionResources).values({ id: uuid(), executionRecordId: params.executionRecordId, resourceType: params.resourceType, resourceId: params.resourceId, quantity: params.quantity, unit: params.unit||'No.', hoursUsed: params.hoursUsed??null }).returning().get();
  },
};

export const dweAgentService = {
  createRecommendation(params: { companyId: string; projectId: string; issue: string; recommendedAction: string; workPackId?: string; executionRecordId?: string; evidence?: string; riskLevel?: string; owner?: string }) {
    return db.insert(dweAgentRecommendations).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, issue: params.issue, recommendedAction: params.recommendedAction, workPackId: params.workPackId||null, executionRecordId: params.executionRecordId||null, evidence: params.evidence||null, riskLevel: params.riskLevel||'medium', owner: params.owner||null }).returning().get();
  },
};
