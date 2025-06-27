"use client"

import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Plus, CheckCircle, Clock } from "lucide-react"
import { DashboardStats } from "@/components/dashboard-stats-new"

export function DashboardContent() {
  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex justify-between items-start mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
          <p className="text-gray-600">Vue d'ensemble de votre activité</p>
        </div>
        <Button className="bg-purple-600 hover:bg-purple-700">
          <Plus className="w-4 h-4 mr-2" />
          Nouveau Contact
        </Button>
      </div>

      {/* Stats Cards */}
      <DashboardStats />

      {/* Bottom Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mt-8">
        {/* Mes Tâches du Jour */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold text-gray-900">Mes Tâches du Jour</h2>
            <Badge variant="secondary" className="bg-purple-100 text-purple-700">
              0
            </Badge>
          </div>
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <CheckCircle className="w-8 h-8 text-green-600" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune tâche pour aujourd'hui</h3>
            <p className="text-gray-600">Vous êtes à jour !</p>
          </div>
        </Card>

        {/* Activité Récente */}
        <Card className="p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold text-gray-900">Activité Récente</h2>
          </div>
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Clock className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune activité récente</h3>
          </div>
        </Card>
      </div>

      {/* Create Logo */}
      <div className="flex justify-center mt-12">
        <div className="bg-gray-800 text-white px-6 py-3 rounded-lg flex items-center gap-2">
          <div className="w-6 h-6 bg-white/20 rounded flex items-center justify-center">
            <div className="w-3 h-3 bg-white rounded-sm transform rotate-45"></div>
          </div>
          <span className="font-medium">create</span>
        </div>
      </div>
    </div>
  )
}
