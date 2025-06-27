"use client"

import { useState } from "react"
import { useAuth } from "@/components/auth-provider"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Switch } from "@/components/ui/switch"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import {
  User,
  Bell,
  Download,
  Upload,
  Palette,
  Globe,
  Shield,
  Database,
  FileText,
  Mail,
  SettingsIcon,
  Save,
  RefreshCw,
  Building2,
} from "lucide-react"
import { AuthGuard } from "@/components/auth-guard"

export default function SettingsPage() {
  const { user } = useAuth()
  const [loading, setLoading] = useState(false)
  const [saved, setSaved] = useState(false)

  const handleSave = async () => {
    setLoading(true)
    // Simuler la sauvegarde
    await new Promise((resolve) => setTimeout(resolve, 1000))
    setSaved(true)
    setLoading(false)
    setTimeout(() => setSaved(false), 3000)
  }

  const handleExport = async (type: string) => {
    setLoading(true)
    // Simuler l'export
    await new Promise((resolve) => setTimeout(resolve, 2000))

    // Créer un fichier de test
    const data = {
      user: user?.email,
      type: type,
      date: new Date().toISOString(),
      data: `Données ${type} exportées avec succès`,
    }

    const blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = `export-${type}-${new Date().toISOString().split("T")[0]}.json`
    a.click()
    URL.revokeObjectURL(url)

    setLoading(false)
  }

  return (
    <AuthGuard>
      <div className="container mx-auto p-6 max-w-4xl">
        <div className="flex items-center gap-3 mb-6">
          <SettingsIcon className="h-8 w-8 text-blue-600" />
          <div>
            <h1 className="text-3xl font-bold">Paramètres</h1>
            <p className="text-gray-600">Gérez vos préférences et paramètres du compte</p>
          </div>
        </div>

        <Tabs defaultValue="profile" className="space-y-6">
          <TabsList className="grid w-full grid-cols-5">
            <TabsTrigger value="profile" className="flex items-center gap-2">
              <User className="h-4 w-4" />
              Profil
            </TabsTrigger>
            <TabsTrigger value="notifications" className="flex items-center gap-2">
              <Bell className="h-4 w-4" />
              Notifications
            </TabsTrigger>
            <TabsTrigger value="data" className="flex items-center gap-2">
              <Database className="h-4 w-4" />
              Données
            </TabsTrigger>
            <TabsTrigger value="appearance" className="flex items-center gap-2">
              <Palette className="h-4 w-4" />
              Apparence
            </TabsTrigger>
            <TabsTrigger value="system" className="flex items-center gap-2">
              <Shield className="h-4 w-4" />
              Système
            </TabsTrigger>
          </TabsList>

          {/* PROFIL */}
          <TabsContent value="profile">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <User className="h-5 w-5" />
                  Informations du profil
                </CardTitle>
                <CardDescription>Modifiez vos informations personnelles et préférences de compte</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="flex items-center gap-4">
                  <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center">
                    <User className="h-10 w-10 text-blue-600" />
                  </div>
                  <div className="flex-1">
                    <h3 className="font-semibold">
                      {user?.first_name} {user?.last_name}
                    </h3>
                    <p className="text-gray-600">{user?.email}</p>
                    <Badge variant="secondary" className="mt-1">
                      {user?.role}
                    </Badge>
                  </div>
                  <Button variant="outline">Changer la photo</Button>
                </div>

                <Separator />

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="firstName">Prénom</Label>
                    <Input id="firstName" defaultValue={user?.first_name} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="lastName">Nom</Label>
                    <Input id="lastName" defaultValue={user?.last_name} />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="email">Email</Label>
                  <Input id="email" type="email" defaultValue={user?.email} />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="phone">Téléphone</Label>
                  <Input id="phone" placeholder="+33 1 23 45 67 89" />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="signature">Signature email</Label>
                  <Textarea id="signature" placeholder="Votre signature automatique pour les emails..." rows={3} />
                </div>

                <Button onClick={handleSave} disabled={loading} className="w-full">
                  {loading ? <RefreshCw className="h-4 w-4 animate-spin mr-2" /> : <Save className="h-4 w-4 mr-2" />}
                  {saved ? "Sauvegardé !" : "Sauvegarder les modifications"}
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* NOTIFICATIONS */}
          <TabsContent value="notifications">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Bell className="h-5 w-5" />
                  Préférences de notification
                </CardTitle>
                <CardDescription>Configurez comment et quand vous souhaitez être notifié</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Notifications email</Label>
                      <p className="text-sm text-gray-600">Recevoir des notifications par email</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Notifications push</Label>
                      <p className="text-sm text-gray-600">Recevoir des notifications dans le navigateur</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Nouveaux contacts</Label>
                      <p className="text-sm text-gray-600">Être notifié des nouveaux contacts assignés</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Tâches en retard</Label>
                      <p className="text-sm text-gray-600">Rappels pour les tâches non terminées</p>
                    </div>
                    <Switch defaultChecked />
                  </div>

                  <div className="flex items-center justify-between">
                    <div className="space-y-0.5">
                      <Label>Rapports hebdomadaires</Label>
                      <p className="text-sm text-gray-600">Recevoir un résumé hebdomadaire de vos performances</p>
                    </div>
                    <Switch />
                  </div>
                </div>

                <Separator />

                <div className="space-y-4">
                  <h4 className="font-medium">Fréquence des notifications</h4>
                  <Select defaultValue="immediate">
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="immediate">Immédiatement</SelectItem>
                      <SelectItem value="hourly">Toutes les heures</SelectItem>
                      <SelectItem value="daily">Quotidien</SelectItem>
                      <SelectItem value="weekly">Hebdomadaire</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <Button onClick={handleSave} disabled={loading} className="w-full">
                  {loading ? <RefreshCw className="h-4 w-4 animate-spin mr-2" /> : <Save className="h-4 w-4 mr-2" />}
                  Sauvegarder les préférences
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* DONNÉES */}
          <TabsContent value="data">
            <div className="space-y-6">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Download className="h-5 w-5" />
                    Export de données
                  </CardTitle>
                  <CardDescription>Exportez vos données dans différents formats</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <Button
                      variant="outline"
                      onClick={() => handleExport("contacts")}
                      disabled={loading}
                      className="h-20 flex-col"
                    >
                      <FileText className="h-6 w-6 mb-2" />
                      Exporter les contacts
                    </Button>
                    <Button
                      variant="outline"
                      onClick={() => handleExport("interactions")}
                      disabled={loading}
                      className="h-20 flex-col"
                    >
                      <Mail className="h-6 w-6 mb-2" />
                      Exporter les interactions
                    </Button>
                    <Button
                      variant="outline"
                      onClick={() => handleExport("contracts")}
                      disabled={loading}
                      className="h-20 flex-col"
                    >
                      <FileText className="h-6 w-6 mb-2" />
                      Exporter les contrats
                    </Button>
                    <Button
                      variant="outline"
                      onClick={() => handleExport("reports")}
                      disabled={loading}
                      className="h-20 flex-col"
                    >
                      <Database className="h-6 w-6 mb-2" />
                      Exporter les rapports
                    </Button>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Upload className="h-5 w-5" />
                    Import de données
                  </CardTitle>
                  <CardDescription>Importez des données depuis des fichiers externes</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                    <Upload className="h-12 w-12 mx-auto text-gray-400 mb-4" />
                    <p className="text-gray-600 mb-2">Glissez-déposez vos fichiers ici</p>
                    <p className="text-sm text-gray-500">Formats supportés: CSV, Excel, JSON</p>
                    <Button variant="outline" className="mt-4 bg-transparent">
                      Sélectionner des fichiers
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* APPARENCE */}
          <TabsContent value="appearance">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Palette className="h-5 w-5" />
                  Apparence et affichage
                </CardTitle>
                <CardDescription>Personnalisez l'apparence de votre interface</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label>Thème</Label>
                    <Select defaultValue="light">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="light">Clair</SelectItem>
                        <SelectItem value="dark">Sombre</SelectItem>
                        <SelectItem value="system">Système</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Langue</Label>
                    <Select defaultValue="fr">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="fr">Français</SelectItem>
                        <SelectItem value="en">English</SelectItem>
                        <SelectItem value="es">Español</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Fuseau horaire</Label>
                    <Select defaultValue="europe/paris">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="europe/paris">Europe/Paris</SelectItem>
                        <SelectItem value="europe/london">Europe/London</SelectItem>
                        <SelectItem value="america/new_york">America/New_York</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Format de date</Label>
                    <Select defaultValue="dd/mm/yyyy">
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="dd/mm/yyyy">DD/MM/YYYY</SelectItem>
                        <SelectItem value="mm/dd/yyyy">MM/DD/YYYY</SelectItem>
                        <SelectItem value="yyyy-mm-dd">YYYY-MM-DD</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <Separator />

                <div className="space-y-4">
                  <h4 className="font-medium">Couleurs du thème</h4>
                  <div className="grid grid-cols-4 gap-4">
                    <div className="space-y-2">
                      <Label className="text-sm">Primaire</Label>
                      <div className="w-full h-10 bg-blue-600 rounded border cursor-pointer"></div>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-sm">Secondaire</Label>
                      <div className="w-full h-10 bg-gray-600 rounded border cursor-pointer"></div>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-sm">Succès</Label>
                      <div className="w-full h-10 bg-green-600 rounded border cursor-pointer"></div>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-sm">Danger</Label>
                      <div className="w-full h-10 bg-red-600 rounded border cursor-pointer"></div>
                    </div>
                  </div>
                </div>

                <Button onClick={handleSave} disabled={loading} className="w-full">
                  {loading ? <RefreshCw className="h-4 w-4 animate-spin mr-2" /> : <Save className="h-4 w-4 mr-2" />}
                  Appliquer les modifications
                </Button>
              </CardContent>
            </Card>
          </TabsContent>

          {/* SYSTÈME */}
          <TabsContent value="system">
            <div className="space-y-6">
              {user?.role === "Directeur" && (
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Shield className="h-5 w-5" />
                      Paramètres système (Directeur)
                    </CardTitle>
                    <CardDescription>Configuration avancée réservée aux directeurs</CardDescription>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-2">
                      <Label>Nom de l'entreprise</Label>
                      <Input defaultValue="CRM Pro Assurances" />
                    </div>

                    <div className="space-y-2">
                      <Label>Logo de l'entreprise</Label>
                      <div className="flex items-center gap-4">
                        <div className="w-16 h-16 bg-gray-100 rounded border flex items-center justify-center">
                          <Building2 className="h-8 w-8 text-gray-400" />
                        </div>
                        <Button variant="outline">Changer le logo</Button>
                      </div>
                    </div>

                    <div className="space-y-2">
                      <Label>Signature d'entreprise</Label>
                      <Textarea placeholder="Signature automatique pour tous les emails de l'entreprise..." rows={4} />
                    </div>

                    <Separator />

                    <div className="space-y-4">
                      <h4 className="font-medium">Sauvegarde et maintenance</h4>
                      <div className="grid grid-cols-2 gap-4">
                        <Button variant="outline">
                          <Database className="h-4 w-4 mr-2" />
                          Sauvegarder la base
                        </Button>
                        <Button variant="outline">
                          <RefreshCw className="h-4 w-4 mr-2" />
                          Maintenance système
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              )}

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Globe className="h-5 w-5" />
                    Informations système
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <Label className="text-gray-600">Version</Label>
                      <p className="font-mono">v2.1.0</p>
                    </div>
                    <div>
                      <Label className="text-gray-600">Dernière mise à jour</Label>
                      <p>15 janvier 2024</p>
                    </div>
                    <div>
                      <Label className="text-gray-600">Base de données</Label>
                      <p>PostgreSQL 15.2</p>
                    </div>
                    <div>
                      <Label className="text-gray-600">Statut</Label>
                      <Badge variant="secondary" className="bg-green-100 text-green-800">
                        En ligne
                      </Badge>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </div>
          </TabsContent>
        </Tabs>
      </div>
    </AuthGuard>
  )
}
