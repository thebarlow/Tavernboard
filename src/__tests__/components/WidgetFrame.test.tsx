import { describe, it, expect, vi } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import WidgetFrame from '@/components/WidgetFrame'

describe('WidgetFrame', () => {
  it('fires onRemove when the remove button is clicked', () => {
    const onRemove = vi.fn()
    render(<WidgetFrame title="Tasks" onRemove={onRemove}>content</WidgetFrame>)
    fireEvent.click(screen.getByRole('button', { name: /remove widget/i }))
    expect(onRemove).toHaveBeenCalledOnce()
  })

  it('marks header buttons with widget-action so react-grid-layout ignores them for dragging', () => {
    render(
      <WidgetFrame title="Tasks" onRemove={() => {}} onSettings={() => {}}>content</WidgetFrame>
    )
    expect(screen.getByRole('button', { name: /remove widget/i })).toHaveClass('widget-action')
    expect(screen.getByRole('button', { name: /widget settings/i })).toHaveClass('widget-action')
  })
})
