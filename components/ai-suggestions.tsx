"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Sparkles, TrendingUp, Target, MessageSquare, CheckCircle, X } from "lucide-react"
import { supabase, type Database } from "@/lib/supabase"

type AISuggestion = Database["public"]["Tables"]["ai_suggestions"]["Row"]

interface AISuggestionsProps {
  contactId: string
}

export function AISuggestions({ contactId }: AISuggestionsProps) {
  const [suggestions, setSuggestions] = useState<AISuggestion[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchSuggestions()
  }, [contactId])

  async function fetchSuggestions() {
    try {
      const { data, error } = await supabase
        .from("ai_suggestions")
        .select("*")
        .eq("contact_id", contactId)
        .eq("status", "pending")
        .order("confidence_score", { ascending: false })

      if (error) throw error
      setSuggestions(data || [])
    } catch (error) {
      console.error("Error fetching AI suggestions:", error)
    } finally {
      setLoading(false)
    }
  }

  async function handleSuggestionAction(suggestionId: string, action: "accepted" | "rejected") {
    try {
      const { error } = await supabase.from("ai_suggestions").update({ status: action }).eq("id", suggestionId)

      if (error) throw error
      await fetchSuggestions()
    } catch (error) {
      console.error("Error updating suggestion:", error)
    }
  }

  const getTypeIcon = (type: string) => {
    switch (type) {
      case "cross_sell":
        return <Target className="h-4 w-4" />
      case "follow_up":
        return <MessageSquare className="h-4 w-4" />
      case "action":
        return <TrendingUp className="h-4 w-4" />
      default:
        return <Sparkles className="h-4 w-4" />
    }
  }

  const getConfidenceColor = (confidence: number) => {
    if (confidence >= 0.8) return "bg-green-100 text-green-800"
    if (confidence >= 0.6) return "bg-yellow-100 text-yellow-800"
    return "bg-red-100 text-red-800"
  }

  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Sparkles className="h-5 w-5 text-purple-600" />
            Suggestions IA
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="animate-pulse space-y-3">
            <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Sparkles className="h-5 w-5 text-purple-600" />
          Suggestions IA ({suggestions.length})
        </CardTitle>
      </CardHeader>
      <CardContent>
        {suggestions.length === 0 ? (
          <p className="text-gray-600 text-center py-4">Aucune suggestion disponible</p>
        ) : (
          <div className="space-y-4">
            {suggestions.map((suggestion) => (
              <div key={suggestion.id} className="border rounded-lg p-4 space-y-3">
                <div className="flex items-start justify-between">
                  <div className="flex items-center gap-2">
                    {getTypeIcon(suggestion.suggestion_type)}
                    <h4 className="font-medium">{suggestion.title}</h4>
                  </div>
                  <Badge className={getConfidenceColor(suggestion.confidence_score)}>
                    {Math.round(suggestion.confidence_score * 100)}% confiance
                  </Badge>
                </div>
                <p className="text-gray-600 text-sm">{suggestion.description}</p>
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    onClick={() => handleSuggestionAction(suggestion.id, "accepted")}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    <CheckCircle className="h-4 w-4 mr-1" />
                    Accepter
                  </Button>
                  <Button size="sm" variant="outline" onClick={() => handleSuggestionAction(suggestion.id, "rejected")}>
                    <X className="h-4 w-4 mr-1" />
                    Rejeter
                  </Button>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}
