import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { projectActivities, activityDependencies, projectBaselines, scheduleBaselineVersions, plnAgentRecommendations } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const activityService = {
  create(params: { companyId: string; projectId: string; activityCode: string; activityName: string; wbsCode?: string; description?: string; activityType?: string; plannedStart?: string; plannedEnd?: string; durationDays?: number; parentId?: string; boqItemId?: string; assignedTo?: string }) {
    return db.insert(projectActivities).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, activityCode: params.activityCode, activityName: params.activityName, wbsCode: params.wbsCode||null, description: params.description||null, activityType: params.activityType||'construction', plannedStart: params.plannedStart||null, plannedEnd: params.plannedEnd||null, durationDays: params.durationDays??null, parentId: params.parentId||null, boqItemId: params.boqItemId||null, assignedTo: params.assignedTo||null }).returning().get();
  },
  setStatus(activityId: string, status: string, actualStart?: string, actualEnd?: string, actualPct?: number) {
    const u: any = { status, updatedAt: new Date().toISOString() };
    if (actualStart) u.actualStart = actualStart; if (actualEnd) u.actualEnd = actualEnd; if (actualPct!==undefined) u.actualPct = actualPct;
    return db.update(projectActivities).set(u).where(eq(projectActivities.id, activityId)).returning().get();
  },
};

export const dependenciesService = {
  add(params: { predecessorId: string; successorId: string; dependencyType?: string; lagDays?: number }) {
    return db.insert(activityDependencies).values({ id: uuid(), predecessorId: params.predecessorId, successorId: params.successorId, dependencyType: params.dependencyType||'FS', lagDays: params.lagDays||0 }).returning().get();
  },
};

export const cpmService = {
  compute(projectId: string) {
    const acts = db.select().from(projectActivities).where(eq(projectActivities.projectId, projectId)).all();
    const deps = db.select().from(activityDependencies).where(
      and(eq(activityDependencies.isActive, 1))
    ).all();
    // Forward pass
    const es: Record<string, number> = {}, ef: Record<string, number> = {};
    for (const a of acts) { const dur = a.durationDays||0; es[a.id] = 0; ef[a.id] = dur; }
    for (const d of deps) {
      const predEf = ef[d.predecessorId]||0, succEs = es[d.successorId]||0, lag = d.lagDays||0;
      const proposed = predEf + lag;
      if (proposed > succEs) { es[d.successorId] = proposed; ef[d.successorId] = proposed + (acts.find(a=>a.id===d.successorId)?.durationDays||0); }
    }
    const maxEf = Math.max(...Object.values(ef), 0);
    // Backward pass
    const ls: Record<string, number> = {}, lf: Record<string, number> = {};
    for (const a of acts) { ls[a.id] = maxEf - (a.durationDays||0); lf[a.id] = maxEf; }
    const sortedDeps = [...deps].reverse();
    for (const d of sortedDeps) {
      const succLs = ls[d.successorId]!==undefined ? ls[d.successorId] : maxEf, predLf = lf[d.predecessorId]!==undefined ? lf[d.predecessorId] : maxEf;
      const proposed = succLs - (d.lagDays||0);
      if (proposed < predLf) { lf[d.predecessorId] = proposed; ls[d.predecessorId] = proposed - (acts.find(a=>a.id===d.predecessorId)?.durationDays||0); }
    }
    // Update activities with CPM values
    for (const a of acts) {
      const tf = (ls[a.id]!==undefined ? ls[a.id] : maxEf) - (ef[a.id]!==undefined ? ef[a.id] : 0);
      const isCritical = Math.abs(tf) < 0.001 ? 1 : 0;
      db.update(projectActivities).set({ earlyStart: es[a.id]||0, earlyFinish: ef[a.id]||0, lateStart: ls[a.id]!==undefined ? ls[a.id] : 0, lateFinish: lf[a.id]!==undefined ? lf[a.id] : 0, totalFloat: tf, isCritical, updatedAt: new Date().toISOString() }).where(eq(projectActivities.id, a.id)).run();
    }
    return acts.map(a => ({ id: a.id, es: es[a.id], ef: ef[a.id], ls: ls[a.id], lf: lf[a.id], tf: (ls[a.id]!==undefined ? ls[a.id] : maxEf) - (ef[a.id]||0), critical: Math.abs((ls[a.id]!==undefined ? ls[a.id] : maxEf) - (ef[a.id]||0)) < 0.001 }));
  },
};

export const baselineService = {
  create(params: { companyId: string; projectId: string; baselineName: string; baselineDate: string; baselineType?: string; approvedBy?: string }) {
    return db.insert(projectBaselines).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, baselineName: params.baselineName, baselineDate: params.baselineDate, baselineType: params.baselineType||'schedule', approvedBy: params.approvedBy||null, isCurrent: 1 }).returning().get();
  },
  snapshotActivity(baselineId: string, activityId: string, plannedStart: string, plannedEnd: string) {
    return db.insert(scheduleBaselineVersions).values({ id: uuid(), baselineId, activityId, plannedStart, plannedEnd, durationDays: null }).returning().get();
  },
};

export const plnAgentService = {
  recommend(params: { companyId: string; projectId: string; issue: string; recommendedAction: string; activityId?: string; evidence?: string; riskLevel?: string; owner?: string }) {
    return db.insert(plnAgentRecommendations).values({ id: uuid(), companyId: params.companyId, projectId: params.projectId, issue: params.issue, recommendedAction: params.recommendedAction, activityId: params.activityId||null, evidence: params.evidence||null, riskLevel: params.riskLevel||'medium', owner: params.owner||null }).returning().get();
  },
};
