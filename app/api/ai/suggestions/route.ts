import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const { contactId } = await request.json()

    // Récupérer les données du contact
    const { data: contact, error: contactError } = await supabase
      .from("contacts")
      .select("*")
      .eq("id", contactId)
      .single()

    if (contactError) throw contactError

    // Générer des suggestions basées sur le profil du contact
    const suggestions = []

    // Suggestion de suivi si pas d'interaction récente
    const { data: recentInteractions } = await supabase
      .from("interactions")
      .select("*")
      .eq("contact_id", contactId)
      .gte("created_at", new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString())

    if (!recentInteractions || recentInteractions.length === 0) {
      suggestions.push({
        contact_id: contactId,
        suggestion_type: "follow_up",
        title: "Relance recommandée",
        description: "Ce contact n'a pas eu d'interaction récente. Une relance pourrait être bénéfique.",
        confidence_score: 0.8,
        priority: "medium",
      })
    }

    // Suggestion de cross-sell pour les clients
    if (contact.status === "client") {
      const { data: contracts } = await supabase.from("contracts").select("*").eq("contact_id", contactId)

      if (contracts && contracts.length === 1) {
        suggestions.push({
          contact_id: contactId,
          suggestion_type: "cross_sell",
          title: "Opportunité de vente croisée",
          description: "Ce client n'a qu'un seul contrat. Proposez-lui des produits complémentaires.",
          confidence_score: 0.75,
          priority: "high",
        })
      }
    }

    // Suggestion d'action pour les prospects
    if (contact.status === "prospect") {
      suggestions.push({
        contact_id: contactId,
        suggestion_type: "action",
        title: "Proposition commerciale",
        description: "Ce prospect semble prêt pour une proposition commerciale personnalisée.",
        confidence_score: 0.7,
        priority: "medium",
      })
    }

    // Sauvegarder les suggestions
    if (suggestions.length > 0) {
      const { error: saveError } = await supabase.from("ai_suggestions").insert(suggestions)
      if (saveError) throw saveError
    }

    return NextResponse.json({ suggestions })
  } catch (error) {
    console.error("Error generating AI suggestions:", error)
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
