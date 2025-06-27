import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const page = Number.parseInt(searchParams.get("page") || "1")
    const limit = Number.parseInt(searchParams.get("limit") || "10")
    const search = searchParams.get("search") || ""

    let query = supabase
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

    if (search) {
      query = query.or(`contract_number.ilike.%${search}%,full_name.ilike.%${search}%`)
    }

    const { data, error, count } = await query.range((page - 1) * limit, page * limit - 1).limit(limit)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 })
    }

    return NextResponse.json({
      data,
      pagination: {
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit),
      },
    })
  } catch (error) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    const { data, error } = await supabase.from("contracts").insert([body]).select().single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
