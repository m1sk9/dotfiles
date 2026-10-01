import type { SessionRateLimit } from 'claude-code'

export type UsageWindow = 'five_hour' | 'seven_day' | 'fable_weekly'

export type Reading = {
  window: UsageWindow
  percent: number
  resetsAt?: string
}

export type Notified = {
  cycle?: number
  level: number
}

export const THRESHOLDS = [80, 95] as const

const LABELS: Record<UsageWindow, string> = {
  five_hour: '5 時間枠',
  seven_day: '週次枠',
  fable_weekly: 'Fable の週次枠',
}

export const levelOf = (percent: number): number =>
  THRESHOLDS.filter(threshold => percent >= threshold).at(-1) ?? 0

// Why not resetsAt の文字列を比べる: usage API は同じ周期でも呼ぶたびに
// "00:59:59.987154" のように端数の違う時刻を返すので，分単位に丸めて周期を見分ける
export const cycleOf = (reading: Reading): number | undefined =>
  reading.resetsAt === undefined ? undefined : Math.round(Date.parse(reading.resetsAt) / 60_000)

export const shouldNotify = (reading: Reading, previous: Notified | undefined): boolean => {
  const level = levelOf(reading.percent)
  if (level === 0) return false
  if (!previous || previous.cycle !== cycleOf(reading)) return true
  return level > previous.level
}

const remaining = (resetsAt: string, now: number): string => {
  const minutes = Math.max(0, Math.round((Date.parse(resetsAt) - now) / 60_000))
  const days = Math.floor(minutes / 1440)
  const hours = Math.floor(minutes / 60) % 24
  if (days > 0) return `${days}日${hours}時間`
  if (hours > 0) return `${hours}時間${minutes % 60}分`
  return `${minutes}分`
}

export const message = (reading: Reading, now: number): string => {
  const reset = reading.resetsAt ? `（リセットまで ${remaining(reading.resetsAt, now)}）` : ''
  return `⚠ ${LABELS[reading.window]}を ${Math.floor(reading.percent)}% 使用しています${reset}`
}

export const fromRateLimit = (limit: SessionRateLimit): Reading[] =>
  limit.kind === 'five_hour' || limit.kind === 'seven_day'
    ? [{ window: limit.kind, percent: limit.percentUsed, resetsAt: limit.resetsAt }]
    : []

type UsageLimit = {
  kind?: string
  percent?: number
  resets_at?: string
  scope?: { model?: { display_name?: string } } | null
}

// usage API (api.anthropic.com/api/oauth/usage) の limits[] から Fable の週次枠を拾う．
// Why not $.session.usage() の rateLimits を使う: そちらには five_hour / seven_day しか来ない（2026-10-02 実測）
export const fableFromUsage = (body: unknown): Reading | undefined => {
  const limits = (body as { limits?: UsageLimit[] } | null)?.limits
  const fable = limits?.find(
    limit => limit.kind === 'weekly_scoped' && limit.scope?.model?.display_name === 'Fable',
  )
  if (!fable || typeof fable.percent !== 'number') return undefined
  return { window: 'fable_weekly', percent: fable.percent, resetsAt: fable.resets_at }
}
