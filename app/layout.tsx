import type React from "react"
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import "./globals.css"
import { AuthProvider } from "@/components/auth-provider"
import { AuthGuard } from "@/components/auth-guard"
import { Sidebar } from "@/components/sidebar"
import { UserMenu } from "@/components/user-menu"
import { Toaster } from "@/components/ui/toaster"

const inter = Inter({ subsets: ["latin"] })

export const metadata: Metadata = {
  title: "CRM Pro Assurances",
  description: "Système de gestion de la relation client pour assurances",
    generator: 'v0.dev'
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr">
      <body className={inter.className}>
        <AuthProvider>
          <AuthGuard>
            <div className="flex h-screen bg-gray-50">
              <Sidebar />
              <div className="flex-1 flex flex-col overflow-hidden">
                <header className="bg-white shadow-sm border-b px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <h1 className="text-2xl font-bold text-gray-900">CRM Pro Assurances</h1>
                      <p className="text-sm text-gray-600">Gestion de la relation client</p>
                    </div>
                    <UserMenu />
                  </div>
                </header>
                <main className="flex-1 overflow-auto">{children}</main>
              </div>
            </div>
          </AuthGuard>
          <Toaster />
        </AuthProvider>
      </body>
    </html>
  )
}
