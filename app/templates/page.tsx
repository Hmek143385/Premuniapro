"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, Mail, Copy, Eye } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { Sidebar } from "@/components/sidebar"

type EmailTemplate = Database["public"]["Tables"]["email_templates"]["Row"]

export default function TemplatesPage() {
  const [templates, setTemplates] = useState<EmailTemplate[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")

  useEffect(() => {
    fetchTemplates()
  }, [])

  async function fetchTemplates() {
    try {
      const { data, error } = await supabase
        .from("email_templates")
        .select("*")
        .order("created_at", { ascending: false })

      if (error) throw error
      setTemplates(data || [])
    } catch (error) {
      console.error("Error fetching templates:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteTemplate(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce template ?")) return

    try {
      const { error } = await supabase.from("email_templates").delete().eq("id", id)

      if (error) throw error
      await fetchTemplates()
    } catch (error) {
      console.error("Error deleting template:", error)
    }
  }

  const filteredTemplates = templates.filter((template) =>
    `${template.name} ${template.template_type} ${template.subject}`.toLowerCase().includes(searchTerm.toLowerCase()),
  )

  const getTypeBadgeColor = (type: string) => {
    switch (type) {
      case "welcome":
        return "bg-green-100 text-green-800"
      case "follow_up":
        return "bg-blue-100 text-blue-800"
      case "fb_senior_followup_1":
      case "fb_senior_followup_2":
      case "fb_senior_followup_3":
        return "bg-purple-100 text-purple-800"
      case "proposal":
        return "bg-orange-100 text-orange-800"
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Templates Email</h1>
              <p className="text-gray-600">Gérez vos modèles d'emails et workflows</p>
            </div>
            <Button className="bg-purple-600 hover:bg-purple-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouveau Template
            </Button>
          </div>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher un template..."
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
              {filteredTemplates.map((template) => (
                <Card key={template.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg">{template.name}</CardTitle>
                        <CardDescription className="mt-1">{template.subject}</CardDescription>
                      </div>
                      <Badge className={getTypeBadgeColor(template.template_type || "default")}>
                        {template.template_type}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="text-sm text-gray-600 line-clamp-3">{template.body.substring(0, 150)}...</div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Utilisations:</span>
                        <span className="font-medium">{template.usage_count}</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Variables:</span>
                        <span className="font-medium">
                          {Array.isArray(template.variables) ? template.variables.length : 0}
                        </span>
                      </div>
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button variant="outline" size="sm">
                        <Eye className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm">
                        <Copy className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm">
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteTemplate(template.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredTemplates.length === 0 && !loading && (
            <div className="text-center py-12">
              <Mail className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun template trouvé</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par créer un template."}
              </p>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
