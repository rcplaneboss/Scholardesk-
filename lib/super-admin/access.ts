import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";

export type SuperAdminAccess =
  | { status: "unauthenticated" }
  | { status: "forbidden" }
  | { status: "unavailable"; userId: string }
  | { status: "authorized"; userId: string };

export async function getSuperAdminAccess(): Promise<SuperAdminAccess> {
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { status: "unauthenticated" };
  const { data: profile, error } = await supabase.from("profiles").select("role").eq("id", user.id).maybeSingle();
  if (error) return { status: "unavailable", userId: user.id };
  if (!profile || profile.role !== "super_admin") return { status: "forbidden" };
  return { status: "authorized", userId: user.id };
}

export function enforceSuperAdminAccess(access: SuperAdminAccess) {
  if (access.status === "unauthenticated") redirect("/login?next=/super-admin");
  if (access.status === "forbidden") redirect("/find-school?error=platform-access");
}