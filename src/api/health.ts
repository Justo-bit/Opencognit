import { request } from './core';

export const apiHealth = {
  check: () => request<{ status: string; version: string; name: string }>('/health'),
};
