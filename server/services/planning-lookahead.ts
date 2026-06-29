import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { lookaheadPlans, lookaheadReadiness, scheduleBlockers, planningReviews, plnReviews } from '../db/schema';
import { eq } from 'drizzle-orm';

export const lookaheadService = {
  generate(params: { companyId: string; projectId: string; lookaheadWeeks: number; startDate: string; endDate: string }) {
    return db.insert(lookaheadPlans).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, lookaheadWeeks: params.lookaheadWeeks, startDate: params.startDate, endDate: params.endDate, isCurrent: 1 }).returning().get();
  },
  setReadiness(params: { lookaheadId: string; activityId: string; materials?: boolean; equipment?: boolean; labour?: boolean; drawings?: boolean; permits?: boolean; rfi?: boolean; method?: boolean; qaHse?: boolean; subcontractor?: boolean; leadTimeDays?: number }) {
    const dims = ['materials','equipment','labour','drawings','permits','rfi','method','qaHse','subcontractor'];
    const vals: any = {}; for (const d of dims) vals[`readiness_${d}`] = params[d as keyof typeof params] ? 1 : 0;
    vals.readinessOverall = dims.every(d => vals[`readiness_${d}`]===1) ? 1 : 0;
    return db.insert(lookaheadReadiness).values({ id: uuid(), lookaheadId: params.lookaheadId, activityId: params.activityId, ...vals, leadTimeDays: params.leadTimeDays??null }).returning().get();
  },
  nearTermRisk(lookaheadId: string) {
    const reads = db.select().from(lookaheadReadiness).where(eq(lookaheadReadiness.lookaheadId, lookaheadId)).all();
    const blockers = db.select().from(scheduleBlockers).all();
    let score = 0; reads.forEach(r => { if (!r.readinessOverall) score += 40; if (!r.readinessPermits) score += 25; if (!r.readinessMaterials || !r.readinessEquipment || !r.readinessLabour) score += 3; });
    blockers.filter(b => b.status==='active').forEach(b => { if (b.severity==='critical') score += 40; else if (b.severity==='high') score += 25; else score += 10; });
    return { score, level: score >= 100 ? 'critical' : score >= 60 ? 'high' : score >= 30 ? 'medium' : 'low' };
  },
};

export const blockerService = {
  raise(params: { companyId: string; projectId: string; activityId: string; blockerType: string; description: string; severity: string; raisedBy: string; cascadingPredecessors?: string }) {
    return db.insert(scheduleBlockers).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, activityId: params.activityId, blockerType: params.blockerType, description: params.description, severity: params.severity, raisedBy: params.raisedBy, cascadingPredecessors: params.cascadingPredecessors||null }).returning().get();
  },
  resolve(blockerId: string, resolvedBy: string, resolution: string) {
    return db.update(scheduleBlockers).set({ status: 'resolved', resolvedBy, resolution, resolvedAt: new Date().toISOString(), updatedAt: new Date().toISOString() }).where(eq(scheduleBlockers.id, blockerId)).returning().get();
  },
};

export const planningReviewService = {
  submit(params: { companyId: string; reviewedBy: string; reviewType?: string; decision?: string; role?: string; projectId?: string; comments?: string }) {
    return db.insert(planningReviews).values({ id: uuid(), companyId: params.companyId, reviewedBy: params.reviewedBy, reviewType: params.reviewType||'lookahead', decision: params.decision||'no_action', role: params.role||'planner', projectId: params.projectId||null, comments: params.comments||null }).returning().get();
  },
  submitPlnReview(params: { companyId: string; reviewedBy: string; decision?: string; role?: string; projectId?: string; comments?: string }) {
    return db.insert(plnReviews).values({ id: uuid(), companyId: params.companyId, reviewedBy: params.reviewedBy, decision: params.decision||'no_action', role: params.role||'project_manager', projectId: params.projectId||null, comments: params.comments||null }).returning().get();
  },
};
