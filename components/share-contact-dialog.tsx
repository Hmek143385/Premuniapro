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

type Contact = Database["public"]["Tables"]["contacts"]["Row"]
type Collaborator = Database["public"]["Tables"]["collaborators"]["Row"]

interface ShareContactDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onSuccess: () => void
}

export function ShareContactDialog({ open, onOpenChange, onSuccess }: ShareContactDialogProps) {
  const [formData, setFormData] = useState({
    contact_id: "",
    shared_with: "",
    permission_level: "read",
    message: "",
    expires_at: "",
  })
  const [contacts, setContacts] = useState<Contact[]>([])
  const [collaborators, setCollaborators] = useState<Collaborator[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (open) {
      fetchData()
    }
  }, [open])

  async function fetchData() {
    try {
      const [contactsRes, collaboratorsRes] = await Promise.all([
        supabase.from("contacts").select("*").order("first_name"),
        supabase.from("collaborators").select("*").order("first_name"),
      ])

      if (contactsRes.error) throw contactsRes.error
      if (collaboratorsRes.error) throw collaboratorsRes.error

      setContacts(contactsRes.data || [])
      setCollaborators(collaboratorsRes.data || [])
    } catch (error) {
      console.error("Error fetching data:", error)
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const shareData = {
        contact_id: formData.contact_id,
        shared_by: "00000000-0000-0000-0000-000000000001", // À récupérer depuis l'auth
        shared_with: formData.shared_with,
        permission_level: formData.permission_level,
        message: formData.message || null,
        expires_at: formData.expires_at || null,
      }

      const { error } = await supabase.from("contact_shares").insert([shareData])

      if (error) throw error

      onSuccess()
      setFormData({
        contact_id: "",
        shared_with: "",
        permission_level: "read",
        message: "",
        expires_at: "",
      })
    } catch (error) {
      console.error("Error sharing contact:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>Partager un Contact</DialogTitle>
          <DialogDescription>
            Partagez un contact avec un membre de votre équipe et définissez les permissions d'accès.
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="contact_id">Contact à partager</Label>
              <Select
                value={formData.contact_id}
                onValueChange={(value) => setFormData({ ...formData, contact_id: value })}
                required
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
              <Label htmlFor="shared_with">Partager avec</Label>
              <Select
                value={formData.shared_with}
                onValueChange={(value) => setFormData({ ...formData, shared_with: value })}
                required
              >
                <SelectTrigger>
                  <SelectValue placeholder="Sélectionner un collaborateur" />
                </SelectTrigger>
                <SelectContent>
                  {collaborators
                    .filter((collab) => collab.id !== "00000000-0000-0000-0000-000000000001")
                    .map((collaborator) => (
                      <SelectItem key={collaborator.id} value={collaborator.id}>
                        {collaborator.first_name} {collaborator.last_name}
                      </SelectItem>
                    ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="permission_level">Niveau de permission</Label>
              <Select
                value={formData.permission_level}
                onValueChange={(value) => setFormData({ ...formData, permission_level: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="read">Lecture seule</SelectItem>
                  <SelectItem value="write">Lecture et modification</SelectItem>
                  <SelectItem value="full">Accès complet</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-2">
              <Label htmlFor="expires_at">Date d'expiration (optionnel)</Label>
              <Input
                id="expires_at"
                type="datetime-local"
                value={formData.expires_at}
                onChange={(e) => setFormData({ ...formData, expires_at: e.target.value })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="message">Message (optionnel)</Label>
              <Textarea
                id="message"
                placeholder="Ajoutez un message pour expliquer pourquoi vous partagez ce contact..."
                value={formData.message}
                onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                rows={3}
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading} className="bg-purple-600 hover:bg-purple-700">
              {loading ? "Partage..." : "Partager"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
