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

type InsuranceProduct = Database["public"]["Tables"]["insurance_products"]["Row"]

interface ProductDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  product?: InsuranceProduct | null
  onSuccess: () => void
}

export function ProductDialog({ open, onOpenChange, product, onSuccess }: ProductDialogProps) {
  const [formData, setFormData] = useState({
    code: "",
    name: "",
    category: "",
    base_price: "",
    commission_rate: "0.05",
    cross_sell_priority: "0",
  })
  const [loading, setLoading] = useState(false)

  useEffect(() => {
    if (product) {
      setFormData({
        code: product.code,
        name: product.name,
        category: product.category,
        base_price: product.base_price.toString(),
        commission_rate: product.commission_rate.toString(),
        cross_sell_priority: product.cross_sell_priority.toString(),
      })
    } else {
      setFormData({
        code: "",
        name: "",
        category: "",
        base_price: "",
        commission_rate: "0.05",
        cross_sell_priority: "0",
      })
    }
  }, [product])

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const productData = {
        code: formData.code,
        name: formData.name,
        category: formData.category,
        base_price: Number.parseFloat(formData.base_price),
        commission_rate: Number.parseFloat(formData.commission_rate),
        cross_sell_priority: Number.parseInt(formData.cross_sell_priority),
      }

      if (product) {
        const { error } = await supabase.from("insurance_products").update(productData).eq("id", product.id)

        if (error) throw error
      } else {
        const { error } = await supabase.from("insurance_products").insert([productData])

        if (error) throw error
      }

      onSuccess()
    } catch (error) {
      console.error("Error saving product:", error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>{product ? "Modifier le produit" : "Nouveau produit"}</DialogTitle>
          <DialogDescription>
            {product
              ? "Modifiez les informations du produit d'assurance."
              : "Ajoutez un nouveau produit à votre catalogue."}
          </DialogDescription>
        </DialogHeader>
        <form onSubmit={handleSubmit}>
          <div className="grid gap-4 py-4">
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="code" className="text-right">
                Code
              </Label>
              <Input
                id="code"
                value={formData.code}
                onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="name" className="text-right">
                Nom
              </Label>
              <Input
                id="name"
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="category" className="text-right">
                Catégorie
              </Label>
              <Select
                value={formData.category}
                onValueChange={(value) => setFormData({ ...formData, category: value })}
              >
                <SelectTrigger className="col-span-3">
                  <SelectValue placeholder="Sélectionner une catégorie" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="Vie">Vie</SelectItem>
                  <SelectItem value="Automobile">Automobile</SelectItem>
                  <SelectItem value="Santé">Santé</SelectItem>
                  <SelectItem value="Habitation">Habitation</SelectItem>
                  <SelectItem value="Professionnelle">Professionnelle</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label htmlFor="base_price" className="text-right">
                Prix de base (€)
              </Label>
              <Input
                id="base_price"
                type="number"
                step="0.01"
                min="0"
                value={formData.base_price}
                onChange={(e) => setFormData({ ...formData, base_price: e.target.value })}
                className="col-span-3"
                required
              />
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
              <Label htmlFor="cross_sell_priority" className="text-right">
                Priorité vente croisée
              </Label>
              <Input
                id="cross_sell_priority"
                type="number"
                min="0"
                value={formData.cross_sell_priority}
                onChange={(e) => setFormData({ ...formData, cross_sell_priority: e.target.value })}
                className="col-span-3"
                required
              />
            </div>
          </div>
          <DialogFooter>
            <Button type="submit" disabled={loading}>
              {loading ? "Enregistrement..." : product ? "Modifier" : "Créer"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
