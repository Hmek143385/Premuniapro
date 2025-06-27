import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function GET(request: NextRequest) {
  try {
    const [
      { count: totalContacts },
      { count: newLeads },
      { count: clientsGagnes },
      { data: contractsData },
      { count: totalCollaborators },
      { count: totalProducts },
    ] = await Promise.all([
      supabase.from("contacts").select("*", { count: "exact", head: true }),
      supabase.from("contacts").select("*", { count: "exact", head: true }).eq("status", "lead"),
      supabase.from("contacts").select("*", { count: "exact", head: true }).eq("status", "client"),
      supabase.from("contracts").select("received_commission"),
      supabase.from("collaborators").select("*", { count: "exact", head: true }),
      supabase.from("insurance_products").select("*", { count: "exact", head: true }),
    ])

    const totalCommissions = contractsData?.reduce((sum, contract) => sum + (contract.received_commission || 0), 0) || 0

    const tauxConversion =
      totalContacts && totalContacts > 0 ? Math.round(((clientsGagnes || 0) / totalContacts) * 100) : 0

    return NextResponse.json({
      totalContacts: totalContacts || 0,
      newLeads: newLeads || 0,
      clientsGagnes: clientsGagnes || 0,
      tauxConversion,
      totalCommissions,
      totalCollaborators: totalCollaborators || 0,
      totalProducts: totalProducts || 0,
    })
  } catch (error) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
