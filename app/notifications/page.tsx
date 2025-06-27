"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Bell, Check, Trash2, Eye, Clock, AlertCircle } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"
import { Sidebar } from "@/components/sidebar"

type Notification = Database["public"]["Tables"]["notifications"]["Row"]

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<"all" | "unread" | "read">("all")

  useEffect(() => {
    fetchNotifications()
  }, [filter])

  async function fetchNotifications() {
    try {
      let query = supabase.from("notifications").select("*").order("created_at", { ascending: false })

      if (filter === "unread") {
        query = query.eq("is_read", false)
      } else if (filter === "read") {
        query = query.eq("is_read", true)
      }

      const { data, error } = await query

      if (error) throw error
      setNotifications(data || [])
    } catch (error) {
      console.error("Error fetching notifications:", error)
    } finally {
      setLoading(false)
    }
  }

  async function markAsRead(id: string) {
    try {
      const { error } = await supabase.from("notifications").update({ is_read: true }).eq("id", id)

      if (error) throw error
      await fetchNotifications()
    } catch (error) {
      console.error("Error marking notification as read:", error)
    }
  }

  async function markAllAsRead() {
    try {
      const { error } = await supabase.from("notifications").update({ is_read: true }).eq("is_read", false)

      if (error) throw error
      await fetchNotifications()
    } catch (error) {
      console.error("Error marking all notifications as read:", error)
    }
  }

  async function deleteNotification(id: string) {
    try {
      const { error } = await supabase.from("notifications").delete().eq("id", id)

      if (error) throw error
      await fetchNotifications()
    } catch (error) {
      console.error("Error deleting notification:", error)
    }
  }

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "urgent":
        return "bg-red-100 text-red-800"
      case "high":
        return "bg-orange-100 text-orange-800"
      case "medium":
        return "bg-blue-100 text-blue-800"
      case "low":
        return "bg-gray-100 text-gray-800"
      default:
        return "bg-gray-100 text-gray-800"
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "contact_shared":
        return <Eye className="h-4 w-4" />
      case "prospect_converted":
        return <Check className="h-4 w-4" />
      case "email_received":
        return <Bell className="h-4 w-4" />
      default:
        return <AlertCircle className="h-4 w-4" />
    }
  }

  const unreadCount = notifications.filter((n) => !n.is_read).length

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-auto">
        <div className="p-8">
          <div className="flex justify-between items-start mb-8">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">Notifications</h1>
              <p className="text-gray-600">
                Centre de notifications - {unreadCount} non lue{unreadCount !== 1 ? "s" : ""}
              </p>
            </div>
            <div className="flex gap-2">
              <Button variant="outline" onClick={markAllAsRead} disabled={unreadCount === 0}>
                <Check className="h-4 w-4 mr-2" />
                Tout marquer comme lu
              </Button>
            </div>
          </div>

          {/* Filtres */}
          <div className="flex gap-2 mb-6">
            <Button
              variant={filter === "all" ? "default" : "outline"}
              onClick={() => setFilter("all")}
              className={filter === "all" ? "bg-purple-600 hover:bg-purple-700" : ""}
            >
              Toutes ({notifications.length})
            </Button>
            <Button
              variant={filter === "unread" ? "default" : "outline"}
              onClick={() => setFilter("unread")}
              className={filter === "unread" ? "bg-purple-600 hover:bg-purple-700" : ""}
            >
              Non lues ({unreadCount})
            </Button>
            <Button
              variant={filter === "read" ? "default" : "outline"}
              onClick={() => setFilter("read")}
              className={filter === "read" ? "bg-purple-600 hover:bg-purple-700" : ""}
            >
              Lues ({notifications.length - unreadCount})
            </Button>
          </div>

          {loading ? (
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-24 bg-gray-200 rounded animate-pulse"></div>
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {notifications.map((notification) => (
                <Card
                  key={notification.id}
                  className={`hover:shadow-lg transition-shadow ${
                    !notification.is_read ? "border-l-4 border-l-purple-500 bg-purple-50" : ""
                  }`}
                >
                  <CardHeader className="pb-3">
                    <div className="flex justify-between items-start">
                      <div className="flex items-start gap-3">
                        <div className="mt-1">{getTypeIcon(notification.type)}</div>
                        <div className="flex-1">
                          <CardTitle className="text-lg">{notification.title}</CardTitle>
                          <p className="text-gray-600 mt-1">{notification.message}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-2">
                        <Badge className={getPriorityColor(notification.priority)}>{notification.priority}</Badge>
                        {!notification.is_read && <div className="w-2 h-2 bg-purple-500 rounded-full"></div>}
                      </div>
                    </div>
                  </CardHeader>
                  <CardContent className="pt-0">
                    <div className="flex justify-between items-center">
                      <div className="flex items-center gap-2 text-sm text-gray-500">
                        <Clock className="h-4 w-4" />
                        <span>{new Date(notification.created_at).toLocaleString("fr-FR")}</span>
                      </div>
                      <div className="flex gap-2">
                        {!notification.is_read && (
                          <Button variant="outline" size="sm" onClick={() => markAsRead(notification.id)}>
                            <Check className="h-4 w-4" />
                          </Button>
                        )}
                        <Button variant="outline" size="sm" onClick={() => deleteNotification(notification.id)}>
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}

          {notifications.length === 0 && !loading && (
            <div className="text-center py-12">
              <Bell className="h-12 w-12 text-gray-400 mx-auto mb-4" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Aucune notification</h3>
              <p className="text-gray-600">Vous êtes à jour !</p>
            </div>
          )}
        </div>
      </main>
    </div>
  )
}
