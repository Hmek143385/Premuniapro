import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const filter = searchParams.get("filter") || "all"
    const collaboratorId = searchParams.get("collaborator_id") || "00000000-0000-0000-0000-000000000001"

    let query = supabase
      .from("notifications")
      .select("*")
      .eq("collaborator_id", collaboratorId)
      .order("created_at", { ascending: false })

    if (filter === "unread") {
      query = query.eq("is_read", false)
    } else if (filter === "read") {
      query = query.eq("is_read", true)
    }

    const { data, error } = await query

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 })
    }

    return NextResponse.json(data)
  } catch (error) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    const { data, error } = await supabase.from("notifications").insert([body]).select().single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
