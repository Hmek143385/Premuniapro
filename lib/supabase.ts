import { createClient } from "@supabase/supabase-js"

// Configuration Supabase - Environment variables with fallbacks
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

// Validate that required environment variables are present
if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables. Please check your .env.local file.')
  console.error('Required variables: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY')
}

// Create Supabase client with proper error handling
export const supabase = supabaseUrl && supabaseAnonKey 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

export type Database = {
  public: {
    Tables: {
      user_roles: {
        Row: {
          id: string
          name: string
          description: string | null
          permissions: any
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          permissions?: any
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          permissions?: any
          created_at?: string
        }
      }
      collaborators: {
        Row: {
          id: string
          first_name: string
          last_name: string
          email: string
          phone: string | null
          password_hash: string
          role_id: string | null
          is_active: boolean
          hire_date: string | null
          commission_rate: number
          manager_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          first_name: string
          last_name: string
          email: string
          phone?: string | null
          password_hash: string
          role_id?: string | null
          is_active?: boolean
          hire_date?: string | null
          commission_rate?: number
          manager_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          first_name?: string
          last_name?: string
          email?: string
          phone?: string | null
          password_hash?: string
          role_id?: string | null
          is_active?: boolean
          hire_date?: string | null
          commission_rate?: number
          manager_id?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      contacts: {
        Row: {
          id: string
          client_code: string
          first_name: string
          last_name: string
          email: string | null
          phone: string | null
          birth_date: string | null
          gender: string | null
          address: string | null
          postal_code: string | null
          city: string | null
          country: string
          source: string | null
          status: string
          regime: string | null
          commercial_id: string | null
          assigned_to: string | null
          ai_engagement_score: number
          last_interaction_date: string | null
          conversion_probability: number
          lifetime_value: number
          notes: string | null
          tags: string[] | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          client_code: string
          first_name: string
          last_name: string
          email?: string | null
          phone?: string | null
          birth_date?: string | null
          gender?: string | null
          address?: string | null
          postal_code?: string | null
          city?: string | null
          country?: string
          source?: string | null
          status?: string
          regime?: string | null
          commercial_id?: string | null
          assigned_to?: string | null
          ai_engagement_score?: number
          last_interaction_date?: string | null
          conversion_probability?: number
          lifetime_value?: number
          notes?: string | null
          tags?: string[] | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          client_code?: string
          first_name?: string
          last_name?: string
          email?: string | null
          phone?: string | null
          birth_date?: string | null
          gender?: string | null
          address?: string | null
          postal_code?: string | null
          city?: string | null
          country?: string
          source?: string | null
          status?: string
          regime?: string | null
          commercial_id?: string | null
          assigned_to?: string | null
          ai_engagement_score?: number
          last_interaction_date?: string | null
          conversion_probability?: number
          lifetime_value?: number
          notes?: string | null
          tags?: string[] | null
          created_at?: string
          updated_at?: string
        }
      }
      contact_shares: {
        Row: {
          id: string
          contact_id: string
          shared_by: string | null
          shared_with: string | null
          permission_level: string
          message: string | null
          expires_at: string | null
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          contact_id: string
          shared_by?: string | null
          shared_with?: string | null
          permission_level?: string
          message?: string | null
          expires_at?: string | null
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          contact_id?: string
          shared_by?: string | null
          shared_with?: string | null
          permission_level?: string
          message?: string | null
          expires_at?: string | null
          is_active?: boolean
          created_at?: string
        }
      }
      emails: {
        Row: {
          id: string
          contact_id: string | null
          collaborator_id: string | null
          email_account_id: string | null
          from_email: string
          to_email: string
          cc_emails: string[] | null
          bcc_emails: string[] | null
          subject: string | null
          body: string | null
          html_body: string | null
          email_type: string
          status: string
          thread_id: string | null
          message_id: string | null
          in_reply_to: string | null
          attachments: any
          tracking_data: any
          sent_at: string | null
          delivered_at: string | null
          opened_at: string | null
          clicked_at: string | null
          created_at: string
        }
        Insert: {
          id?: string
          contact_id?: string | null
          collaborator_id?: string | null
          email_account_id?: string | null
          from_email: string
          to_email: string
          cc_emails?: string[] | null
          bcc_emails?: string[] | null
          subject?: string | null
          body?: string | null
          html_body?: string | null
          email_type?: string
          status?: string
          thread_id?: string | null
          message_id?: string | null
          in_reply_to?: string | null
          attachments?: any
          tracking_data?: any
          sent_at?: string | null
          delivered_at?: string | null
          opened_at?: string | null
          clicked_at?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          contact_id?: string | null
          collaborator_id?: string | null
          email_account_id?: string | null
          from_email?: string
          to_email?: string
          cc_emails?: string[] | null
          bcc_emails?: string[] | null
          subject?: string | null
          body?: string | null
          html_body?: string | null
          email_type?: string
          status?: string
          thread_id?: string | null
          message_id?: string | null
          in_reply_to?: string | null
          attachments?: any
          tracking_data?: any
          sent_at?: string | null
          delivered_at?: string | null
          opened_at?: string | null
          clicked_at?: string | null
          created_at?: string
        }
      }
    }
  }
}