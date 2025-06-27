"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, UserCheck, Phone, Mail } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { ContactDialog } from "@/components/contact-dialog"
import { Sidebar } from "@/components/sidebar"

type Contact = Database["public"]["Tables"]["contacts"]["Row"] & {
  collaborators?: {
    first_name: string
    last_name: string
  }
}

export default function ContactsPage() {
  const [contacts, setContacts] = useState<Contact[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingContact, setEditingContact] = useState<Contact | null>(null)

  useEffect(() => {
    fetchContacts()
  }, [])

  async function fetchContacts() {
    try {
      const { data, error } = await supabase
        .from("contacts")
        .select(`
          *,
          collaborators:assigned_to (
            first_name,
            last_name
          )
        `)
        .order("created_at", { ascending: false })

      if (error) throw error
      setContacts(data || [])
    } catch (error) {
      console.error("Error fetching contacts:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteContact(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce contact ?")) return

    try {
      const { error } = await supabase.from("contacts").delete().eq("id", id)

      if (error) throw error
      await fetchContacts()
    } catch (error) {
      console.error("Error deleting contact:", error)
    }
  }

  const filteredContacts = contacts.filter((contact) =>
    `${contact.first_name} ${contact.last_name} ${contact.email} ${contact.client_code}`
      .toLowerCase()
      .includes(searchTerm.toLowerCase()),
  )

  const getStatusBadgeColor = (status: string) => {
    switch (status) {
      case "client":
        return "bg-green-100 text-green-800"
      case "prospect":
        return "bg-blue-100 text-blue-800"
      case "lead":
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Prospects</h1>
              <p className="text-gray-600">Gérez vos clients et prospects</p>
            </div>
            <Button onClick={() => setDialogOpen(true)} className="bg-purple-600 hover:bg-purple-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouveau Contact
            </Button>
          </div>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher un contact..."
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
              {filteredContacts.map((contact) => (
                <Card key={contact.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg">
                          {contact.first_name} {contact.last_name}
                        </CardTitle>
                        <CardDescription className="font-mono text-sm">{contact.client_code}</CardDescription>
                      </div>
                      <Badge className={getStatusBadgeColor(contact.status)}>{contact.status}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {contact.email && (
                        <div className="flex items-center gap-2 text-sm">
                          <Mail className="h-4 w-4 text-gray-400" />
                          <span className="truncate">{contact.email}</span>
                        </div>
                      )}
                      {contact.phone && (
                        <div className="flex items-center gap-2 text-sm">
                          <Phone className="h-4 w-4 text-gray-400" />
                          <span>{contact.phone}</span>
                        </div>
                      )}
                      {contact.city && (
                        <div className="flex justify-between text-sm">
                          <span className="text-gray-600">Ville:</span>
                          <span className="font-medium">{contact.city}</span>
                        </div>
                      )}
                      {contact.profession && (
                        <div className="flex justify-between text-sm">
                          <span className="text-gray-600">Profession:</span>
                          <span className="font-medium truncate ml-2">{contact.profession}</span>
                        </div>
                      )}
                      {contact.collaborators && (
                        <div className="flex justify-between text-sm">
                          <span className="text-gray-600">Assigné à:</span>
                          <span className="font-medium">
                            {contact.collaborators.first_name} {contact.collaborators.last_name}
                          </span>
                        </div>
                      )}
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setEditingContact(contact)
                          setDialogOpen(true)
                        }}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteContact(contact.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredContacts.length === 0 && !loading && (
            <div className="text-center py-12">
              <UserCheck className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun contact trouvé</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par ajouter un contact."}
              </p>
            </div>
          )}

          <ContactDialog
            open={dialogOpen}
            onOpenChange={(open) => {
              setDialogOpen(open)
              if (!open) setEditingContact(null)
            }}
            contact={editingContact}
            onSuccess={() => {
              fetchContacts()
              setDialogOpen(false)
              setEditingContact(null)
            }}
          />
        </div>
      </main>
    </div>
  )
}
