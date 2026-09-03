export type TenantContext = { schoolId: string; slug: string; name: string };

/**
 * Looks up tenant information by school slug.
 * @param _slug - The school slug to look up
 * @returns The tenant context or null if not found
 */
async function lookupTenantBySlug(_slug: string): Promise<TenantContext | null> {
  if (!_slug) return null;
  return null;
}

/**
 * Resolves and validates a tenant by slug, ensuring it meets format requirements.
 * @param slug - The school slug to resolve (must be lowercase alphanumeric with hyphens, max 80 chars)
 * @returns The tenant context or null if validation fails or tenant not found
 */
export async function resolveTenant(slug: string): Promise<TenantContext | null> {
  if (!slug || slug.length > 80 || !/^[a-z0-9-]+$/.test(slug)) return null;
  return lookupTenantBySlug(slug);
}