"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, Users } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { CollaboratorDialog } from "@/components/collaborator-dialog"
import { Sidebar } from "@/components/sidebar"

type Collaborator = Database["public"]["Tables"]["collaborators"]["Row"]

export default function CollaboratorsPage() {
  const [collaborators, setCollaborators] = useState<Collaborator[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingCollaborator, setEditingCollaborator] = useState<Collaborator | null>(null)

  useEffect(() => {
    fetchCollaborators()
  }, [])

  async function fetchCollaborators() {
    try {
      const { data, error } = await supabase.from("collaborators").select("*").order("created_at", { ascending: false })

      if (error) throw error
      setCollaborators(data || [])
    } catch (error) {
      console.error("Error fetching collaborators:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteCollaborator(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce collaborateur ?")) return

    try {
      const { error } = await supabase.from("collaborators").delete().eq("id", id)

      if (error) throw error
      await fetchCollaborators()
    } catch (error) {
      console.error("Error deleting collaborator:", error)
    }
  }

  const filteredCollaborators = collaborators.filter((collaborator) =>
    `${collaborator.first_name} ${collaborator.last_name} ${collaborator.email}`
      .toLowerCase()
      .includes(searchTerm.toLowerCase()),
  )

  const getRoleBadgeColor = (role: string) => {
    switch (role) {
      case "admin":
        return "bg-red-100 text-red-800"
      case "manager":
        return "bg-blue-100 text-blue-800"
      case "commercial":
        return "bg-green-100 text-green-800"
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Collaborateurs</h1>
              <p className="text-gray-600">Gérez votre équipe et leurs performances</p>
            </div>
            <Button onClick={() => setDialogOpen(true)} className="bg-purple-600 hover:bg-purple-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouveau Collaborateur
            </Button>
          </div>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher un collaborateur..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="h-48 bg-gray-200 rounded animate-pulse"></div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredCollaborators.map((collaborator) => (
                <Card key={collaborator.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg">
                          {collaborator.first_name} {collaborator.last_name}
                        </CardTitle>
                        <CardDescription>{collaborator.email}</CardDescription>
                      </div>
                      <Badge className={getRoleBadgeColor(collaborator.role)}>{collaborator.role}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Commission:</span>
                        <span className="font-medium">{(collaborator.commission_rate * 100).toFixed(2)}%</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Embauché le:</span>
                        <span className="font-medium">
                          {new Date(collaborator.hire_date).toLocaleDateString("fr-FR")}
                        </span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Statut:</span>
                        <Badge variant={collaborator.is_active ? "default" : "secondary"}>
                          {collaborator.is_active ? "Actif" : "Inactif"}
                        </Badge>
                      </div>
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setEditingCollaborator(collaborator)
                          setDialogOpen(true)
                        }}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteCollaborator(collaborator.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredCollaborators.length === 0 && !loading && (
            <div className="text-center py-12">
              <Users className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun collaborateur trouvé</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par ajouter un collaborateur."}
              </p>
            </div>
          )}

          <CollaboratorDialog
            open={dialogOpen}
            onOpenChange={(open) => {
              setDialogOpen(open)
              if (!open) setEditingCollaborator(null)
            }}
            collaborator={editingCollaborator}
            onSuccess={() => {
              fetchCollaborators()
              setDialogOpen(false)
              setEditingCollaborator(null)
            }}
          />
        </div>
      </main>
    </div>
  )
}
