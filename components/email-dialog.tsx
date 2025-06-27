"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { supabase, type Database } from "@/lib/supabase"
import { Sparkles } from "lucide-react"

type Contact = Database["public"]["Tables"]["contacts"]["Row"]
type EmailTemplate = Database["public"]["Tables"]["email_templates"]["Row"]

interface EmailDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onSuccess: () => void
  contactId?: string
}

export function EmailDialog({ open, onOpenChange, onSuccess, contactId }: EmailDialogProps) {
  const [formData, setFormData] = useState({
    contact_id: contactId || "",
    to_email: "",
    subject: "",
    body: "",
    template_id: "",
  })
  const [contacts, setContacts] = useState<Contact[]>([])
  const [templates, setTemplates] = useState<EmailTemplate[]>([])
  const [loading, setLoading] = useState(false)
  const [aiGenerating, setAiGenerating] = useState(false)

  useEffect(() => {
    if (open) {
      fetchData()
    }
  }, [open])

  useEffect(() => {
    if (contactId) {
      setFormData((prev) => ({ ...prev, contact_id: contactId }))
      // Récupérer l'email du contact
      fetchContactEmail(contactId)
    }
  }, [contactId])

  async function fetchData() {
    try {
      const [contactsRes, templatesRes] = await Promise.all([
        supabase.from("contacts").select("*").order("first_name"),
        supabase.from("email_templates").select("*").order("name"),
      ])

      if (contactsRes.error) throw contactsRes.error
      if (templatesRes.error) throw templatesRes.error

      setContacts(contactsRes.data || [])
      setTemplates(templatesRes.data || [])
    } catch (error) {
      console.error("Error fetching data:", error)
    }
  }

  async function fetchContactEmail(contactId: string) {
    try {
      const { data, error } = await supabase
        .from("contacts")
        .select("email, first_name, last_name")
        .eq("id", contactId)
        .single()

      if (error) throw error
      if (data?.email) {
        setFormData((prev) => ({ ...prev, to_email: data.email }))
      }
    } catch (error) {
      console.error("Error fetching contact email:", error)
    }
  }

  async function handleTemplateChange(templateId: string) {
    if (!templateId) return

    try {
      const { data, error } = await supabase.from("email_templates").select("*").eq("id", templateId).single()

      if (error) throw error
      if (data) {
        setFormData((prev) => ({
          ...prev,
          template_id: templateId,
          subject: data.subject || "",
          body: data.body || "",
        }))
      }
    } catch (error) {
      console.error("Error fetching template:", error)
    }
  }

  async function generateWithAI() {
    if (!formData.contact_id) {
      alert("Veuillez sélectionner un contact d'abord")
      return
    }

    setAiGenerating(true)
    try {
      // Simulation d'un appel IA - remplacer par votre service IA
      const contact = contacts.find((c) => c.id === formData.contact_id)
      if (contact) {
        const aiSubject = `Suivi personnalisé pour ${contact.first_name} ${contact.last_name}`
        const aiBody = `Bonjour ${contact.first_name},

J'espère que vous allez bien. Je me permets de vous recontacter concernant votre projet d'assurance.

Après notre dernière conversation, j'ai préparé une proposition personnalisée qui pourrait vous intéresser. Cette solution prend en compte vos besoins spécifiques et votre situation actuelle.

Seriez-vous disponible pour un appel cette semaine afin que nous puissions en discuter plus en détail ?

Je reste à votre disposition pour toute question.

Cordialement,
L'équipe CRM Pro`

        setFormData((prev) => ({
          ...prev,
          subject: aiSubject,
          body: aiBody,
        }))
      }
    } catch (error) {
      console.error("Error generating AI content:", error)
    } finally {
      setAiGenerating(false)
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const emailData = {
        contact_id: formData.contact_id || null,
        to_email: formData.to_email,
        from_email: "contactpremunia@gmail.com", // À récupérer depuis les paramètres utilisateur
        subject: formData.subject,
        body: formData.body,
        email_type: "outbound",
        status: "sent",
        sent_at: new Date().toISOString(),
        collaborator_id: "00000000-0000-0000-0000-000000000001", // À récupérer depuis l'auth
      }

      const { error } = await supabase.from("emails").insert([emailData])

      if (error) throw error

      // Créer une notification
      if (formData.contact_id) {
        await supabase.from("notifications").insert([
          {
            collaborator_id: "00000000-0000-0000-0000-000000000001",
            title: "Email envoyé",
            message: `Email envoyé à ${formData.to_email}`,
            type: "email_sent",
          },
        ])
      }

      onSuccess()
    } catch (error) {
      console.error("Error sending email:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[700px] max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>Nouvel Email</DialogTitle>
          <DialogDescription>Composez et envoyez un email à vos contacts.</DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="contact_id">Contact (optionnel)</Label>
                <Select
                  value={formData.contact_id}
                  onValueChange={(value) => {
                    setFormData({ ...formData, contact_id: value })
                    if (value) fetchContactEmail(value)
                  }}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionner un contact" />
                  </SelectTrigger>
                  <SelectContent>
                    {contacts.map((contact) => (
                      <SelectItem key={contact.id} value={contact.id}>
                        {contact.first_name} {contact.last_name} ({contact.client_code})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="template_id">Template (optionnel)</Label>
                <Select value={formData.template_id} onValueChange={handleTemplateChange}>
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionner un template" />
                  </SelectTrigger>
                  <SelectContent>
                    {templates.map((template) => (
                      <SelectItem key={template.id} value={template.id}>
                        {template.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="to_email">Destinataire</Label>
              <Input
                id="to_email"
                type="email"
                value={formData.to_email}
                onChange={(e) => setFormData({ ...formData, to_email: e.target.value })}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="subject">Objet</Label>
              <div className="flex gap-2">
                <Input
                  id="subject"
                  value={formData.subject}
                  onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
                  required
                  className="flex-1"
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={generateWithAI}
                  disabled={aiGenerating || !formData.contact_id}
                >
                  <Sparkles className="h-4 w-4 mr-2" />
                  {aiGenerating ? "Génération..." : "IA"}
                </Button>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="body">Message</Label>
              <Textarea
                id="body"
                value={formData.body}
                onChange={(e) => setFormData({ ...formData, body: e.target.value })}
                required
                rows={10}
                className="resize-none"
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading} className="bg-purple-600 hover:bg-purple-700">
              {loading ? "Envoi..." : "Envoyer"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
