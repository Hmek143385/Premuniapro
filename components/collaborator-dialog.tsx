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
import { Switch } from "@/components/ui/switch"
import { supabase, type Database } from "@/lib/supabase"

type Collaborator = Database["public"]["Tables"]["collaborators"]["Row"]

interface CollaboratorDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  collaborator?: Collaborator | null
  onSuccess: () => void
}

export function CollaboratorDialog({ open, onOpenChange, collaborator, onSuccess }: CollaboratorDialogProps) {
  const [formData, setFormData] = useState({
    email: "",
    password: "",
    first_name: "",
    last_name: "",
    role: "commercial",
    commission_rate: "0.05",
    hire_date: new Date().toISOString().split("T")[0],
    is_active: true,
  })
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (collaborator) {
      setFormData({
        email: collaborator.email,
        password: "",
        first_name: collaborator.first_name,
        last_name: collaborator.last_name,
        role: collaborator.role,
        commission_rate: collaborator.commission_rate.toString(),
        hire_date: collaborator.hire_date,
        is_active: collaborator.is_active,
      })
    } else {
      setFormData({
        email: "",
        password: "",
        first_name: "",
        last_name: "",
        role: "commercial",
        commission_rate: "0.05",
        hire_date: new Date().toISOString().split("T")[0],
        is_active: true,
      })
    }
  }, [collaborator])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const collaboratorData = {
        email: formData.email,
        first_name: formData.first_name,
        last_name: formData.last_name,
        role: formData.role,
        commission_rate: Number.parseFloat(formData.commission_rate),
        hire_date: formData.hire_date,
        is_active: formData.is_active,
        ...(formData.password && { password_hash: `$2b$10$${formData.password}` }),
      }

      if (collaborator) {
        const { error } = await supabase.from("collaborators").update(collaboratorData).eq("id", collaborator.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from("collaborators").insert([
          {
            ...collaboratorData,
            password_hash: `$2b$10$${formData.password}`,
          },
        ])

        if (error) throw error
      }

      onSuccess()
    } catch (error) {
      console.error("Error saving collaborator:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{collaborator ? "Modifier le collaborateur" : "Nouveau collaborateur"}</DialogTitle>
          <DialogDescription>
            {collaborator
              ? "Modifiez les informations du collaborateur."
              : "Ajoutez un nouveau collaborateur à votre équipe."}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="email" className="text-right">
                Email
              </Label>
              <Input
                id="email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="password" className="text-right">
                {collaborator ? "Nouveau mot de passe" : "Mot de passe"}
              </Label>
              <Input
                id="password"
                type="password"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                className="col-span-3"
                required={!collaborator}
                placeholder={collaborator ? "Laisser vide pour ne pas changer" : ""}
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="first_name" className="text-right">
                Prénom
              </Label>
              <Input
                id="first_name"
                value={formData.first_name}
                onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="last_name" className="text-right">
                Nom
              </Label>
              <Input
                id="last_name"
                value={formData.last_name}
                onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="role" className="text-right">
                Rôle
              </Label>
              <Select value={formData.role} onValueChange={(value) => setFormData({ ...formData, role: value })}>
                <SelectTrigger className="col-span-3">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="admin">Administrateur</SelectItem>
                  <SelectItem value="manager">Manager</SelectItem>
                  <SelectItem value="commercial">Commercial</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="commission_rate" className="text-right">
                Taux de commission
              </Label>
              <Input
                id="commission_rate"
                type="number"
                step="0.0001"
                min="0"
                max="1"
                value={formData.commission_rate}
                onChange={(e) => setFormData({ ...formData, commission_rate: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="hire_date" className="text-right">
                Date d'embauche
              </Label>
              <Input
                id="hire_date"
                type="date"
                value={formData.hire_date}
                onChange={(e) => setFormData({ ...formData, hire_date: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="is_active" className="text-right">
                Actif
              </Label>
              <Switch
                id="is_active"
                checked={formData.is_active}
                onCheckedChange={(checked) => setFormData({ ...formData, is_active: checked })}
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Enregistrement..." : collaborator ? "Modifier" : "Créer"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
