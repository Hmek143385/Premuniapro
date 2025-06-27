"use client"

import { useAuth } from "@/components/auth-provider"
import { DashboardContent } from "@/components/dashboard-content"
import { AuthGuard } from "@/components/auth-guard"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Users, FileText, TrendingUp, Target, Calendar, Bell, Shield, Award } from "lucide-react"

export default function HomePage() {
  const { user } = useAuth()

  const getWelcomeMessage = () => {
    const hour = new Date().getHours()
    if (hour < 12) return "Bonjour"
    if (hour < 18) return "Bon après-midi"
    return "Bonsoir"
  }

  const getRoleSpecificStats = () => {
    switch (user?.role) {
      case "Directeur":
        return [
          { title: "Équipe totale", value: "12", icon: Users, color: "text-blue-600" },
          { title: "CA mensuel", value: "€125,430", icon: TrendingUp, color: "text-green-600" },
          { title: "Objectifs atteints", value: "8/10", icon: Target, color: "text-orange-600" },
          { title: "Nouveaux contrats", value: "23", icon: FileText, color: "text-purple-600" },
        ]
      case "Commercial Senior":
        return [
          { title: "Mon équipe", value: "4", icon: Users, color: "text-blue-600" },
          { title: "CA personnel", value: "€45,200", icon: TrendingUp, color: "text-green-600" },
          { title: "Objectif mensuel", value: "85%", icon: Target, color: "text-orange-600" },
          { title: "Mes contrats", value: "12", icon: FileText, color: "text-purple-600" },
        ]
      case "Commercial":
        return [
          { title: "Mes contacts", value: "156", icon: Users, color: "text-blue-600" },
          { title: "CA personnel", value: "€28,900", icon: TrendingUp, color: "text-green-600" },
          { title: "Objectif mensuel", value: "72%", icon: Target, color: "text-orange-600" },
          { title: "Mes contrats", value: "8", icon: FileText, color: "text-purple-600" },
        ]
      case "Service Qualité":
        return [
          { title: "Contrôles effectués", value: "45", icon: Shield, color: "text-blue-600" },
          { title: "Taux de conformité", value: "94%", icon: Award, color: "text-green-600" },
          { title: "Alertes traitées", value: "12", icon: Bell, color: "text-orange-600" },
          { title: "Rapports générés", value: "6", icon: FileText, color: "text-purple-600" },
        ]
      case "Gestionnaire":
        return [
          { title: "Contrats gérés", value: "89", icon: FileText, color: "text-blue-600" },
          { title: "Taux de traitement", value: "96%", icon: TrendingUp, color: "text-green-600" },
          { title: "En attente", value: "7", icon: Calendar, color: "text-orange-600" },
          { title: "Validés ce mois", value: "34", icon: Award, color: "text-purple-600" },
        ]
      default:
        return []
    }
  }

  const stats = getRoleSpecificStats()

  return (
    <AuthGuard>
      <div className="p-6 space-y-6">
        {/* Welcome Section */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-lg p-6 text-white">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold">
                {getWelcomeMessage()}, {user?.first_name} !
              </h1>
              <p className="text-blue-100 mt-1">Voici un aperçu de votre activité en tant que {user?.role}</p>
            </div>
            <div className="text-right">
              <div className="flex items-center gap-2 mb-2">
                {user?.role === "Directeur" && <Shield className="h-5 w-5" />}
                <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                  {user?.role}
                </Badge>
              </div>
              <p className="text-sm text-blue-100">
                {new Date().toLocaleDateString("fr-FR", {
                  weekday: "long",
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                })}
              </p>
            </div>
          </div>
        </div>

        {/* Role-specific Stats */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, index) => {
            const Icon = stat.icon
            return (
              <Card key={index}>
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium text-gray-600">{stat.title}</CardTitle>
                  <Icon className={`h-4 w-4 ${stat.color}`} />
                </CardHeader>
                <CardContent>
                  <div className={`text-2xl font-bold ${stat.color}`}>{stat.value}</div>
                </CardContent>
              </Card>
            )
          })}
        </div>

        {/* Role-specific Quick Actions */}
        <Card>
          <CardHeader>
            <CardTitle>Actions rapides</CardTitle>
            <CardDescription>Accès rapide aux fonctionnalités principales pour votre rôle</CardDescription>
          </CardHeader>
          <CardContent>
            <DashboardContent />
          </CardContent>
        </Card>

        {/* Recent Activity */}
        <Card>
          <CardHeader>
            <CardTitle>Activité récente</CardTitle>
            <CardDescription>Vos dernières actions dans le système</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Nouveau contact ajouté</p>
                  <p className="text-xs text-gray-600">Marie Dubois - il y a 2 heures</p>
                </div>
              </div>
              <div className="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Contrat signé</p>
                  <p className="text-xs text-gray-600">Assurance Auto - Pierre Martin - il y a 4 heures</p>
                </div>
              </div>
              <div className="flex items-center gap-4 p-3 bg-gray-50 rounded-lg">
                <div className="w-2 h-2 bg-orange-500 rounded-full"></div>
                <div className="flex-1">
                  <p className="text-sm font-medium">Rappel programmé</p>
                  <p className="text-xs text-gray-600">Appel client Sophie Leroy - demain 14h</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </AuthGuard>
  )
}
