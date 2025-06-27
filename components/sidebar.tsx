"use client"

import Link from "next/link"
import { usePathname } from "next/navigation"
import { useAuth } from "./auth-provider"
import { cn } from "@/lib/utils"
import { Badge } from "@/components/ui/badge"
import {
  Home,
  Users,
  UserCheck,
  Package,
  FileText,
  MessageSquare,
  BarChart3,
  Target,
  CheckSquare,
  Mail,
  Share2,
  Upload,
  Bell,
  FileIcon as FileTemplate,
  Settings,
  Building2,
  Shield,
} from "lucide-react"

const navigationItems = [
  {
    title: "Tableau de bord",
    href: "/",
    icon: Home,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité", "Gestionnaire"],
  },
  {
    title: "Contacts",
    href: "/contacts",
    icon: Users,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité"],
  },
  {
    title: "Collaborateurs",
    href: "/collaborators",
    icon: UserCheck,
    roles: ["Directeur", "Commercial Senior"],
  },
  {
    title: "Produits",
    href: "/products",
    icon: Package,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Gestionnaire"],
  },
  {
    title: "Contrats",
    href: "/contracts",
    icon: FileText,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Gestionnaire"],
  },
  {
    title: "Interactions",
    href: "/interactions",
    icon: MessageSquare,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité"],
  },
  {
    title: "Rapports",
    href: "/reports",
    icon: BarChart3,
    roles: ["Directeur", "Commercial Senior", "Service Qualité"],
  },
  {
    title: "Objectifs",
    href: "/sales-targets",
    icon: Target,
    roles: ["Directeur", "Commercial Senior", "Commercial"],
  },
  {
    title: "Tâches",
    href: "/tasks",
    icon: CheckSquare,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité", "Gestionnaire"],
  },
  {
    title: "Emails",
    href: "/emails",
    icon: Mail,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité"],
  },
  {
    title: "Templates",
    href: "/templates",
    icon: FileTemplate,
    roles: ["Directeur", "Commercial Senior", "Commercial"],
  },
  {
    title: "Partage",
    href: "/sharing",
    icon: Share2,
    roles: ["Directeur", "Commercial Senior", "Commercial"],
  },
  {
    title: "Import",
    href: "/import",
    icon: Upload,
    roles: ["Directeur", "Commercial Senior", "Gestionnaire"],
  },
  {
    title: "Notifications",
    href: "/notifications",
    icon: Bell,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité", "Gestionnaire"],
  },
  {
    title: "Paramètres",
    href: "/settings",
    icon: Settings,
    roles: ["Directeur", "Commercial Senior", "Commercial", "Service Qualité", "Gestionnaire"],
  },
]

export function Sidebar() {
  const pathname = usePathname()
  const { user } = useAuth()

  if (!user || pathname === "/login") return null

  const userRole = user.role || ""
  const filteredItems = navigationItems.filter((item) => item.roles.includes(userRole))

  return (
    <div className="w-64 bg-white shadow-lg border-r flex flex-col">
      {/* Header */}
      <div className="p-6 border-b">
        <div className="flex items-center gap-3">
          <div className="bg-blue-600 p-2 rounded-lg">
            <Building2 className="h-6 w-6 text-white" />
          </div>
          <div>
            <h2 className="font-bold text-lg">CRM Pro</h2>
            <p className="text-xs text-gray-600">Assurances</p>
          </div>
        </div>
      </div>

      {/* User Info */}
      <div className="p-4 border-b bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
            <span className="text-blue-600 font-semibold text-sm">
              {user.first_name?.[0]}
              {user.last_name?.[0]}
            </span>
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium truncate">
              {user.first_name} {user.last_name}
            </p>
            <div className="flex items-center gap-1 mt-1">
              {user.role === "Directeur" && <Shield className="h-3 w-3 text-amber-600" />}
              <Badge variant="secondary" className="text-xs">
                {user.role}
              </Badge>
            </div>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {filteredItems.map((item) => {
          const isActive = pathname === item.href
          const Icon = item.icon

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors",
                isActive
                  ? "bg-blue-100 text-blue-700 border border-blue-200"
                  : "text-gray-700 hover:bg-gray-100 hover:text-gray-900",
              )}
            >
              <Icon className={cn("h-4 w-4", isActive ? "text-blue-600" : "text-gray-500")} />
              <span className="truncate">{item.title}</span>
              {isActive && <div className="ml-auto w-2 h-2 bg-blue-600 rounded-full" />}
            </Link>
          )
        })}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t bg-gray-50">
        <div className="text-xs text-gray-500 text-center">
          <p>CRM Pro v2.1.0</p>
          <p>© 2024 Assurances</p>
        </div>
      </div>
    </div>
  )
}
