interface Props { message: string }

export default function WidgetError({ message }: Props) {
  return (
    <div className="h-full flex items-center justify-center">
      <p className="text-ember text-sm">{message}</p>
    </div>
  )
}
