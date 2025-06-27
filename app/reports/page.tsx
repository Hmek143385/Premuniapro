"use client"

import { useEffect, useState } from "react"
import { useAuth } from "@/components/auth-provider"
import { supabase } from "@/lib/supabase"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { DateRangePicker } from "@/components/ui/date-range-picker"
import { BarChart3, TrendingUp, Users, FileText, Download, Calendar, Target, Award, AlertCircle } from "lucide-react"
import { AuthGuard } from "@/components/auth-guard"
import type { DateRange } from "react-day-picker"

interface ReportData {
  totalContacts: number
  totalContracts: number
  totalRevenue: number
  conversionRate: number
  topPerformer: string
  recentActivity: Array<{
    id: string
    type: string
    description: string
    date: string
    user: string
  }>
}

export default function ReportsPage() {
  const { user } = useAuth()
  const [reportData, setReportData] = useState<ReportData | null>(null)
  const [loading, setLoading] = useState(true)
  const [dateRange, setDateRange] = useState<DateRange | undefined>()

  useEffect(() => {
    fetchReportData()
  }, [user, dateRange])

  const fetchReportData = async () => {
    if (!user) return

    try {
      setLoading(true)

      // Récupérer les données selon le rôle
      const queries = []

      // Contacts
      if (user.role === "Directeur" || user.role === "Commercial Senior") {
        queries.push(supabase.from("contacts").select("*"))
      } else {
        queries.push(supabase.from("contacts").select("*").eq("assigned_to", user.id))
      }

      // Contrats
      queries.push(supabase.from("contracts").select("*"))

      // Collaborateurs pour les performances
      queries.push(supabase.from("collaborators").select("id, first_name, last_name, role"))

      const [contactsResult, contractsResult, collaboratorsResult] = await Promise.all(queries)

      const contacts = contactsResult.data || []
      const contracts = contractsResult.data || []
      const collaborators = collaboratorsResult.data || []

      // Calculer les métriques
      const totalRevenue = contracts.reduce((sum, contract) => sum + (contract.amount || 0), 0)
      const conversionRate = contacts.length > 0 ? (contracts.length / contacts.length) * 100 : 0

      // Trouver le meilleur performer (simulé)
      const topPerformer =
        collaborators.find((c) => c.role === "Commercial")?.first_name +
          " " +
          collaborators.find((c) => c.role === "Commercial")?.last_name || "N/A"

      // Activité récente (simulée)
      const recentActivity = [
        {
          id: "1",
          type: "contract",
          description: "Nouveau contrat signé - Assurance Auto",
          date: new Date().toISOString(),
          user: user.first_name + " " + user.last_name,
        },
        {
          id: "2",
          type: "contact",
          description: "Nouveau contact ajouté",
          date: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
          user: user.first_name + " " + user.last_name,
        },
      ]

      setReportData({
        totalContacts: contacts.length,
        totalContracts: contracts.length,
        totalRevenue,
        conversionRate,
        topPerformer,
        recentActivity,
      })
    } catch (error) {
      console.error("Erreur lors du chargement des rapports:", error)
    } finally {
      setLoading(false)
    }
  }

  const exportReport = async (format: "pdf" | "excel") => {
    // Simuler l'export
    const data = {
      user: user?.email,
      role: user?.role,
      date: new Date().toISOString(),
      data: reportData,
      format,
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `rapport-${format}-${new Date().toISOString().split("T")[0]}.json`
    a.click()
    URL.revokeObjectURL(url)
  }

  if (loading) {
    return (
      <AuthGuard>
        <div className="p-6">
          <div className="animate-pulse space-y-6">
            <div className="h-8 bg-gray-200 rounded w-1/4"></div>
            <div className="grid grid-cols-4 gap-6">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="h-32 bg-gray-200 rounded"></div>
              ))}
            </div>
          </div>
        </div>
      </AuthGuard>
    )
  }

  return (
    <AuthGuard>
      <div className="p-6 space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold flex items-center gap-3">
              <BarChart3 className="h-8 w-8 text-blue-600" />
              Rapports et Analyses
            </h1>
            <p className="text-gray-600 mt-1">Tableau de bord personnalisé pour {user?.role}</p>
          </div>
          <div className="flex items-center gap-4">
            <DateRangePicker date={dateRange} onDateChange={setDateRange} />
            <Button onClick={() => exportReport("pdf")} variant="outline">
              <Download className="h-4 w-4 mr-2" />
              Export PDF
            </Button>
            <Button onClick={() => exportReport("excel")}>
              <Download className="h-4 w-4 mr-2" />
              Export Excel
            </Button>
          </div>
        </div>

        {/* KPI Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Total Contacts</CardTitle>
              <Users className="h-4 w-4 text-blue-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-blue-600">{reportData?.totalContacts || 0}</div>
              <p className="text-xs text-gray-600 mt-1">+12% par rapport au mois dernier</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Contrats Signés</CardTitle>
              <FileText className="h-4 w-4 text-green-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-green-600">{reportData?.totalContracts || 0}</div>
              <p className="text-xs text-gray-600 mt-1">+8% par rapport au mois dernier</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Chiffre d'Affaires</CardTitle>
              <TrendingUp className="h-4 w-4 text-purple-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-purple-600">
                €{reportData?.totalRevenue?.toLocaleString() || 0}
              </div>
              <p className="text-xs text-gray-600 mt-1">+15% par rapport au mois dernier</p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Taux de Conversion</CardTitle>
              <Target className="h-4 w-4 text-orange-600" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-orange-600">{reportData?.conversionRate?.toFixed(1) || 0}%</div>
              <p className="text-xs text-gray-600 mt-1">+3% par rapport au mois dernier</p>
            </CardContent>
          </Card>
        </div>

        {/* Detailed Reports */}
        <Tabs defaultValue="performance" className="space-y-6">
          <TabsList>
            <TabsTrigger value="performance">Performance</TabsTrigger>
            <TabsTrigger value="activity">Activité</TabsTrigger>
            <TabsTrigger value="goals">Objectifs</TabsTrigger>
            {user?.role === "Directeur" && <TabsTrigger value="team">Équipe</TabsTrigger>}
          </TabsList>

          {/* Performance Tab */}
          <TabsContent value="performance">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Award className="h-5 w-5 text-yellow-600" />
                    Meilleur Performer
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="text-center p-6">
                    <div className="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
                      <Award className="h-8 w-8 text-yellow-600" />
                    </div>
                    <h3 className="text-xl font-bold">{reportData?.topPerformer}</h3>
                    <p className="text-gray-600">Commercial du mois</p>
                    <Badge variant="secondary" className="mt-2 bg-yellow-100 text-yellow-800">
                      +25% objectifs
                    </Badge>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Évolution Mensuelle</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Contacts</span>
                      <div className="flex items-center gap-2">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div className="bg-blue-600 h-2 rounded-full" style={{ width: "75%" }}></div>
                        </div>
                        <span className="text-sm font-medium">75%</span>
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Contrats</span>
                      <div className="flex items-center gap-2">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div className="bg-green-600 h-2 rounded-full" style={{ width: "60%" }}></div>
                        </div>
                        <span className="text-sm font-medium">60%</span>
                      </div>
                    </div>
                    <div className="flex items-center justify-between">
                      <span className="text-sm">Chiffre d'affaires</span>
                      <div className="flex items-center gap-2">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div className="bg-purple-600 h-2 rounded-full" style={{ width: "85%" }}></div>
                        </div>
                        <span className="text-sm font-medium">85%</span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Activity Tab */}
          <TabsContent value="activity">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-blue-600" />
                  Activité Récente
                </CardTitle>
                <CardDescription>Vos dernières actions dans le système</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {reportData?.recentActivity.map((activity) => (
                    <div key={activity.id} className="flex items-center gap-4 p-4 bg-gray-50 rounded-lg">
                      <div
                        className={`w-3 h-3 rounded-full ${
                          activity.type === "contract"
                            ? "bg-green-500"
                            : activity.type === "contact"
                              ? "bg-blue-500"
                              : "bg-orange-500"
                        }`}
                      ></div>
                      <div className="flex-1">
                        <p className="font-medium">{activity.description}</p>
                        <p className="text-sm text-gray-600">
                          Par {activity.user} • {new Date(activity.date).toLocaleDateString("fr-FR")}
                        </p>
                      </div>
                      <Badge variant="outline">
                        {activity.type === "contract" ? "Contrat" : activity.type === "contact" ? "Contact" : "Autre"}
                      </Badge>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          {/* Goals Tab */}
          <TabsContent value="goals">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Target className="h-5 w-5 text-orange-600" />
                    Objectifs Personnels
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-sm">Contacts mensuels</span>
                      <span className="text-sm font-medium">45/50</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-blue-600 h-2 rounded-full" style={{ width: "90%" }}></div>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-sm">Contrats signés</span>
                      <span className="text-sm font-medium">12/15</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-green-600 h-2 rounded-full" style={{ width: "80%" }}></div>
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-sm">CA mensuel</span>
                      <span className="text-sm font-medium">€28,900/€35,000</span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div className="bg-purple-600 h-2 rounded-full" style={{ width: "82%" }}></div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Alertes et Recommandations</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-start gap-3 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                    <AlertCircle className="h-5 w-5 text-yellow-600 mt-0.5" />
                    <div>
                      <p className="text-sm font-medium text-yellow-800">Objectif en retard</p>
                      <p className="text-xs text-yellow-700">
                        Il vous reste 3 contrats à signer pour atteindre votre objectif mensuel
                      </p>
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <TrendingUp className="h-5 w-5 text-blue-600 mt-0.5" />
                    <div>
                      <p className="text-sm font-medium text-blue-800">Opportunité</p>
                      <p className="text-xs text-blue-700">5 contacts n'ont pas été contactés depuis plus de 7 jours</p>
                    </div>
                  </div>

                  <div className="flex items-start gap-3 p-3 bg-green-50 border border-green-200 rounded-lg">
                    <Award className="h-5 w-5 text-green-600 mt-0.5" />
                    <div>
                      <p className="text-sm font-medium text-green-800">Félicitations</p>
                      <p className="text-xs text-green-700">
                        Vous avez dépassé votre objectif de contacts ce mois-ci !
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Team Tab (Directeur only) */}
          {user?.role === "Directeur" && (
            <TabsContent value="team">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Users className="h-5 w-5 text-blue-600" />
                    Performance de l'Équipe
                  </CardTitle>
                  <CardDescription>Vue d'ensemble des performances de tous les collaborateurs</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-4">
                    <div className="grid grid-cols-4 gap-4 p-4 bg-gray-50 rounded-lg font-medium text-sm">
                      <div>Collaborateur</div>
                      <div>Contacts</div>
                      <div>Contrats</div>
                      <div>Performance</div>
                    </div>

                    {["Marie Martin", "Pierre Durand", "Sophie Leroy", "Thomas Moreau"].map((name, index) => (
                      <div key={name} className="grid grid-cols-4 gap-4 p-4 border rounded-lg">
                        <div className="flex items-center gap-2">
                          <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                            <span className="text-xs font-medium text-blue-600">
                              {name
                                .split(" ")
                                .map((n) => n[0])
                                .join("")}
                            </span>
                          </div>
                          <span className="font-medium">{name}</span>
                        </div>
                        <div>{45 - index * 5}</div>
                        <div>{12 - index * 2}</div>
                        <div>
                          <Badge variant={index === 0 ? "default" : index === 1 ? "secondary" : "outline"}>
                            {index === 0 ? "Excellent" : index === 1 ? "Bon" : "Moyen"}
                          </Badge>
                        </div>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          )}
        </Tabs>
      </div>
    </AuthGuard>
  )
}
