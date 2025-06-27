"use client"

import { useEffect, useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, UserCheck, FileText, TrendingUp } from "lucide-react"
import { supabase } from "@/lib/supabase"

interface Stats {
  collaborators: number
  contacts: number
  contracts: number
  totalCommissions: number
}

export function DashboardStats() {
  const [stats, setStats] = useState<Stats>({
    collaborators: 0,
    contacts: 0,
    contracts: 0,
    totalCommissions: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchStats() {
      try {
        const [
          { count: collaboratorsCount },
          { count: contactsCount },
          { count: contractsCount },
          { data: commissionsData },
        ] = await Promise.all([
          supabase.from("collaborators").select("*", { count: "exact", head: true }),
          supabase.from("contacts").select("*", { count: "exact", head: true }),
          supabase.from("contracts").select("*", { count: "exact", head: true }),
          supabase.from("contracts").select("received_commission"),
        ])

        const totalCommissions =
          commissionsData?.reduce((sum, contract) => sum + (contract.received_commission || 0), 0) || 0

        setStats({
          collaborators: collaboratorsCount || 0,
          contacts: contactsCount || 0,
          contracts: contractsCount || 0,
          totalCommissions,
        })
      } catch (error) {
        console.error("Error fetching stats:", error)
      } finally {
        setLoading(false)
      }
    }

    fetchStats()
  }, [])

  if (loading) {
    return (
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {[...Array(4)].map((_, i) => (
          <Card key={i} className="animate-pulse">
            <CardHeader className="pb-2">
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            </CardHeader>
            <CardContent>
              <div className="h-8 bg-gray-200 rounded w-1/2"></div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Collaborateurs</CardTitle>
          <Users className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.collaborators}</div>
          <p className="text-xs text-muted-foreground">Équipe active</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Contacts</CardTitle>
          <UserCheck className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.contacts}</div>
          <p className="text-xs text-muted-foreground">Clients et prospects</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Contrats</CardTitle>
          <FileText className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{stats.contracts}</div>
          <p className="text-xs text-muted-foreground">Contrats signés</p>
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Commissions</CardTitle>
          <TrendingUp className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {new Intl.NumberFormat("fr-FR", {
              style: "currency",
              currency: "EUR",
            }).format(stats.totalCommissions)}
          </div>
          <p className="text-xs text-muted-foreground">Total reçu</p>
        </CardContent>
      </Card>
    </div>
  )
}
