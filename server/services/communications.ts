import { v4 as uuid } from 'uuid'; import { db } from '../db/client';
import { platformMessages, notificationChannels, notificationTemplates, notificationLogs, commsAgentRecommendations } from '../db/schema';
import { eq } from 'drizzle-orm';

export const messageService = {
  send(params: { companyId: string; senderId: string; body: string; projectId?: string; subject?: string; priority?: string; recipients?: string; parentMessageId?: string }) {
    return db.insert(platformMessages).values({ id: uuid(), companyId: params.companyId, senderId: params.senderId, body: params.body, projectId: params.projectId||null, subject: params.subject||null, priority: params.priority||'normal', recipients: params.recipients||null, parentMessageId: params.parentMessageId||null }).returning().get();
  },
  markRead(msgId: string) { return db.update(platformMessages).set({ isRead: 1, readAt: new Date().toISOString() }).where(eq(platformMessages.id, msgId)).returning().get(); },
};

export const notificationChannelService = {
  createChannel(params: { companyId: string; channelType: string; channelLabel: string; config?: string }) {
    return db.insert(notificationChannels).values({ id: uuid(), companyId: params.companyId, channelType: params.channelType, channelLabel: params.channelLabel, config: params.config||null }).returning().get();
  },
};

export const notificationTemplateService = {
  createTemplate(params: { companyId: string; templateCode: string; templateName: string; channelType: string; bodyTemplate: string; subjectTemplate?: string; variables?: string }) {
    return db.insert(notificationTemplates).values({ id: uuid(), companyId: params.companyId, templateCode: params.templateCode, templateName: params.templateName, channelType: params.channelType, bodyTemplate: params.bodyTemplate, subjectTemplate: params.subjectTemplate||null, variables: params.variables||null }).returning().get();
  },
};

export const notificationLogService = {
  log(params: { companyId: string; channelType: string; recipient: string; body: string; templateId?: string; subject?: string; status?: string; errorMessage?: string }) {
    return db.insert(notificationLogs).values({ id: uuid(), companyId: params.companyId, channelType: params.channelType, recipient: params.recipient, body: params.body, templateId: params.templateId||null, subject: params.subject||null, status: params.status||'sent', errorMessage: params.errorMessage||null }).returning().get();
  },
};

export const commsAgentService = {
  recommend(params: { companyId: string; issue: string; recommendedAction: string; projectId?: string; evidence?: string; riskLevel?: string; owner?: string }) {
    return db.insert(commsAgentRecommendations).values({ id: uuid(), companyId: params.companyId, issue: params.issue, recommendedAction: params.recommendedAction, projectId: params.projectId||null, evidence: params.evidence||null, riskLevel: params.riskLevel||'low', owner: params.owner||null }).returning().get();
  },
};
