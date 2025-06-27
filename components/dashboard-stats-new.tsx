"use client"

import { useEffect, useState } from "react"
import { Card, CardContent } from "@/components/ui/card"
import { Users, UserPlus, Handshake, Percent, TrendingUp, TrendingDown } from "lucide-react"
import { supabase } from "@/lib/supabase"

interface Stats {
  totalContacts: number
  newLeads: number
  clientsGagnes: number
  tauxConversion: number
}

export function DashboardStats() {
  const [stats, setStats] = useState<Stats>({
    totalContacts: 0,
    newLeads: 0,
    clientsGagnes: 0,
    tauxConversion: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchStats() {
      try {
        const [{ count: totalContacts }, { count: newLeads }, { count: clientsGagnes }] = await Promise.all([
          supabase.from("contacts").select("*", { count: "exact", head: true }),
          supabase.from("contacts").select("*", { count: "exact", head: true }).eq("status", "lead"),
          supabase.from("contacts").select("*", { count: "exact", head: true }).eq("status", "client"),
        ])

        const tauxConversion =
          totalContacts && totalContacts > 0 ? Math.round(((clientsGagnes || 0) / totalContacts) * 100) : 0

        setStats({
          totalContacts: totalContacts || 0,
          newLeads: newLeads || 0,
          clientsGagnes: clientsGagnes || 0,
          tauxConversion,
        })
      } catch (error) {
        console.error("Error fetching stats:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

  const statsData = [
    {
      title: "Total Contacts",
      value: stats.totalContacts,
      change: "+12% ce mois",
      changeType: "positive" as const,
      icon: Users,
      bgColor: "bg-blue-500",
      iconBg: "bg-blue-100",
    },
    {
      title: "Nouveaux Leads",
      value: stats.newLeads,
      change: "+8% ce mois",
      changeType: "positive" as const,
      icon: UserPlus,
      bgColor: "bg-green-500",
      iconBg: "bg-green-100",
    },
    {
      title: "Clients Gagnés",
      value: stats.clientsGagnes,
      change: "+15% ce mois",
      changeType: "positive" as const,
      icon: Handshake,
      bgColor: "bg-orange-500",
      iconBg: "bg-orange-100",
    },
    {
      title: "Taux Conversion",
      value: `${stats.tauxConversion}%`,
      change: "-2% ce mois",
      changeType: "negative" as const,
      icon: Percent,
      bgColor: "bg-purple-500",
      iconBg: "bg-purple-100",
    },
  ]

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {[...Array(4)].map((_, i) => (
          <Card key={i} className="animate-pulse">
            <CardContent className="p-6">
              <div className="h-16 bg-gray-200 rounded mb-4"></div>
              <div className="h-8 bg-gray-200 rounded mb-2"></div>
              <div className="h-4 bg-gray-200 rounded w-2/3"></div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      {statsData.map((stat, index) => (
        <Card key={index} className="overflow-hidden">
          <CardContent className="p-6">
            <div className="flex items-center justify-between mb-4">
              <div className={`w-12 h-12 ${stat.iconBg} rounded-lg flex items-center justify-center`}>
                <stat.icon className={`w-6 h-6 text-${stat.bgColor.split("-")[1]}-600`} />
              </div>
            </div>
            <div className="space-y-2">
              <p className="text-sm font-medium text-gray-600">{stat.title}</p>
              <p className="text-3xl font-bold text-gray-900">{stat.value}</p>
              <div className="flex items-center gap-1">
                {stat.changeType === "positive" ? (
                  <TrendingUp className="w-4 h-4 text-green-600" />
                ) : (
                  <TrendingDown className="w-4 h-4 text-red-600" />
                )}
                <span
                  className={`text-sm font-medium ${
                    stat.changeType === "positive" ? "text-green-600" : "text-red-600"
                  }`}
                >
                  {stat.change}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  )
}
