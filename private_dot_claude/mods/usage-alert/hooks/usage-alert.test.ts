import { describe, expect, mock, test } from 'claude-code/testing'
import { fableFromUsage, levelOf, message, shouldNotify } from './alerts'

const NOW = Date.parse('2026-10-02T00:00:00Z')
const WEEKLY_RESET = '2026-10-05T01:00:00+00:00'

describe('thresholds', () => {
  test('nothing below 80%, then 80 and 95 as the two levels', () => {
    expect(levelOf(79.9)).toBe(0)
    expect(levelOf(80)).toBe(80)
    expect(levelOf(94)).toBe(80)
    expect(levelOf(95)).toBe(95)
  })

  test('a level is announced once per reset cycle, and again only when it rises', () => {
    const reading = { window: 'seven_day' as const, percent: 85, resetsAt: WEEKLY_RESET }
    expect(shouldNotify(reading, undefined)).toBe(true)
    const notified = { cycle: Math.round(Date.parse(WEEKLY_RESET) / 60_000), level: 80 }
    expect(shouldNotify(reading, notified)).toBe(false)
    expect(shouldNotify({ ...reading, percent: 96 }, notified)).toBe(true)
  })

  test('the same cycle is recognised despite sub-second jitter in resets_at', () => {
    const notified = { cycle: Math.round(Date.parse(WEEKLY_RESET) / 60_000), level: 80 }
    const jittered = { window: 'seven_day' as const, percent: 85, resetsAt: '2026-10-05T00:59:59.987154+00:00' }
    expect(shouldNotify(jittered, notified)).toBe(false)
  })

  test('a new reset cycle announces the level again', () => {
    const notified = { cycle: Math.round(Date.parse(WEEKLY_RESET) / 60_000), level: 95 }
    const next = { window: 'seven_day' as const, percent: 81, resetsAt: '2026-10-12T01:00:00+00:00' }
    expect(shouldNotify(next, notified)).toBe(true)
  })
})

describe('message', () => {
  test('names the window, the floored percentage and the time left', () => {
    expect(message({ window: 'fable_weekly', percent: 81.7, resetsAt: WEEKLY_RESET }, NOW)).toBe(
      '⚠ Fable の週次枠を 81% 使用しています（リセットまで 3日1時間）',
    )
    expect(
      message({ window: 'five_hour', percent: 96, resetsAt: '2026-10-02T01:20:00Z' }, NOW),
    ).toBe('⚠ 5 時間枠を 96% 使用しています（リセットまで 1時間20分）')
  })
})

describe('fableFromUsage', () => {
  test('picks the Fable weekly_scoped entry out of limits[]', () => {
    const body = {
      limits: [
        { kind: 'weekly_all', percent: 22, resets_at: WEEKLY_RESET, scope: null },
        { kind: 'weekly_scoped', percent: 40, resets_at: WEEKLY_RESET, scope: { model: { display_name: 'Opus' } } },
        { kind: 'weekly_scoped', percent: 12, resets_at: WEEKLY_RESET, scope: { model: { display_name: 'Fable' } } },
      ],
    }
    expect(fableFromUsage(body)).toEqual({ window: 'fable_weekly', percent: 12, resetsAt: WEEKLY_RESET })
  })

  test('is absent when the plan has no Fable limit', () => {
    expect(fableFromUsage({ limits: [] })).toBe(undefined)
    expect(fableFromUsage(null)).toBe(undefined)
  })
})

test('session.measure toasts each crossing once, across repeated measurements', async ($, on) => {
  mock.store(on)
  mock.clock(on, { now: NOW })
  const toasts: string[] = []
  on('ui.toast', (_$, e) => {
    toasts.push(e.text)
    return { value: undefined }
  })
  on('session.measure', (_$, e) => ({ changed: e.changed }))

  const measure = (percent: number) =>
    $.session.measure({
      context: { window: 200_000 },
      rateLimits: [{ kind: 'seven_day', percentUsed: percent, resetsAt: WEEKLY_RESET }],
      changed: ['rateLimits'],
    } as never)

  for (const percent of [79, 82, 85, 96, 97]) await measure(percent)

  expect(toasts).toEqual([
    '⚠ 週次枠を 82% 使用しています（リセットまで 3日1時間）',
    '⚠ 週次枠を 96% 使用しています（リセットまで 3日1時間）',
  ])
})

test('session.start fetches the usage API, caches it for fish and toasts the Fable limit', async ($, on) => {
  mock.store(on)
  const clock = mock.clock(on, { now: NOW })
  mock.env(on, { HOME: '/home/me' })
  const body = {
    limits: [{ kind: 'weekly_scoped', percent: 81, resets_at: WEEKLY_RESET, scope: { model: { display_name: 'Fable' } } }],
  }
  const writes: { path: string; text: string }[] = []
  const toasts: string[] = []
  on('session.authorize', () => ({ value: { handle: 'h', kind: 'bearer' as const } }))
  on('http.fetch', () => ({ value: { status: 200, ok: true, headers: {}, text: JSON.stringify(body) } }) as never)
  on('fs.write', (_$, e) => {
    writes.push(e)
    return { value: undefined }
  })
  on('ui.toast', (_$, e) => {
    toasts.push(e.text)
    return { value: undefined }
  })

  on('session.start', (_$, e) => e as never)

  await $.session.start({ cwd: '/tmp', surface: 'terminal', interactive: true } as never)
  // The fetch runs unawaited so that it never delays the session's start.
  await clock.settle()

  expect(writes).toEqual([{ path: '/home/me/.claude/.usage-cache', text: `${NOW / 1000} ${JSON.stringify(body)}\n` }])
  expect(toasts).toEqual(['⚠ Fable の週次枠を 81% 使用しています（リセットまで 3日1時間）'])
})
