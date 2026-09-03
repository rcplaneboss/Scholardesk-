export type TenantContext = { schoolId: string; slug: string; name: string };

async function lookupTenantBySlug(_slug: string): Promise<TenantContext | null> {
  // Typed server-side lookup seam; connect this to a scoped Supabase RPC once the schema exists.
  if (!_slug) return null;
  return null;
}

export async function resolveTenant(slug: string): Promise<TenantContext | null> {
  if (!slug || slug.length > 80 || !/^[a-z0-9-]+$/.test(slug)) return null;
  return lookupTenantBySlug(slug);
}