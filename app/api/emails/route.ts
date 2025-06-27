import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const filter = searchParams.get("filter") || "all"
    const search = searchParams.get("search") || ""

    let query = supabase
      .from("emails")
      .select(`
        *,
        contacts:contact_id (
          first_name,
          last_name,
          client_code
        )
      `)
      .order("created_at", { ascending: false })

    if (filter === "sent") {
      query = query.eq("email_type", "outbound")
    } else if (filter === "received") {
      query = query.eq("email_type", "inbound")
    }

    if (search) {
      query = query.or(`subject.ilike.%${search}%,from_email.ilike.%${search}%,to_email.ilike.%${search}%`)
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

    const { data, error } = await supabase.from("emails").insert([body]).select().single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
