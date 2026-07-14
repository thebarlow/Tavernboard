import { useState } from 'react'
import { useEntries } from '@/hooks/useEntries'
import WidgetSkeleton from '@/components/WidgetSkeleton'
import WidgetError from '@/components/WidgetError'
import type { CalendarConfig } from './config'

const ALL_DAY_NAMES = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
const WEEKDAY_INDICES = [1, 2, 3, 4, 5]

function toDateStr(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

interface Props { config: CalendarConfig }

export default function CalendarWidget({ config }: Props) {
  const [focused, setFocused] = useState(() => new Date())
  const [selected, setSelected] = useState<string | null>(null)
  const { data: entries, isLoading, isError } = useEntries()

  if (isLoading) return <WidgetSkeleton />
  if (isError) return <WidgetError message="Could not load calendar" />

  const year = focused.getFullYear()
  const month = focused.getMonth()
  const firstDay = new Date(year, month, 1)
  const daysInMonth = new Date(year, month + 1, 0).getDate()
  const startOffset = firstDay.getDay()
  const todayStr = toDateStr(new Date())
  const monthLabel = firstDay.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })

  const dotMap = new Map<string, string[]>()
  for (const e of entries ?? []) {
    if (!e.date) continue
    const existing = dotMap.get(e.date) ?? []
    existing.push(e.color_override ?? '#C8A96E')
    dotMap.set(e.date, existing)
  }

  type Cell = { date: Date; str: string } | null
  const cells: Cell[] = []
  for (let i = 0; i < startOffset; i++) cells.push(null)
  for (let d = 1; d <= daysInMonth; d++) {
    const date = new Date(year, month, d)
    cells.push({ date, str: toDateStr(date) })
  }
  while (cells.length % 7 !== 0) cells.push(null)

  const dayNames = config.showWeekends
    ? ALL_DAY_NAMES
    : ALL_DAY_NAMES.filter((_, i) => WEEKDAY_INDICES.includes(i))

  const visibleCells = config.showWeekends
    ? cells
    : cells.filter((_, i) => WEEKDAY_INDICES.includes(i % 7))

  const cols = config.showWeekends ? 7 : 5
  // Tailwind needs static class names — use inline style for grid columns
  const gridStyle = { display: 'grid', gridTemplateColumns: `repeat(${cols}, minmax(0, 1fr))`, gap: '2px' }

  return (
    <div className="p-3 flex flex-col gap-2 h-full overflow-hidden">
      <div className="flex items-center justify-between shrink-0">
        <button
          onClick={() => setFocused(new Date(year, month - 1, 1))}
          onPointerDown={e => e.stopPropagation()}
          className="text-parchment hover:text-parchment-light text-lg px-1 leading-none"
        >
          ‹
        </button>
        <span className="font-display text-xs text-parchment">{monthLabel}</span>
        <button
          onClick={() => setFocused(new Date(year, month + 1, 1))}
          onPointerDown={e => e.stopPropagation()}
          className="text-parchment hover:text-parchment-light text-lg px-1 leading-none"
        >
          ›
        </button>
      </div>

      <div style={gridStyle} className="shrink-0">
        {dayNames.map(d => (
          <div key={d} className="text-center text-text-secondary text-xs py-1">{d}</div>
        ))}
      </div>

      <div style={gridStyle} className="flex-1 overflow-hidden">
        {visibleCells.map((cell, i) => {
          if (!cell) return <div key={`empty-${i}`} />
          const isToday = cell.str === todayStr
          const isSelected = cell.str === selected
          const dots = dotMap.get(cell.str) ?? []

          return (
            <button
              key={cell.str}
              onPointerDown={e => e.stopPropagation()}
              onClick={() => setSelected(cell.str === selected ? null : cell.str)}
              className={[
                'flex flex-col items-center pt-0.5 rounded text-xs transition-colors',
                isToday ? 'bg-ember text-parchment-light' : '',
                isSelected && !isToday ? 'bg-parchment/20 text-parchment' : '',
                !isToday && !isSelected ? 'text-text-primary hover:bg-white/5' : '',
              ].join(' ')}
            >
              <span>{cell.date.getDate()}</span>
              {dots.length > 0 && (
                <div className="flex gap-px mt-px flex-wrap justify-center">
                  {dots.slice(0, 3).map((color, di) => (
                    <div
                      key={di}
                      className="w-1 h-1 rounded-full"
                      style={{ backgroundColor: color }}
                    />
                  ))}
                </div>
              )}
            </button>
          )
        })}
      </div>
    </div>
  )
}
