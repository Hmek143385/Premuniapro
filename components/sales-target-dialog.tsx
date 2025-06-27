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
import { supabase, type Database } from "@/lib/supabase"

type SalesTarget = Database["public"]["Tables"]["sales_targets"]["Row"]
type Collaborator = Database["public"]["Tables"]["collaborators"]["Row"]

interface SalesTargetDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  salesTarget?: SalesTarget | null
  onSuccess: () => void
}

export function SalesTargetDialog({ open, onOpenChange, salesTarget, onSuccess }: SalesTargetDialogProps) {
  const [formData, setFormData] = useState({
    collaborator_id: "",
    target_type: "",
    target_value: "",
    min_value: "",
    start_date: new Date().toISOString().split("T")[0],
    end_date: "",
    weight: "100",
  })
  const [collaborators, setCollaborators] = useState<Collaborator[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchCollaborators()
  }, [])

  useEffect(() => {
    if (salesTarget) {
      setFormData({
        collaborator_id: salesTarget.collaborator_id,
        target_type: salesTarget.target_type,
        target_value: salesTarget.target_value.toString(),
        min_value: salesTarget.min_value.toString(),
        start_date: salesTarget.start_date,
        end_date: salesTarget.end_date,
        weight: salesTarget.weight.toString(),
      })
    } else {
      setFormData({
        collaborator_id: "",
        target_type: "",
        target_value: "",
        min_value: "",
        start_date: new Date().toISOString().split("T")[0],
        end_date: "",
        weight: "100",
      })
    }
  }, [salesTarget])

  async function fetchCollaborators() {
    try {
      const { data, error } = await supabase.from("collaborators").select("*").eq("is_active", true).order("first_name")

      if (error) throw error
      setCollaborators(data || [])
    } catch (error) {
      console.error("Error fetching collaborators:", error)
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const targetData = {
        collaborator_id: formData.collaborator_id,
        target_type: formData.target_type,
        target_value: Number.parseFloat(formData.target_value),
        min_value: Number.parseFloat(formData.min_value),
        start_date: formData.start_date,
        end_date: formData.end_date,
        weight: Number.parseInt(formData.weight),
      }

      if (salesTarget) {
        const { error } = await supabase.from("sales_targets").update(targetData).eq("id", salesTarget.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from("sales_targets").insert([targetData])

        if (error) throw error
      }

      onSuccess()
    } catch (error) {
      console.error("Error saving sales target:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>{salesTarget ? "Modifier l'objectif" : "Nouvel objectif"}</DialogTitle>
          <DialogDescription>
            {salesTarget ? "Modifiez les détails de l'objectif de vente." : "Créez un nouvel objectif de vente."}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-2 gap-4">
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
                        {collaborator.first_name} {collaborator.last_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="target_type">Type d'objectif</Label>
                <Select
                  value={formData.target_type}
                  onValueChange={(value) => setFormData({ ...formData, target_type: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionner un type" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="revenue">Chiffre d'affaires</SelectItem>
                    <SelectItem value="contracts">Nombre de contrats</SelectItem>
                    <SelectItem value="leads">Nombre de leads</SelectItem>
                    <SelectItem value="commission">Commission</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="target_value">Valeur objectif</Label>
                <Input
                  id="target_value"
                  type="number"
                  step="0.01"
                  min="0"
                  value={formData.target_value}
                  onChange={(e) => setFormData({ ...formData, target_value: e.target.value })}
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="min_value">Valeur minimale</Label>
                <Input
                  id="min_value"
                  type="number"
                  step="0.01"
                  min="0"
                  value={formData.min_value}
                  onChange={(e) => setFormData({ ...formData, min_value: e.target.value })}
                  required
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="start_date">Date de début</Label>
                <Input
                  id="start_date"
                  type="date"
                  value={formData.start_date}
                  onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="end_date">Date de fin</Label>
                <Input
                  id="end_date"
                  type="date"
                  value={formData.end_date}
                  onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
                  required
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="weight">Poids (%)</Label>
              <Input
                id="weight"
                type="number"
                min="1"
                max="100"
                value={formData.weight}
                onChange={(e) => setFormData({ ...formData, weight: e.target.value })}
                required
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Enregistrement..." : salesTarget ? "Modifier" : "Créer"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
