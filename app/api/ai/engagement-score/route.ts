import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const { contactId } = await request.json()

    // Récupérer les données du contact et ses interactions
    const [contactRes, interactionsRes] = await Promise.all([
      supabase.from("contacts").select("*").eq("id", contactId).single(),
      supabase
        .from("interactions")
        .select("*")
        .eq("contact_id", contactId)
        .order("created_at", { ascending: false })
        .limit(10),
    ])

    if (contactRes.error) throw contactRes.error

    const contact = contactRes.data
    const interactions = interactionsRes.data || []

    // Calcul du score d'engagement (logique simplifiée)
    let score = 50 // Score de base

    // Facteurs positifs
    if (interactions.length > 0) {
      const lastInteraction = new Date(interactions[0].created_at)
      const daysSinceLastInteraction = Math.floor((Date.now() - lastInteraction.getTime()) / (1000 * 60 * 60 * 24))

      if (daysSinceLastInteraction <= 7) score += 20
      else if (daysSinceLastInteraction <= 30) score += 10
      else score -= 10
    }

    // Nombre d'interactions
    if (interactions.length >= 5) score += 15
    else if (interactions.length >= 2) score += 10

    // Statut du contact
    if (contact.status === "client") score += 25
    else if (contact.status === "prospect") score += 15

    // Email et téléphone renseignés
    if (contact.email) score += 5
    if (contact.phone) score += 5

    // Limiter le score entre 0 et 100
    score = Math.max(0, Math.min(100, score))

    // Sauvegarder le score
    const { error: saveError } = await supabase.from("ai_engagement_scores").upsert(
      {
        contact_id: contactId,
        score,
        factors: {
          interactions_count: interactions.length,
          last_interaction_days:
            interactions.length > 0
              ? Math.floor((Date.now() - new Date(interactions[0].created_at).getTime()) / (1000 * 60 * 60 * 24))
              : null,
          status: contact.status,
          has_email: !!contact.email,
          has_phone: !!contact.phone,
        },
        prediction_confidence: 0.85,
        calculated_at: new Date().toISOString(),
      },
      { onConflict: "contact_id" },
    )

    if (saveError) throw saveError

    return NextResponse.json({ score, confidence: 0.85 })
  } catch (error) {
    console.error("Error calculating engagement score:", error)
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
