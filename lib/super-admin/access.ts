import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type SuperAdminAccess =
  | { status: "unauthenticated" }
  | { status: "forbidden" }
  | { status: "unavailable"; userId: string }
  | { status: "authorized"; userId: string };

/**
 * Checks the current user's super admin access status.
 * @returns The access status object indicating authentication and authorization level
 */
export async function getSuperAdminAccess(): Promise<SuperAdminAccess> {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { status: "unauthenticated" };
  const { data: profile, error } = await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle();
  if (error) return { status: "unavailable", userId: user.id };
  if (!profile || profile.role !== "super_admin") return { status: "forbidden" };
  return { status: "authorized", userId: user.id };
}

/**
 * Enforces super admin access by redirecting users without proper authorization.
 * @param access - The access status to enforce
 */
export function enforceSuperAdminAccess(access: SuperAdminAccess) {
  if (access.status === "unauthenticated") redirect("/login?next=/super-admin");
  if (access.status === "forbidden") redirect("/find-school?error=platform-access");
}