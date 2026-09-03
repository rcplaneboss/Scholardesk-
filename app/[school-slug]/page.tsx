import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { resolveTenant } from "@/lib/tenant";

/**
 * Tenant page component that resolves a school by slug and redirects authenticated users appropriately.
 * @param params - Route parameters containing the school slug
 * @returns Redirects to appropriate destination based on tenant and auth status
 */
export default async function TenantPage({ params }: { params: Promise<{ "school-slug": string }> }) {
  const { "school-slug": slug } = await params;
  const tenant = await resolveTenant(slug);
  if (!tenant) redirect("/find-school");
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect(`/login?next=/${slug}`);
  redirect(`/find-school?message=tenant-setup&school=${encodeURIComponent(tenant.name)}`);
}