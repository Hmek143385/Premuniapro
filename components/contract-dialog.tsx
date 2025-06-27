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

type Contract = Database["public"]["Tables"]["contracts"]["Row"]
type Contact = Database["public"]["Tables"]["contacts"]["Row"]
type InsuranceProduct = Database["public"]["Tables"]["insurance_products"]["Row"]
type Collaborator = Database["public"]["Tables"]["collaborators"]["Row"]

interface ContractDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  contract?: Contract | null
  onSuccess: () => void
}

export function ContractDialog({ open, onOpenChange, contract, onSuccess }: ContractDialogProps) {
  const [formData, setFormData] = useState({
    contact_id: "",
    product_id: "",
    full_name: "",
    city: "",
    signature_date: new Date().toISOString().split("T")[0],
    start_date: new Date().toISOString().split("T")[0],
    end_date: "",
    monthly_premium: "",
    annual_premium: "",
    status: "active",
    assigned_to: "",
    country: "France",
  })
  const [contacts, setContacts] = useState<Contact[]>([])
  const [products, setProducts] = useState<InsuranceProduct[]>([])
  const [collaborators, setCollaborators] = useState<Collaborator[]>([])
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    fetchData()
  }, [])

  useEffect(() => {
    if (contract) {
      setFormData({
        contact_id: contract.contact_id,
        product_id: contract.product_id,
        full_name: contract.full_name,
        city: contract.city || "",
        signature_date: contract.signature_date,
        start_date: contract.start_date,
        end_date: contract.end_date || "",
        monthly_premium: contract.monthly_premium.toString(),
        annual_premium: contract.annual_premium.toString(),
        status: contract.status,
        assigned_to: contract.assigned_to || "",
        country: contract.country,
      })
    } else {
      setFormData({
        contact_id: "",
        product_id: "",
        full_name: "",
        city: "",
        signature_date: new Date().toISOString().split("T")[0],
        start_date: new Date().toISOString().split("T")[0],
        end_date: "",
        monthly_premium: "",
        annual_premium: "",
        status: "active",
        assigned_to: "",
        country: "France",
      })
    }
  }, [contract])

  async function fetchData() {
    try {
      const [contactsRes, productsRes, collaboratorsRes] = await Promise.all([
        supabase.from("contacts").select("*").order("first_name"),
        supabase.from("insurance_products").select("*").order("name"),
        supabase.from("collaborators").select("*").eq("is_active", true).order("first_name"),
      ])

      if (contactsRes.error) throw contactsRes.error
      if (productsRes.error) throw productsRes.error
      if (collaboratorsRes.error) throw collaboratorsRes.error

      setContacts(contactsRes.data || [])
      setProducts(productsRes.data || [])
      setCollaborators(collaboratorsRes.data || [])
    } catch (error) {
      console.error("Error fetching data:", error)
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const contractData = {
        contact_id: formData.contact_id,
        product_id: formData.product_id,
        full_name: formData.full_name,
        city: formData.city || null,
        signature_date: formData.signature_date,
        start_date: formData.start_date,
        end_date: formData.end_date || null,
        monthly_premium: Number.parseFloat(formData.monthly_premium),
        annual_premium: Number.parseFloat(formData.annual_premium),
        status: formData.status,
        assigned_to: formData.assigned_to || null,
        country: formData.country,
      }

      if (contract) {
        const { error } = await supabase.from("contracts").update(contractData).eq("id", contract.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from("contracts").insert([contractData])

        if (error) throw error
      }

      onSuccess()
    } catch (error) {
      console.error("Error saving contract:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[600px] max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{contract ? "Modifier le contrat" : "Nouveau contrat"}</DialogTitle>
          <DialogDescription>
            {contract ? "Modifiez les informations du contrat." : "Créez un nouveau contrat d'assurance."}
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
                <Label htmlFor="product_id">Produit</Label>
                <Select
                  value={formData.product_id}
                  onValueChange={(value) => setFormData({ ...formData, product_id: value })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Sélectionner un produit" />
                  </SelectTrigger>
                  <SelectContent>
                    {products.map((product) => (
                      <SelectItem key={product.id} value={product.id}>
                        {product.name} ({product.code})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="full_name">Nom complet</Label>
                <Input
                  id="full_name"
                  value={formData.full_name}
                  onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="city">Ville</Label>
                <Input
                  id="city"
                  value={formData.city}
                  onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                />
              </div>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label htmlFor="signature_date">Date de signature</Label>
                <Input
                  id="signature_date"
                  type="date"
                  value={formData.signature_date}
                  onChange={(e) => setFormData({ ...formData, signature_date: e.target.value })}
                  required
                />
              </div>
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
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="monthly_premium">Prime mensuelle (€)</Label>
                <Input
                  id="monthly_premium"
                  type="number"
                  step="0.01"
                  min="0"
                  value={formData.monthly_premium}
                  onChange={(e) => setFormData({ ...formData, monthly_premium: e.target.value })}
                  required
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="annual_premium">Prime annuelle (€)</Label>
                <Input
                  id="annual_premium"
                  type="number"
                  step="0.01"
                  min="0"
                  value={formData.annual_premium}
                  onChange={(e) => setFormData({ ...formData, annual_premium: e.target.value })}
                  required
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label htmlFor="status">Statut</Label>
                <Select value={formData.status} onValueChange={(value) => setFormData({ ...formData, status: value })}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="active">Actif</SelectItem>
                    <SelectItem value="pending">En attente</SelectItem>
                    <SelectItem value="cancelled">Annulé</SelectItem>
                    <SelectItem value="expired">Expiré</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label htmlFor="assigned_to">Assigné à</Label>
                <Select
                  value={formData.assigned_to}
                  onValueChange={(value) => setFormData({ ...formData, assigned_to: value })}
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
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Enregistrement..." : contract ? "Modifier" : "Créer"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
