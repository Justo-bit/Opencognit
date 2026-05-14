import type express from 'express';

const RATE_LIMIT_READ = parseInt(process.env.API_RATE_LIMIT_READ || '120', 10);
const RATE_LIMIT_WRITE = parseInt(process.env.API_RATE_LIMIT_WRITE || '30', 10);
const RATE_LIMIT_WINDOW_MS = parseInt(process.env.API_RATE_LIMIT_WINDOW_MS || '60000', 10);

interface RateLimitEntry {
  readCount: number;
  writeCount: number;
  resetAt: number;
}

const apiRateLimits = new Map<string, RateLimitEntry>();

export function apiRateLimit(req: express.Request, res: express.Response, next: express.NextFunction) {
  // Skip rate limiting for webhooks (they have their own auth)
  if (req.path.startsWith('/webhooks')) return next();

  // Skip rate limiting for localhost/development
  const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim()
    || req.socket.remoteAddress || 'unknown';
  if (ip === '127.0.0.1' || ip === '::1' || ip === '::ffff:127.0.0.1') return next();
  const isWrite = ['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method);
  const now_ms = Date.now();

  let entry = apiRateLimits.get(ip);
  if (!entry || now_ms > entry.resetAt) {
    entry = { readCount: 0, writeCount: 0, resetAt: now_ms + RATE_LIMIT_WINDOW_MS };
    apiRateLimits.set(ip, entry);
  }

  const limit = isWrite ? RATE_LIMIT_WRITE : RATE_LIMIT_READ;
  const current = isWrite ? entry.writeCount : entry.readCount;

  if (current >= limit) {
    const retryAfter = Math.ceil((entry.resetAt - now_ms) / 1000);
    res.setHeader('Retry-After', String(retryAfter));
    return res.status(429).json({
      error: 'Rate limit exceeded. Please wait.',
      limit,
      windowMs: RATE_LIMIT_WINDOW_MS,
      retryAfter,
    });
  }

  if (isWrite) entry.writeCount++;
  else entry.readCount++;

  // Expose rate limit headers
  res.setHeader('X-RateLimit-Limit', String(limit));
  res.setHeader('X-RateLimit-Remaining', String(Math.max(0, limit - (isWrite ? entry.writeCount : entry.readCount))));
  res.setHeader('X-RateLimit-Reset', String(Math.ceil(entry.resetAt / 1000)));

  next();
}

// Prune both rate limit maps periodically
setInterval(() => {
  const now_ms = Date.now();
  for (const [ip, entry] of apiRateLimits.entries()) {
    if (now_ms > entry.resetAt) apiRateLimits.delete(ip);
  }
}, 60000);

const authRateLimits = new Map<string, { count: number; resetAt: number }>();

export function authRateLimit(maxPerWindow: number, windowMs: number) {
  return (req: express.Request, res: express.Response, next: express.NextFunction) => {
    const ip = (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.socket.remoteAddress || 'unknown';
    const entry = authRateLimits.get(ip);
    const now_ms = Date.now();
    if (!entry || now_ms > entry.resetAt) {
      authRateLimits.set(ip, { count: 1, resetAt: now_ms + windowMs });
      return next();
    }
    if (entry.count >= maxPerWindow) {
      return res.status(429).json({ error: 'Too many attempts. Please wait.' });
    }
    entry.count++;
    return next();
  };
}

// Prune rate limit map periodically to avoid unbounded growth
setInterval(() => {
  const now_ms = Date.now();
  for (const [ip, entry] of authRateLimits.entries()) {
    if (now_ms > entry.resetAt) authRateLimits.delete(ip);
  }
}, 60000);
