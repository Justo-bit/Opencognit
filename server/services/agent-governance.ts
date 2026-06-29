import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { aiAgents, aiAgentVersions, aiAgentRecommendations, aiAgentEvidenceLinks, aiAgentReviews } from '../db/schema';
import { eq, and } from 'drizzle-orm';

export const agentRegistryService = {
  register(params: { companyId: string; agentCode: string; agentName: string; controlRoom: string; description?: string; capabilities?: string; riskCategory?: string; requiresHumanApproval?: boolean }) {
    return db.insert(aiAgents).values({ id: uuid(), companyId: params.companyId, agentCode: params.agentCode, agentName: params.agentName, controlRoom: params.controlRoom, description: params.description||null, capabilities: params.capabilities||null, riskCategory: params.riskCategory||'medium', requiresHumanApproval: params.requiresHumanApproval===false?0:1 }).returning().get();
  },
  deployVersion(params: { agentId: string; version: string; changelog?: string; configSnapshot?: string; deployedBy?: string }) {
    return db.insert(aiAgentVersions).values({ id: uuid(), agentId: params.agentId, version: params.version, changelog: params.changelog||null, configSnapshot: params.configSnapshot||null, deployedBy: params.deployedBy||null, deployedAt: new Date().toISOString() }).returning().get();
  },
};

export const agentRecommendationService = {
  create(params: { companyId: string; agentId: string; subjectType: string; subjectId: string; recommendation: string; projectId?: string; agentVersionId?: string; evidenceSummary?: string; confidence?: number; riskLevel?: string; requiresHumanApproval?: boolean }) {
    return db.insert(aiAgentRecommendations).values({ id: uuid(), companyId: params.companyId, agentId: params.agentId, subjectType: params.subjectType, subjectId: params.subjectId, recommendation: params.recommendation, projectId: params.projectId||null, agentVersionId: params.agentVersionId||null, evidenceSummary: params.evidenceSummary||null, confidence: params.confidence??null, riskLevel: params.riskLevel||'medium', requiresHumanApproval: params.requiresHumanApproval===false?0:1 }).returning().get();
  },
  addEvidence(params: { recommendationId: string; evidenceType: string; evidenceRef: string; evidenceSummary?: string }) {
    return db.insert(aiAgentEvidenceLinks).values({ id: uuid(), recommendationId: params.recommendationId, evidenceType: params.evidenceType, evidenceRef: params.evidenceRef, evidenceSummary: params.evidenceSummary||null }).returning().get();
  },
  review(params: { recommendationId: string; reviewedBy: string; reviewerRole: string; decision: string; decisionReason?: string }) {
    return db.insert(aiAgentReviews).values({ id: uuid(), recommendationId: params.recommendationId, reviewedBy: params.reviewedBy, reviewerRole: params.reviewerRole, decision: params.decision, decisionReason: params.decisionReason||null }).returning().get();
  },
};
