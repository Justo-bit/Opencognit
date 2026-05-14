import { Router } from 'express';
import { authMiddleware } from '../middleware/auth.js';
import { adapterRegistry } from '../adapters/registry.js';

const router = Router();

function workerAuthMiddleware(req: any, res: any, next: any) {
  const id = req.headers['x-worker-id'] as string;
  const token = req.headers['x-worker-token'] as string;
  if (!id || !token) return res.status(401).json({ error: 'missing worker credentials' });
  import('../services/worker-pool.js').then(({ authenticateWorker }) => {
    if (!authenticateWorker(id, token)) return res.status(401).json({ error: 'invalid worker credentials' });
    req.workerId = id;
    next();
  }).catch(e => res.status(500).json({ error: e.message }));
}

router.get('/api/adapters', (_req, res) => {
  res.json({
    registered: adapterRegistry.getRegisteredAdapters(),
    plugins: adapterRegistry.getLoadedPlugins(),
  });
});

router.get('/api/workers', authMiddleware, async (_req, res) => {
  try {
    const { listWorkers } = await import('../services/worker-pool.js');
    res.json({ workers: listWorkers() });
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

router.post('/api/workers/register', authMiddleware, async (req, res) => {
  try {
    const { name, hostname, capabilities, maxConcurrency, id } = req.body;
    if (!name || !Array.isArray(capabilities)) {
      return res.status(400).json({ error: 'name and capabilities[] required' });
    }
    const { registerWorker } = await import('../services/worker-pool.js');
    const w = registerWorker({ name, hostname, capabilities, maxConcurrency, id });
    res.json(w);
  } catch (e: any) { res.status(400).json({ error: e.message }); }
});

router.post('/api/workers/:id/disable', authMiddleware, async (req, res) => {
  try {
    const { disableWorker } = await import('../services/worker-pool.js');
    disableWorker(req.params.id as string);
    res.json({ ok: true });
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

router.post('/api/worker/heartbeat', workerAuthMiddleware, async (req: any, res) => {
  try {
    const { heartbeat } = await import('../services/worker-pool.js');
    res.json(heartbeat(req.workerId));
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

router.post('/api/worker/claim', workerAuthMiddleware, async (req: any, res) => {
  try {
    const { claimWork } = await import('../services/worker-pool.js');
    const capability = (req.body?.capability as string) || null;
    const claim = claimWork(req.workerId, capability);
    if (!claim) return res.json({ claim: null });
    res.json({ claim });
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

router.post('/api/worker/submit', workerAuthMiddleware, async (req: any, res) => {
  try {
    const { wakeupId, success, error } = req.body;
    if (!wakeupId) return res.status(400).json({ error: 'wakeupId required' });
    const { submitResult } = await import('../services/worker-pool.js');
    res.json(submitResult(req.workerId, wakeupId, !!success, error));
  } catch (e: any) { res.status(500).json({ error: e.message }); }
});

export default router;
