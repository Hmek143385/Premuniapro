"use client"

import type React from "react"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Progress } from "@/components/ui/progress"
import { Upload, FileSpreadsheet, Globe, Download, CheckCircle, AlertCircle } from "lucide-react"
import { Sidebar } from "@/components/sidebar"
import { supabase } from "@/lib/supabase"

export default function ImportPage() {
  const [importing, setImporting] = useState(false)
  const [progress, setProgress] = useState(0)
  const [importResult, setImportResult] = useState<{
    total: number
    success: number
    failed: number
    errors: string[]
  } | null>(null)

  async function handleFileImport(event: React.ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0]
    if (!file) return

    setImporting(true)
    setProgress(0)
    setImportResult(null)

    try {
      // Simulation d'import - remplacer par votre logique d'import
      const formData = new FormData()
      formData.append("file", file)

      // Simulation du progrès
      for (let i = 0; i <= 100; i += 10) {
        setProgress(i)
        await new Promise((resolve) => setTimeout(resolve, 200))
      }

      // Simulation du résultat
      setImportResult({
        total: 150,
        success: 145,
        failed: 5,
        errors: ["Ligne 23: Email invalide", "Ligne 67: Téléphone manquant", "Ligne 89: Nom requis"],
      })

      // Créer une notification
      await supabase.from("notifications").insert([
        {
          collaborator_id: "00000000-0000-0000-0000-000000000001",
          title: "Import terminé",
          message: `Import réussi: 145/150 contacts importés`,
          type: "import_completed",
        },
      ])
    } catch (error) {
      console.error("Error importing file:", error)
    } finally {
      setImporting(false)
    }
  }

  async function handleHubSpotSync() {
    setImporting(true)
    setProgress(0)

    try {
      // Simulation de synchronisation HubSpot
      for (let i = 0; i <= 100; i += 5) {
        setProgress(i)
        await new Promise((resolve) => setTimeout(resolve, 100))
      }

      setImportResult({
        total: 89,
        success: 89,
        failed: 0,
        errors: [],
      })

      await supabase.from("notifications").insert([
        {
          collaborator_id: "00000000-0000-0000-0000-000000000001",
          title: "Synchronisation HubSpot terminée",
          message: `89 contacts synchronisés depuis HubSpot`,
          type: "sync_completed",
        },
      ])
    } catch (error) {
      console.error("Error syncing with HubSpot:", error)
    } finally {
      setImporting(false)
    }
  }

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <div className="p-8">
          <div className="mb-8">
            <h1 className="text-3xl font-bold text-gray-900 mb-2">Import & Synchronisation</h1>
            <p className="text-gray-600">Importez vos données depuis différentes sources</p>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            {/* Import Excel/CSV */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <FileSpreadsheet className="h-5 w-5 text-green-600" />
                  Import Excel/CSV
                </CardTitle>
                <CardDescription>Importez vos contacts depuis un fichier Excel ou CSV</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="file-upload">Sélectionner un fichier</Label>
                  <Input
                    id="file-upload"
                    type="file"
                    accept=".xlsx,.xls,.csv"
                    onChange={handleFileImport}
                    disabled={importing}
                  />
                </div>
                <div className="text-sm text-gray-600">
                  <p>Formats supportés: .xlsx, .xls, .csv</p>
                  <p>Colonnes requises: prénom, nom, email</p>
                </div>
                <Button
                  variant="outline"
                  className="w-full bg-transparent"
                  onClick={() => {
                    // Télécharger un template
                    const link = document.createElement("a")
                    link.href = "/template-import.xlsx"
                    link.download = "template-import.xlsx"
                    link.click()
                  }}
                >
                  <Download className="h-4 w-4 mr-2" />
                  Télécharger le template
                </Button>
              </CardContent>
            </Card>

            {/* Synchronisation HubSpot */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Globe className="h-5 w-5 text-orange-600" />
                  Synchronisation HubSpot
                </CardTitle>
                <CardDescription>Synchronisez vos contacts depuis HubSpot</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="hubspot-key">Clé API HubSpot</Label>
                  <Input id="hubspot-key" type="password" placeholder="Entrez votre clé API" />
                </div>
                <div className="text-sm text-gray-600">
                  <p>La synchronisation importera tous vos contacts HubSpot</p>
                  <p>Les doublons seront automatiquement détectés</p>
                </div>
                <Button
                  onClick={handleHubSpotSync}
                  disabled={importing}
                  className="w-full bg-orange-600 hover:bg-orange-700"
                >
                  <Globe className="h-4 w-4 mr-2" />
                  Synchroniser avec HubSpot
                </Button>
              </CardContent>
            </Card>

            {/* Google Sheets */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <FileSpreadsheet className="h-5 w-5 text-blue-600" />
                  Google Sheets
                </CardTitle>
                <CardDescription>Importez depuis Google Sheets</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="sheets-url">URL Google Sheets</Label>
                  <Input id="sheets-url" placeholder="https://docs.google.com/spreadsheets/..." />
                </div>
                <div className="text-sm text-gray-600">
                  <p>Assurez-vous que le document est partagé publiquement</p>
                  <p>Ou connectez votre compte Google</p>
                </div>
                <Button variant="outline" className="w-full bg-transparent">
                  <Upload className="h-4 w-4 mr-2" />
                  Importer depuis Google Sheets
                </Button>
              </CardContent>
            </Card>

            {/* Statut d'import */}
            {importing && (
              <Card>
                <CardHeader>
                  <CardTitle>Import en cours...</CardTitle>
                </CardHeader>
                <CardContent>
                  <Progress value={progress} className="w-full" />
                  <p className="text-sm text-gray-600 mt-2">{progress}% terminé</p>
                </CardContent>
              </Card>
            )}

            {/* Résultats d'import */}
            {importResult && (
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <CheckCircle className="h-5 w-5 text-green-600" />
                    Résultats de l'import
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-3 gap-4 text-center">
                    <div>
                      <div className="text-2xl font-bold text-blue-600">{importResult.total}</div>
                      <div className="text-sm text-gray-600">Total</div>
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-green-600">{importResult.success}</div>
                      <div className="text-sm text-gray-600">Réussis</div>
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-red-600">{importResult.failed}</div>
                      <div className="text-sm text-gray-600">Échecs</div>
                    </div>
                  </div>
                  {importResult.errors.length > 0 && (
                    <div className="space-y-2">
                      <h4 className="font-medium flex items-center gap-2">
                        <AlertCircle className="h-4 w-4 text-red-600" />
                        Erreurs détectées:
                      </h4>
                      <ul className="text-sm text-red-600 space-y-1">
                        {importResult.errors.map((error, index) => (
                          <li key={index}>• {error}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </CardContent>
              </Card>
            )}
          </div>
        </div>
      </main>
    </div>
  )
}
