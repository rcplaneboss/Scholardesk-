export type TenantContext = { schoolId: string; slug: string; name: string };

export async function resolveTenant(slug: string): Promise<TenantContext | null> {
  if (!slug || slug.length > 80 || !/^[a-z0-9-]+$/.test(slug)) return null;
  return null;
}