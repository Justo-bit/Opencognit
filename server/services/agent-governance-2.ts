import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { aiAgentAuditEvents, aiAgentPerformanceMetrics, aiAgentReviewThresholds, aiAgentReviewQueues, aigReviews } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const agentAuditService = {
  log(params: { companyId: string; agentId: string; eventType: string; eventDescription: string; affectedSubjectType?: string; affectedSubjectId?: string; eventData?: string }) {
    return db.insert(aiAgentAuditEvents).values({ id: uuid(), companyId: params.companyId, agentId: params.agentId, eventType: params.eventType, eventDescription: params.eventDescription, affectedSubjectType: params.affectedSubjectType||null, affectedSubjectId: params.affectedSubjectId||null, eventData: params.eventData||null }).returning().get();
  },
};
export const agentPerformanceService = {
  computeMetrics(params: { companyId: string; agentId: string; periodStart: string; periodEnd: string }) {
    const recs = db.select().from(aiAgentRecommendations).where(and(eq(aiAgentRecommendations.agentId, params.agentId))).all();
    let accepted=0,rejected=0,modified=0,escalated=0;
    for(const r of recs){ const rev=db.select().from(aiAgentReviews).where(eq(aiAgentReviews.recommendationId,r.id)).all(); for(const v of rev){ if(v.decision==='approve')accepted++; else if(v.decision==='reject')rejected++; else if(v.decision==='modify')modified++; else if(v.decision==='escalate')escalated++; } }
    const total=accepted+rejected+modified+escalated;
    return db.insert(aiAgentPerformanceMetrics).values({ id: uuid(), companyId: params.companyId, agentId: params.agentId, periodStart: params.periodStart, periodEnd: params.periodEnd, totalRecommendations: recs.length, accepted, rejected, modified, escalated, acceptanceRate: total>0?accepted/total:0 }).returning().get();
  },
};
export const thresholdService = {
  set(params: { companyId: string; thresholdType: string; thresholdValue: number; action?: string; agentId?: string; controlRoom?: string }) {
    return db.insert(aiAgentReviewThresholds).values({ id: uuid(), companyId: params.companyId, thresholdType: params.thresholdType, thresholdValue: params.thresholdValue, action: params.action||'flag_for_review', agentId: params.agentId||null, controlRoom: params.controlRoom||null }).returning().get();
  },
};
export const reviewQueueService = {
  enqueue(params: { companyId: string; recommendationId: string; priority?: string; assignedTo?: string; dueAt?: string }) {
    return db.insert(aiAgentReviewQueues).values({ id: uuid(), companyId: params.companyId, recommendationId: params.recommendationId, priority: params.priority||'normal', assignedTo: params.assignedTo||null, dueAt: params.dueAt||null }).returning().get();
  },
};
export const aigReviewService = {
  submit(params: { companyId: string; reviewedBy: string; decision?: string; role?: string; projectId?: string; comments?: string }) {
    return db.insert(aigReviews).values({ id: uuid(), companyId: params.companyId, reviewedBy: params.reviewedBy, decision: params.decision||'no_action', role: params.role||'ai_governance_lead', projectId: params.projectId||null, comments: params.comments||null }).returning().get();
  },
};
