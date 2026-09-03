import type { SupabaseClient } from "@supabase/supabase-js";

export type UserDestination = `/${string}`;

export async function resolveUserDestination(
  supabase: SupabaseClient,
  userId: string,
): Promise<UserDestination | null> {
  if (!supabase || !userId) return null;
  return null;
}