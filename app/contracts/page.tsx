"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Edit, Trash2, FileText, Euro, Calendar } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { ContractDialog } from "@/components/contract-dialog"
import { Sidebar } from "@/components/sidebar"

type Contract = Database["public"]["Tables"]["contracts"]["Row"] & {
  contacts?: {
    first_name: string
    last_name: string
    client_code: string
  }
  insurance_products?: {
    name: string
    code: string
  }
  collaborators?: {
    first_name: string
    last_name: string
  }
}

export default function ContractsPage() {
  const [contracts, setContracts] = useState<Contract[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [dialogOpen, setDialogOpen] = useState(false)
  const [editingContract, setEditingContract] = useState<Contract | null>(null)

  useEffect(() => {
    fetchContracts()
  }, [])

  async function fetchContracts() {
    try {
      const { data, error } = await supabase
        .from("contracts")
        .select(`
          *,
          contacts:contact_id (
            first_name,
            last_name,
            client_code
          ),
          insurance_products:product_id (
            name,
            code
          ),
          collaborators:assigned_to (
            first_name,
            last_name
          )
        `)
        .order("created_at", { ascending: false })

      if (error) throw error
      setContracts(data || [])
    } catch (error) {
      console.error("Error fetching contracts:", error)
    } finally {
      setLoading(false)
    }
  }

  async function deleteContract(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce contrat ?")) return

    try {
      const { error } = await supabase.from("contracts").delete().eq("id", id)

      if (error) throw error
      await fetchContracts()
    } catch (error) {
      console.error("Error deleting contract:", error)
    }
  }

  const filteredContracts = contracts.filter((contract) =>
    `${contract.contract_number} ${contract.full_name} ${contract.contacts?.client_code}`
      .toLowerCase()
      .includes(searchTerm.toLowerCase()),
  )

  const getStatusBadgeColor = (status: string) => {
    switch (status) {
      case "active":
        return "bg-green-100 text-green-800"
      case "pending":
        return "bg-yellow-100 text-yellow-800"
      case "cancelled":
        return "bg-red-100 text-red-800"
      case "expired":
        return "bg-gray-100 text-gray-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="animate-pulse space-y-4">
          <div className="h-8 bg-gray-200 rounded w-1/4"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-80 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <div className="p-8">
          <div className="container mx-auto px-4 py-8">
            <div className="flex justify-between items-center mb-8">
              <div>
                <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
                  <FileText className="h-8 w-8 text-orange-600" />
                  Contrats
                </h1>
                <p className="text-gray-600 mt-2">Gérez les contrats et commissions</p>
              </div>
              <Button onClick={() => setDialogOpen(true)} className="bg-violet-500 hover:bg-violet-700 text-white">
                <Plus className="h-4 w-4 mr-2" />
                Nouveau Contrat
              </Button>
            </div>

            <div className="mb-6">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                <Input
                  placeholder="Rechercher un contrat..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {filteredContracts.map((contract) => (
                <Card key={contract.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex justify-between items-start">
                      <div>
                        <CardTitle className="text-lg">{contract.full_name}</CardTitle>
                        <CardDescription className="font-mono text-sm">{contract.contract_number}</CardDescription>
                      </div>
                      <Badge className={getStatusBadgeColor(contract.status)}>{contract.status}</Badge>
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      {contract.contacts && (
                        <div className="text-sm">
                          <span className="text-gray-600">Client:</span>
                          <span className="ml-2 font-medium">
                            {contract.contacts.first_name} {contract.contacts.last_name}
                          </span>
                          <span className="ml-2 text-gray-500">({contract.contacts.client_code})</span>
                        </div>
                      )}
                      {contract.insurance_products && (
                        <div className="text-sm">
                          <span className="text-gray-600">Produit:</span>
                          <span className="ml-2 font-medium">{contract.insurance_products.name}</span>
                        </div>
                      )}
                      <div className="flex items-center gap-2 text-sm">
                        <Calendar className="h-4 w-4 text-gray-400" />
                        <span>Signé le {new Date(contract.signature_date).toLocaleDateString("fr-FR")}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Euro className="h-4 w-4 text-gray-400" />
                        <div className="text-sm">
                          <div className="font-semibold">
                            {new Intl.NumberFormat("fr-FR", {
                              style: "currency",
                              currency: "EUR",
                            }).format(contract.monthly_premium)}
                            /mois
                          </div>
                          <div className="text-gray-600">
                            {new Intl.NumberFormat("fr-FR", {
                              style: "currency",
                              currency: "EUR",
                            }).format(contract.annual_premium)}
                            /an
                          </div>
                        </div>
                      </div>
                      <div className="text-sm">
                        <span className="text-gray-600">Commission reçue:</span>
                        <span className="ml-2 font-medium text-green-600">
                          {new Intl.NumberFormat("fr-FR", {
                            style: "currency",
                            currency: "EUR",
                          }).format(contract.received_commission)}
                        </span>
                      </div>
                      {contract.collaborators && (
                        <div className="text-sm">
                          <span className="text-gray-600">Assigné à:</span>
                          <span className="ml-2 font-medium">
                            {contract.collaborators.first_name} {contract.collaborators.last_name}
                          </span>
                        </div>
                      )}
                    </div>
                    <div className="flex gap-2 mt-4">
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setEditingContract(contract)
                          setDialogOpen(true)
                        }}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button variant="outline" size="sm" onClick={() => deleteContract(contract.id)}>
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>

            {filteredContracts.length === 0 && (
              <div className="text-center py-12">
                <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-900 mb-2">Aucun contrat trouvé</h3>
                <p className="text-gray-600">
                  {searchTerm ? "Aucun résultat pour votre recherche." : "Commencez par ajouter un contrat."}
                </p>
              </div>
            )}

            <ContractDialog
              open={dialogOpen}
              onOpenChange={(open) => {
                setDialogOpen(open)
                if (!open) setEditingContract(null)
              }}
              contract={editingContract}
              onSuccess={() => {
                fetchContracts()
                setDialogOpen(false)
                setEditingContract(null)
              }}
            />
          </div>
        </div>
      </main>
    </div>
  )
}
