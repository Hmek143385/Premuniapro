"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Search, Share2, Eye, Edit, Users, Clock } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { Sidebar } from "@/components/sidebar"
import { ShareContactDialog } from "@/components/share-contact-dialog"

type ContactShare = Database["public"]["Tables"]["contact_shares"]["Row"] & {
  contacts?: {
    first_name: string
    last_name: string
    client_code: string
    email: string
  }
  shared_by_user?: {
    first_name: string
    last_name: string
  }
  shared_with_user?: {
    first_name: string
    last_name: string
  }
}

export default function SharingPage() {
  const [shares, setShares] = useState<ContactShare[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [filter, setFilter] = useState<"all" | "shared_by_me" | "shared_with_me">("all")
  const [dialogOpen, setDialogOpen] = useState(false)

  useEffect(() => {
    fetchShares()
  }, [filter])

  async function fetchShares() {
    try {
      let query = supabase
        .from("contact_shares")
        .select(`
          *,
          contacts:contact_id (
            first_name,
            last_name,
            client_code,
            email
          ),
          shared_by_user:shared_by (
            first_name,
            last_name
          ),
          shared_with_user:shared_with (
            first_name,
            last_name
          )
        `)
        .eq("is_active", true)
        .order("created_at", { ascending: false })

      const currentUserId = "00000000-0000-0000-0000-000000000001" // À récupérer depuis l'auth

      if (filter === "shared_by_me") {
        query = query.eq("shared_by", currentUserId)
      } else if (filter === "shared_with_me") {
        query = query.eq("shared_with", currentUserId)
      }

      const { data, error } = await query

      if (error) throw error
      setShares(data || [])
    } catch (error) {
      console.error("Error fetching shares:", error)
    } finally {
      setLoading(false)
    }
  }

  async function revokeShare(shareId: string) {
    if (!confirm("Êtes-vous sûr de vouloir révoquer ce partage ?")) return

    try {
      const { error } = await supabase.from("contact_shares").update({ is_active: false }).eq("id", shareId)

      if (error) throw error
      await fetchShares()
    } catch (error) {
      console.error("Error revoking share:", error)
    }
  }

  const filteredShares = shares.filter((share) =>
    `${share.contacts?.first_name} ${share.contacts?.last_name} ${share.contacts?.client_code}`
      .toLowerCase()
      .includes(searchTerm.toLowerCase()),
  )

  const getPermissionBadgeColor = (permission: string) => {
    switch (permission) {
      case "read":
        return "bg-blue-100 text-blue-800"
      case "write":
        return "bg-green-100 text-green-800"
      case "full":
        return "bg-purple-100 text-purple-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const isExpired = (expiresAt: string | null) => {
    if (!expiresAt) return false
    return new Date(expiresAt) < new Date()
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <div className="p-8">
          <div className="flex justify-between items-start mb-8">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Partage de Contacts</h1>
              <p className="text-gray-600">Gérez le partage de vos contacts avec l'équipe</p>
            </div>
            <Button onClick={() => setDialogOpen(true)} className="bg-purple-600 hover:bg-purple-700">
              <Share2 className="h-4 w-4 mr-2" />
              Partager un Contact
            </Button>
          </div>

          {/* Filtres */}
          <div className="flex gap-4 mb-6">
            <div className="flex gap-2">
              <Button
                variant={filter === "all" ? "default" : "outline"}
                onClick={() => setFilter("all")}
                className={filter === "all" ? "bg-purple-600 hover:bg-purple-700" : ""}
              >
                Tous les partages
              </Button>
              <Button
                variant={filter === "shared_by_me" ? "default" : "outline"}
                onClick={() => setFilter("shared_by_me")}
                className={filter === "shared_by_me" ? "bg-purple-600 hover:bg-purple-700" : ""}
              >
                Partagés par moi
              </Button>
              <Button
                variant={filter === "shared_with_me" ? "default" : "outline"}
                onClick={() => setFilter("shared_with_me")}
                className={filter === "shared_with_me" ? "bg-purple-600 hover:bg-purple-700" : ""}
              >
                Partagés avec moi
              </Button>
            </div>
            <div className="flex-1 max-w-md">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Rechercher un contact partagé..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
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
              {filteredShares.map((share) => (
                <Card key={share.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg flex items-center gap-2">
                          <Users className="h-5 w-5 text-purple-600" />
                          {share.contacts?.first_name} {share.contacts?.last_name}
                        </CardTitle>
                        <CardDescription>{share.contacts?.client_code}</CardDescription>
                      </div>
                      <div className="flex flex-col gap-2">
                        <Badge className={getPermissionBadgeColor(share.permission_level)}>
                          {share.permission_level}
                        </Badge>
                        {isExpired(share.expires_at) && (
                          <Badge variant="destructive" className="text-xs">
                            Expiré
                          </Badge>
                        )}
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex items-center gap-2 text-sm">
                        <Avatar className="h-6 w-6">
                          <AvatarFallback className="text-xs">
                            {share.shared_by_user?.first_name?.[0]}
                            {share.shared_by_user?.last_name?.[0]}
                          </AvatarFallback>
                        </Avatar>
                        <span className="text-gray-600">Partagé par:</span>
                        <span className="font-medium">
                          {share.shared_by_user?.first_name} {share.shared_by_user?.last_name}
                        </span>
                      </div>
                      <div className="flex items-center gap-2 text-sm">
                        <Avatar className="h-6 w-6">
                          <AvatarFallback className="text-xs">
                            {share.shared_with_user?.first_name?.[0]}
                            {share.shared_with_user?.last_name?.[0]}
                          </AvatarFallback>
                        </Avatar>
                        <span className="text-gray-600">Partagé avec:</span>
                        <span className="font-medium">
                          {share.shared_with_user?.first_name} {share.shared_with_user?.last_name}
                        </span>
                      </div>
                      {share.message && (
                        <div className="text-sm text-gray-600 bg-gray-50 p-2 rounded">"{share.message}"</div>
                      )}
                      <div className="flex items-center gap-2 text-sm text-gray-500">
                        <Clock className="h-4 w-4" />
                        <span>{new Date(share.created_at).toLocaleDateString("fr-FR")}</span>
                        {share.expires_at && (
                          <span>• Expire le {new Date(share.expires_at).toLocaleDateString("fr-FR")}</span>
                        )}
                      </div>
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button variant="outline" size="sm" className="flex-1 bg-transparent">
                        <Eye className="h-4 w-4 mr-1" />
                        Voir
                      </Button>
                      {share.permission_level !== "read" && (
                        <Button variant="outline" size="sm" className="flex-1 bg-transparent">
                          <Edit className="h-4 w-4 mr-1" />
                          Modifier
                        </Button>
                      )}
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => revokeShare(share.id)}
                        className="text-red-600 hover:text-red-700"
                      >
                        Révoquer
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredShares.length === 0 && !loading && (
            <div className="text-center py-12">
              <Share2 className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun partage trouvé</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par partager un contact."}
              </p>
            </div>
          )}

          <ShareContactDialog
            open={dialogOpen}
            onOpenChange={setDialogOpen}
            onSuccess={() => {
              fetchShares()
              setDialogOpen(false)
            }}
          />
        </div>
      </main>
    </div>
  )
}
