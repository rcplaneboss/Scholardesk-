import { redirect } from "next/navigation";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { resolveTenant } from "@/lib/tenant";

export default async function TenantPage({ params }: { params: Promise<{ "school-slug": string }> }) {
  const { "school-slug": slug } = await params;
  const tenant = await resolveTenant(slug);
  if (!tenant) redirect("/find-school");
  const supabase = await createSupabaseServerClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect(`/login?next=/${slug}`);
  redirect("/find-school?message=tenant-setup");
}