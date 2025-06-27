"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, Calendar, Clock, User } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { InteractionDialog } from "@/components/interaction-dialog"
import { Sidebar } from "@/components/sidebar"

type Interaction = Database["public"]["Tables"]["interactions"]["Row"] & {
  contacts?: {
    first_name: string
    last_name: string
    client_code: string
  }
  collaborators?: {
    first_name: string
    last_name: string
  }
}

export default function InteractionsPage() {
  const [interactions, setInteractions] = useState<Interaction[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingInteraction, setEditingInteraction] = useState<Interaction | null>(null)

  useEffect(() => {
    fetchInteractions()
  }, [])

  async function fetchInteractions() {
    try {
      const { data, error } = await supabase
        .from("interactions")
        .select(`
          *,
          contacts:contact_id (
            first_name,
            last_name,
            client_code
          ),
          collaborators:collaborator_id (
            first_name,
            last_name
          )
        `)
        .order("id", { ascending: false })

      if (error) throw error
      setInteractions(data || [])
    } catch (error) {
      console.error("Error fetching interactions:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteInteraction(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer cette interaction ?")) return

    try {
      const { error } = await supabase.from("interactions").delete().eq("id", id)

      if (error) throw error
      await fetchInteractions()
    } catch (error) {
      console.error("Error deleting interaction:", error)
    }
  }

  const filteredInteractions = interactions.filter((interaction) =>
    `${interaction.type} ${interaction.outcome} ${interaction.contacts?.first_name} ${interaction.contacts?.last_name}`
      .toLowerCase()
      .includes(searchTerm.toLowerCase()),
  )

  const getTypeBadgeColor = (type: string) => {
    switch (type.toLowerCase()) {
      case "call":
        return "bg-blue-100 text-blue-800"
      case "email":
        return "bg-green-100 text-green-800"
      case "meeting":
        return "bg-purple-100 text-purple-800"
      case "sms":
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Interactions</h1>
              <p className="text-gray-600">Suivez vos interactions clients</p>
            </div>
            <Button onClick={() => setDialogOpen(true)} className="bg-purple-600 hover:bg-purple-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouvelle Interaction
            </Button>
          </div>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher une interaction..."
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
              {filteredInteractions.map((interaction) => (
                <Card key={interaction.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg flex items-center gap-2">
                          <Badge className={getTypeBadgeColor(interaction.type)}>{interaction.type}</Badge>
                        </CardTitle>
                        {interaction.contacts && (
                          <CardDescription>
                            {interaction.contacts.first_name} {interaction.contacts.last_name}
                            <span className="ml-2 text-xs">({interaction.contacts.client_code})</span>
                          </CardDescription>
                        )}
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {interaction.scheduled_at && (
                        <div className="flex items-center gap-2 text-sm">
                          <Calendar className="h-4 w-4 text-gray-400" />
                          <span>Programmé: {new Date(interaction.scheduled_at).toLocaleString("fr-FR")}</span>
                        </div>
                      )}
                      {interaction.completed_at && (
                        <div className="flex items-center gap-2 text-sm">
                          <Clock className="h-4 w-4 text-gray-400" />
                          <span>Terminé: {new Date(interaction.completed_at).toLocaleString("fr-FR")}</span>
                        </div>
                      )}
                      {interaction.duration_minutes > 0 && (
                        <div className="flex justify-between text-sm">
                          <span className="text-gray-600">Durée:</span>
                          <span className="font-medium">{interaction.duration_minutes} min</span>
                        </div>
                      )}
                      {interaction.notes && (
                        <div className="text-sm">
                          <span className="text-gray-600">Notes:</span>
                          <p className="mt-1 text-gray-900 line-clamp-3">{interaction.notes}</p>
                        </div>
                      )}
                      {interaction.collaborators && (
                        <div className="flex items-center gap-2 text-sm">
                          <User className="h-4 w-4 text-gray-400" />
                          <span>
                            {interaction.collaborators.first_name} {interaction.collaborators.last_name}
                          </span>
                        </div>
                      )}
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setEditingInteraction(interaction)
                          setDialogOpen(true)
                        }}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteInteraction(interaction.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredInteractions.length === 0 && !loading && (
            <div className="text-center py-12">
              <Calendar className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune interaction trouvée</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par ajouter une interaction."}
              </p>
            </div>
          )}

          <InteractionDialog
            open={dialogOpen}
            onOpenChange={(open) => {
              setDialogOpen(open)
              if (!open) setEditingInteraction(null)
            }}
            interaction={editingInteraction}
            onSuccess={() => {
              fetchInteractions()
              setDialogOpen(false)
              setEditingInteraction(null)
            }}
          />
        </div>
      </main>
    </div>
  )
}
