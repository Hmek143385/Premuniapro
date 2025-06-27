"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, Package, Euro } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { ProductDialog } from "@/components/product-dialog"
import { Sidebar } from "@/components/sidebar"

type InsuranceProduct = Database["public"]["Tables"]["insurance_products"]["Row"]

export default function ProductsPage() {
  const [products, setProducts] = useState<InsuranceProduct[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingProduct, setEditingProduct] = useState<InsuranceProduct | null>(null)

  useEffect(() => {
    fetchProducts()
  }, [])

  async function fetchProducts() {
    try {
      // `created_at` is not present in the current table definition,
      // so we sort by `id` to get the most recently-inserted products first.
      const { data, error } = await supabase.from("insurance_products").select("*").order("id", { ascending: false })

      if (error) throw error
      setProducts(data || [])
    } catch (error) {
      console.error("Error fetching products:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteProduct(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce produit ?")) return

    try {
      const { error } = await supabase.from("insurance_products").delete().eq("id", id)

      if (error) throw error
      await fetchProducts()
    } catch (error) {
      console.error("Error deleting product:", error)
    }
  }

  const filteredProducts = products.filter((product) =>
    `${product.name} ${product.code} ${product.category}`.toLowerCase().includes(searchTerm.toLowerCase()),
  )

  const getCategoryBadgeColor = (category: string) => {
    switch (category.toLowerCase()) {
      case "vie":
        return "bg-blue-100 text-blue-800"
      case "automobile":
        return "bg-red-100 text-red-800"
      case "santé":
        return "bg-green-100 text-green-800"
      case "habitation":
        return "bg-yellow-100 text-yellow-800"
      case "professionnelle":
        return "bg-purple-100 text-purple-800"
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
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Produits d'Assurance</h1>
              <p className="text-gray-600">Gérez votre catalogue de produits</p>
            </div>
            <Button onClick={() => setDialogOpen(true)} className="bg-purple-600 hover:bg-purple-700">
              <Plus className="h-4 w-4 mr-2" />
              Nouveau Produit
            </Button>
          </div>

          <div className="mb-6">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Rechercher un produit..."
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
              {filteredProducts.map((product) => (
                <Card key={product.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg">{product.name}</CardTitle>
                        <CardDescription className="font-mono text-sm">{product.code}</CardDescription>
                      </div>
                      <Badge className={getCategoryBadgeColor(product.category)}>{product.category}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex items-center gap-2">
                        <Euro className="h-4 w-4 text-gray-400" />
                        <span className="text-lg font-semibold">
                          {new Intl.NumberFormat("fr-FR", {
                            style: "currency",
                            currency: "EUR",
                          }).format(product.base_price)}
                        </span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Commission:</span>
                        <span className="font-medium">{(product.commission_rate * 100).toFixed(2)}%</span>
                      </div>
                      <div className="flex justify-between text-sm">
                        <span className="text-gray-600">Priorité vente croisée:</span>
                        <span className="font-medium">{product.cross_sell_priority}</span>
                      </div>
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setEditingProduct(product)
                          setDialogOpen(true)
                        }}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteProduct(product.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {filteredProducts.length === 0 && !loading && (
            <div className="text-center py-12">
              <Package className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun produit trouvé</h3>
              <p className="text-gray-600">
                {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par ajouter un produit."}
              </p>
            </div>
          )}

          <ProductDialog
            open={dialogOpen}
            onOpenChange={(open) => {
              setDialogOpen(open)
              if (!open) setEditingProduct(null)
            }}
            product={editingProduct}
            onSuccess={() => {
              fetchProducts()
              setDialogOpen(false)
              setEditingProduct(null)
            }}
          />
        </div>
      </main>
    </div>
  )
}
