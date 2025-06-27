import { supabase } from "./supabase"
import type { Database } from "./supabase"

// Re-export supabase for use in other components
export { supabase }

export type User = {
  id: string
  email: string
  first_name?: string
  last_name?: string
  role?: string
  avatar_url?: string
}

export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) throw error
  return data
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export async function getCurrentUser(): Promise<User | null> {
  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) return null

  // Récupérer les informations du collaborateur
  const { data: collaborator } = await supabase.from("collaborators").select("*").eq("auth_user_id", user.id).single()

  return {
    id: user.id,
    email: user.email!,
    first_name: collaborator?.first_name,
    last_name: collaborator?.last_name,
    role: collaborator?.role,
    avatar_url: collaborator?.avatar_url,
  }
}

export async function getSession() {
  const {
    data: { session },
  } = await supabase.auth.getSession()
  return session
}