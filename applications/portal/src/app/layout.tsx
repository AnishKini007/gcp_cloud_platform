import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'GCP Platform Portal',
  description: 'Unified dashboard for GCP Cloud Infrastructure Platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
