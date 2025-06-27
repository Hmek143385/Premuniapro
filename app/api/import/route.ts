import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const formData = await request.formData()
    const file = formData.get("file") as File
    const importType = formData.get("type") as string

    if (!file) {
      return NextResponse.json({ error: "No file provided" }, { status: 400 })
    }

    // Créer un enregistrement d'import
    const { data: importRecord, error: importError } = await supabase
      .from("data_imports")
      .insert([
        {
          collaborator_id: "00000000-0000-0000-0000-000000000001",
          import_type: importType || "csv",
          file_name: file.name,
          status: "processing",
        },
      ])
      .select()
      .single()

    if (importError) throw importError

    // Simulation du traitement du fichier
    // Dans un vrai projet, vous analyseriez le contenu du fichier ici
    const fileContent = await file.text()
    const lines = fileContent.split("\n").filter((line) => line.trim())
    const headers = lines[0]?.split(",") || []
    const dataLines = lines.slice(1)

    let successCount = 0
    let failCount = 0
    const errors: string[] = []

    // Simulation du traitement ligne par ligne
    for (let i = 0; i < dataLines.length; i++) {
      const line = dataLines[i]
      const values = line.split(",")

      try {
        // Validation basique
        if (values.length < 3) {
          throw new Error("Données insuffisantes")
        }

        // Simulation d'insertion en base
        // Dans un vrai projet, vous inséreriez les données ici
        successCount++
      } catch (error) {
        failCount++
        errors.push(`Ligne ${i + 2}: ${error instanceof Error ? error.message : "Erreur inconnue"}`)
      }
    }

    // Mettre à jour l'enregistrement d'import
    await supabase
      .from("data_imports")
      .update({
        status: "completed",
        total_records: dataLines.length,
        successful_records: successCount,
        failed_records: failCount,
        error_log: errors.join("\n"),
        completed_at: new Date().toISOString(),
      })
      .eq("id", importRecord.id)

    return NextResponse.json({
      importId: importRecord.id,
      total: dataLines.length,
      success: successCount,
      failed: failCount,
      errors: errors.slice(0, 10), // Limiter à 10 erreurs pour l'affichage
    })
  } catch (error) {
    console.error("Import error:", error)
    return NextResponse.json({ error: "Internal server error" }, { status: 500 })
  }
}
