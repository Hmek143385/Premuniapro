"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Plus, Search, Send, Eye, Clock, CheckCircle, XCircle, Mail } from "lucide-react"
import { Sidebar } from "@/components/sidebar"
import { EmailDialog } from "@/components/email-dialog"
import { supabase } from "@/lib/supabase"

interface Email {
  id: string
  subject: string
  body: string
  from_email: string
  to_email: string
  email_type: string
  status: string
  sent_at: string | null
  delivered_at: string | null
  opened_at: string | null
  clicked_at: string | null
  created_at: string
  contacts: {
    id: string
    first_name: string
    last_name: string
  } | null
  collaborators: {
    id: string
    first_name: string
    last_name: string
  } | null
}

export default function EmailsPage() {
  const [emails, setEmails] = useState<Email[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [statusFilter, setStatusFilter] = useState("all")
  const [typeFilter, setTypeFilter] = useState("all")
  const [isDialogOpen, setIsDialogOpen] = useState(false)

  useEffect(() => {
    fetchEmails()
  }, [])

  async function fetchEmails() {
    try {
      setLoading(true)
      const { data, error } = await supabase
        .from("emails")
        .select(`
          *,
          contacts:contact_id (
            id,
            first_name,
            last_name
          ),
          collaborators:collaborator_id (
            id,
            first_name,
            last_name
          )
        `)
        .order("created_at", { ascending: false })

      if (error) {
        console.error("Error fetching emails:", error)
        return
      }

      setEmails(data || [])
    } catch (error) {
      console.error("Error:", error)
    } finally {
      setLoading(false)
    }
  }

  const filteredEmails = emails.filter((email) => {
    const matchesSearch =
      email.subject.toLowerCase().includes(searchTerm.toLowerCase()) ||
      email.to_email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      (email.contacts?.first_name + " " + email.contacts?.last_name).toLowerCase().includes(searchTerm.toLowerCase())

    const matchesStatus = statusFilter === "all" || email.status === statusFilter
    const matchesType = typeFilter === "all" || email.email_type === typeFilter

    return matchesSearch && matchesStatus && matchesType
  })

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "sent":
        return <Send className="h-4 w-4 text-blue-500" />
      case "delivered":
        return <CheckCircle className="h-4 w-4 text-green-500" />
      case "opened":
        return <Eye className="h-4 w-4 text-purple-500" />
      case "clicked":
        return <CheckCircle className="h-4 w-4 text-green-600" />
      case "bounced":
        return <XCircle className="h-4 w-4 text-red-500" />
      case "draft":
        return <Clock className="h-4 w-4 text-gray-500" />
      default:
        return <Mail className="h-4 w-4 text-gray-400" />
    }
  }

  const getStatusBadge = (status: string) => {
    const variants: Record<string, "default" | "secondary" | "destructive" | "outline"> = {
      sent: "default",
      delivered: "secondary",
      opened: "outline",
      clicked: "secondary",
      bounced: "destructive",
      draft: "outline",
    }

    return (
      <Badge variant={variants[status] || "default"} className="flex items-center gap-1">
        {getStatusIcon(status)}
        {status.charAt(0).toUpperCase() + status.slice(1)}
      </Badge>
    )
  }

  const formatDate = (dateString: string | null) => {
    if (!dateString) return "N/A"
    return new Date(dateString).toLocaleDateString("fr-FR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const getEmailStats = () => {
    const total = emails.length
    const sent = emails.filter((e) => e.status === "sent").length
    const delivered = emails.filter((e) => e.status === "delivered").length
    const opened = emails.filter((e) => e.status === "opened").length
    const clicked = emails.filter((e) => e.status === "clicked").length

    return { total, sent, delivered, opened, clicked }
  }

  const stats = getEmailStats()

  if (loading) {
    return (
      <div className="flex h-screen bg-gray-50">
        <Sidebar />
        <main className="flex-1 overflow-auto">
          <div className="p-8">
            <div className="animate-pulse">
              <div className="h-8 bg-gray-200 rounded w-1/4 mb-4"></div>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                {[...Array(4)].map((_, i) => (
                  <div key={i} className="h-24 bg-gray-200 rounded"></div>
                ))}
              </div>
              <div className="space-y-4">
                {[...Array(5)].map((_, i) => (
                  <div key={i} className="h-20 bg-gray-200 rounded"></div>
                ))}
              </div>
            </div>
          </div>
        </main>
      </div>
    )
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <div className="p-8">
          <div className="flex justify-between items-start mb-8">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Gestion des Emails</h1>
              <p className="text-gray-600">Suivez et gérez tous vos emails clients</p>
            </div>
            <Button onClick={() => setIsDialogOpen(true)} className="bg-blue-600 hover:bg-blue-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouvel Email
            </Button>
          </div>

          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-5 gap-6 mb-8">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total Emails</CardTitle>
                <Mail className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.total}</div>
                <p className="text-xs text-muted-foreground">Tous les emails</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Envoyés</CardTitle>
                <Send className="h-4 w-4 text-blue-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.sent}</div>
                <p className="text-xs text-muted-foreground">Emails envoyés</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Livrés</CardTitle>
                <CheckCircle className="h-4 w-4 text-green-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.delivered}</div>
                <p className="text-xs text-muted-foreground">Emails livrés</p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Ouverts</CardTitle>
                <Eye className="h-4 w-4 text-purple-500" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.opened}</div>
                <p className="text-xs text-muted-foreground">
                  Taux: {stats.total > 0 ? Math.round((stats.opened / stats.total) * 100) : 0}%
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Cliqués</CardTitle>
                <CheckCircle className="h-4 w-4 text-green-600" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.clicked}</div>
                <p className="text-xs text-muted-foreground">
                  Taux: {stats.total > 0 ? Math.round((stats.clicked / stats.total) * 100) : 0}%
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Filters */}
          <div className="flex flex-col sm:flex-row gap-4 mb-6">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher par sujet, destinataire ou contact..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-full sm:w-[180px]">
                <SelectValue placeholder="Statut" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Tous les statuts</SelectItem>
                <SelectItem value="draft">Brouillon</SelectItem>
                <SelectItem value="sent">Envoyé</SelectItem>
                <SelectItem value="delivered">Livré</SelectItem>
                <SelectItem value="opened">Ouvert</SelectItem>
                <SelectItem value="clicked">Cliqué</SelectItem>
                <SelectItem value="bounced">Rejeté</SelectItem>
              </SelectContent>
            </Select>
            <Select value={typeFilter} onValueChange={setTypeFilter}>
              <SelectTrigger className="w-full sm:w-[180px]">
                <SelectValue placeholder="Type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">Tous les types</SelectItem>
                <SelectItem value="outbound">Sortant</SelectItem>
                <SelectItem value="inbound">Entrant</SelectItem>
                <SelectItem value="automated">Automatique</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Emails List */}
          <div className="space-y-4">
            {filteredEmails.length === 0 ? (
              <Card>
                <CardContent className="flex flex-col items-center justify-center py-12">
                  <Mail className="h-12 w-12 text-gray-400 mb-4" />
                  <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun email trouvé</h3>
                  <p className="text-gray-600 text-center mb-4">
                    {searchTerm || statusFilter !== "all" || typeFilter !== "all"
                      ? "Aucun email ne correspond à vos critères de recherche."
                      : "Commencez par envoyer votre premier email."}
                  </p>
                  <Button onClick={() => setIsDialogOpen(true)}>
                    <Plus className="h-4 w-4 mr-2" />
                    Créer un email
                  </Button>
                </CardContent>
              </Card>
            ) : (
              filteredEmails.map((email) => (
                <Card key={email.id} className="hover:shadow-md transition-shadow">
                  <CardContent className="p-6">
                    <div className="flex items-start justify-between">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-3 mb-2">
                          <h3 className="text-lg font-medium text-gray-900 truncate">{email.subject}</h3>
                          {getStatusBadge(email.status)}
                          <Badge variant="outline" className="text-xs">
                            {email.email_type}
                          </Badge>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-gray-600">
                          <div>
                            <p>
                              <strong>À:</strong> {email.to_email}
                            </p>
                            {email.contacts && (
                              <p>
                                <strong>Contact:</strong> {email.contacts.first_name} {email.contacts.last_name}
                              </p>
                            )}
                          </div>
                          <div>
                            <p>
                              <strong>De:</strong> {email.from_email}
                            </p>
                            {email.collaborators && (
                              <p>
                                <strong>Expéditeur:</strong> {email.collaborators.first_name}{" "}
                                {email.collaborators.last_name}
                              </p>
                            )}
                          </div>
                        </div>

                        <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4 text-xs text-gray-500">
                          <div>
                            <p>
                              <strong>Créé:</strong>
                            </p>
                            <p>{formatDate(email.created_at)}</p>
                          </div>
                          {email.sent_at && (
                            <div>
                              <p>
                                <strong>Envoyé:</strong>
                              </p>
                              <p>{formatDate(email.sent_at)}</p>
                            </div>
                          )}
                          {email.delivered_at && (
                            <div>
                              <p>
                                <strong>Livré:</strong>
                              </p>
                              <p>{formatDate(email.delivered_at)}</p>
                            </div>
                          )}
                          {email.opened_at && (
                            <div>
                              <p>
                                <strong>Ouvert:</strong>
                              </p>
                              <p>{formatDate(email.opened_at)}</p>
                            </div>
                          )}
                        </div>

                        {email.body && (
                          <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                            <p className="text-sm text-gray-700 line-clamp-3">
                              {email.body.substring(0, 200)}
                              {email.body.length > 200 && "..."}
                            </p>
                          </div>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))
            )}
          </div>
        </div>
      </main>

      <EmailDialog isOpen={isDialogOpen} onClose={() => setIsDialogOpen(false)} onEmailCreated={fetchEmails} />
    </div>
  )
}
