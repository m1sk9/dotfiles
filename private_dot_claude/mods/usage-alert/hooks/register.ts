import type { EngineInterface, Register } from 'claude-code'
import {
  type Notified,
  type Reading,
  cycleOf,
  fableFromUsage,
  fromRateLimit,
  levelOf,
  message,
  shouldNotify,
} from './alerts'

const USAGE_URL = 'https://api.anthropic.com/api/oauth/usage'
const FABLE_POLL_MS = 10 * 60 * 1000

// Why not セッション内の変数で通知済みを覚える: 複数のセッションを並べていると
// 同じ閾値の toast がセッションの数だけ出るので，セッションをまたぐ $.store に置く
const alert = async ($: EngineInterface, readings: Reading[]) => {
  const now = await $.clock.now()
  for (const reading of readings) {
    const key = `notified.${reading.window}`
    const previous = (await $.store.get(key)) as Notified | undefined
    if (!shouldNotify(reading, previous)) continue
    $.ui.toast(message(reading, now), { timeoutMs: 10_000 })
    await $.store.set(key, { cycle: cycleOf(reading), level: levelOf(reading.percent) })
  }
}

const pollFable = async ($: EngineInterface) => {
  const auth = await $.session.authorize()
  if (!auth) return
  const res = await $.http.fetch(USAGE_URL, {
    auth: auth.handle,
    headers: { 'anthropic-beta': 'oauth-2025-04-20' },
  })
  if (!res.ok) return
  const body: unknown = JSON.parse(res.text)

  // fish の `claude --plan` が起動前に Fable の枠を警告するために読む（__claude_warn_fable_usage）
  const home = await $.env.get('HOME')
  if (home) {
    const fetched = Math.floor((await $.clock.now()) / 1000)
    await $.fs.write(`${home}/.claude/.usage-cache`, `${fetched} ${JSON.stringify(body)}\n`)
  }

  const fable = fableFromUsage(body)
  if (fable) await alert($, [fable])
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const result = await next(e)
    void pollFable($)
    $.clock.every(FABLE_POLL_MS, () => pollFable($))
    return result
  })

  on('session.measure', async ($, e, next) => {
    if (e.changed.includes('rateLimits')) await alert($, e.rateLimits.flatMap(fromRateLimit))
    return next(e)
  })
}
