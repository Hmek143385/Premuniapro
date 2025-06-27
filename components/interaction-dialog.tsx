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
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { supabase, type Database } from "@/lib/supabase"

type Interaction = Database["public"]["Tables"]["interactions"]["Row"]
type Contact = Database["public"]["Tables"]["contacts"]["Row"]
type Collaborator = Database["public"]["Tables"]["collaborators"]["Row"]

interface InteractionDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  interaction?: Interaction | null
  onSuccess: () => void
}

export function InteractionDialog({ open, onOpenChange, interaction, onSuccess }: InteractionDialogProps) {
  const [formData, setFormData] = useState({
    contact_id: "",
    type: "",
    outcome: "",
    scheduled_at: "",
    completed_at: "",
    duration_minutes: "0",
    notes: "",
    next_step: "",
    collaborator_id: "",
  })
  const [contacts, setContacts] = useState<Contact[]>([])
  const [collaborators, setCollaborators] = useState<Collaborator[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchData()
  }, [])

  useEffect(() => {
    if (interaction) {
      setFormData({
        contact_id: interaction.contact_id,
        type: interaction.type,
        outcome: interaction.outcome || "",
        scheduled_at: interaction.scheduled_at ? new Date(interaction.scheduled_at).toISOString().slice(0, 16) : "",
        completed_at: interaction.completed_at ? new Date(interaction.completed_at).toISOString().slice(0, 16) : "",
        duration_minutes: interaction.duration_minutes.toString(),
        notes: interaction.notes || "",
        next_step: interaction.next_step || "",
        collaborator_id: interaction.collaborator_id,
      })
    } else {
      setFormData({
        contact_id: "",
        type: "",
        outcome: "",
        scheduled_at: "",
        completed_at: "",
        duration_minutes: "0",
        notes: "",
        next_step: "",
        collaborator_id: "",
      })
    }
  }, [interaction])

  async function fetchData() {
    try {
      const [contactsRes, collaboratorsRes] = await Promise.all([
        supabase.from("contacts").select("*").order("first_name"),
        supabase.from("collaborators").select("*").eq("is_active", true).order("id", { ascending: true }),
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
      const interactionData = {
        contact_id: formData.contact_id,
        type: formData.type,
        outcome: formData.outcome || null,
        scheduled_at: formData.scheduled_at ? new Date(formData.scheduled_at).toISOString() : null,
        completed_at: formData.completed_at ? new Date(formData.completed_at).toISOString() : null,
        duration_minutes: Number.parseInt(formData.duration_minutes),
        notes: formData.notes || null,
        next_step: formData.next_step || null,
        collaborator_id: formData.collaborator_id,
      }

      if (interaction) {
        const { error } = await supabase.from("interactions").update(interactionData).eq("id", interaction.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from("interactions").insert([interactionData])

        if (error) throw error
      }

      onSuccess()
    } catch (error) {
      console.error("Error saving interaction:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[600px] max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{interaction ? "Modifier l'interaction" : "Nouvelle interaction"}</DialogTitle>
          <DialogDescription>
            {interaction ? "Modifiez les détails de l'interaction." : "Enregistrez une nouvelle interaction client."}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="contact_id">Contact</Label>
                <Select
                  value={formData.contact_id}
                  onValueChange={(value) => setFormData({ ...formData, contact_id: value })}
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
                <Label htmlFor="collaborator_id">Collaborateur</Label>
                <Select
                  value={formData.collaborator_id}
                  onValueChange={(value) => setFormData({ ...formData, collaborator_id: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionner un collaborateur" />
                  </SelectTrigger>
                  <SelectContent>
                    {collaborators.map((collaborator) => (
                      <SelectItem key={collaborator.id} value={collaborator.id}>
                        {collaborator.first_name ?? ""} {collaborator.last_name ?? ""}{" "}
                        {!collaborator.first_name && !collaborator.last_name && `Collaborateur #${collaborator.id}`}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="type">Type</Label>
                <Select value={formData.type} onValueChange={(value) => setFormData({ ...formData, type: value })}>
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionner un type" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="call">Appel</SelectItem>
                    <SelectItem value="email">Email</SelectItem>
                    <SelectItem value="meeting">Rencontre</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="outcome">Résultat</Label>
                <Input
                  id="outcome"
                  value={formData.outcome}
                  onChange={(e) => setFormData({ ...formData, outcome: e.target.value })}
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="scheduled_at">Planifié le</Label>
                <Input
                  id="scheduled_at"
                  type="datetime-local"
                  value={formData.scheduled_at}
                  onChange={(e) => setFormData({ ...formData, scheduled_at: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="completed_at">Terminé le</Label>
                <Input
                  id="completed_at"
                  type="datetime-local"
                  value={formData.completed_at}
                  onChange={(e) => setFormData({ ...formData, completed_at: e.target.value })}
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="duration_minutes">Durée (minutes)</Label>
                <Input
                  id="duration_minutes"
                  type="number"
                  value={formData.duration_minutes}
                  onChange={(e) => setFormData({ ...formData, duration_minutes: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="next_step">Prochain pas</Label>
                <Input
                  id="next_step"
                  value={formData.next_step}
                  onChange={(e) => setFormData({ ...formData, next_step: e.target.value })}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="notes">Notes</Label>
              <Textarea
                id="notes"
                value={formData.notes}
                onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Enregistrement..." : "Enregistrer"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
