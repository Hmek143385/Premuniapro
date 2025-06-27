"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, Target, Calendar, TrendingUp } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { SalesTargetDialog } from "@/components/sales-target-dialog"
import { Sidebar } from "@/components/sidebar"

type SalesTarget = Database["public"]["Tables"]["sales_targets"]["Row"] & {
  collaborators?: {
    first_name: string
    last_name: string
  }
}

export default function SalesTargetsPage() {
  const [salesTargets, setSalesTargets] = useState<SalesTarget[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingTarget, setEditingTarget] = useState<SalesTarget | null>(null)

  useEffect(() => {
    fetchSalesTargets()
  }, [])

  async function fetchSalesTargets() {
    try {
      const { data, error } = await supabase
        .from("sales_targets")
        .select(`
          *,
          collaborators:collaborator_id (
            first_name,
            last_name
          )
        `)
        .order("created_at", { ascending: false })

      if (error) throw error
      setSalesTargets(data || [])
    } catch (error) {
      console.error("Error fetching sales targets:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteSalesTarget(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer cet objectif ?")) return

    try {
      const { error } = await supabase.from("sales_targets").delete().eq("id", id)

      if (error) throw error
      await fetchSalesTargets()
    } catch (error) {
      console.error("Error deleting sales target:", error)
    }
  }

  const filteredTargets = salesTargets.filter((target) =>
    `${target.target_type} ${target.collaborators?.first_name} ${target.collaborators?.last_name}`
      .toLowerCase()
      .includes(searchTerm.toLowerCase()),
  )

  const getTargetTypeBadgeColor = (type: string) => {
    switch (type.toLowerCase()) {
      case "revenue":
        return "bg-green-100 text-green-800"
      case "contracts":
        return "bg-blue-100 text-blue-800"
      case "leads":
        return "bg-yellow-100 text-yellow-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <div className="p-8">
          <div className="flex justify-between items-start mb-8">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Objectifs de Vente</h1>
              <p className="text-gray-600">Définissez et suivez les objectifs</p>
            </div>
            <Button onClick={() => setDialogOpen(true)} className="bg-purple-600 hover:bg-purple-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouvel Objectif
            </Button>
          </div>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher un objectif..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="h-64 bg-gray-200 rounded animate-pulse"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredTargets.map((target) => (
                <Card key={target.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg flex items-center gap-2">
                          <Target className="h-5 w-5 text-purple-600" />
                          {target.target_type}
                        </CardTitle>
                        {target.collaborators && (
                          <CardDescription>
                            {target.collaborators.first_name} {target.collaborators.last_name}
                          </CardDescription>
                        )}
                      </div>
                      <Badge className={getTargetTypeBadgeColor(target.target_type)}>{target.target_type}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex items-center gap-2">
                        <TrendingUp className="h-4 w-4 text-gray-400" />
                        <div className="text-sm">
                          <div className="font-semibold">
                            Objectif: {new Intl.NumberFormat("fr-FR").format(target.target_value)}
                          </div>
                          <div className="text-gray-600">
                            Minimum: {new Intl.NumberFormat("fr-FR").format(target.min_value)}
                          </div>
                        </div>
                      </div>
                      <div className="flex items-center gap-2 text-sm">
                        <Calendar className="h-4 w-4 text-gray-400" />
                        <span>
                          Du {new Date(target.start_date).toLocaleDateString("fr-FR")} au{" "}
                          {new Date(target.end_date).toLocaleDateString("fr-FR")}
                        </span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Poids:</span>
                        <span className="font-medium">{target.weight}%</span>
                      </div>
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setEditingTarget(target)
                          setDialogOpen(true)
                        }}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteSalesTarget(target.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredTargets.length === 0 && !loading && (
            <div className="text-center py-12">
              <Target className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun objectif trouvé</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par ajouter un objectif."}
              </p>
            </div>
          )}

          <SalesTargetDialog
            open={dialogOpen}
            onOpenChange={(open) => {
              setDialogOpen(open)
              if (!open) setEditingTarget(null)
            }}
            salesTarget={editingTarget}
            onSuccess={() => {
              fetchSalesTargets()
              setDialogOpen(false)
              setEditingTarget(null)
            }}
          />
        </div>
      </main>
    </div>
  )
}
