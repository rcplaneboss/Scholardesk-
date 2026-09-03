import type { ReactNode } from "react";
import { enforceSuperAdminAccess, getSuperAdminAccess } from "@/lib/super-admin/access";
import { SuperAdminSidebar } from "@/components/super-admin/sidebar";

/**
 * Super admin layout component that wraps super admin pages with authentication checks and sidebar navigation.
 * @param children - The page content to render within the layout
 * @returns The super admin layout with sidebar and protected content
 */
export default async function SuperAdminLayout({ children }: { children: ReactNode }) {
  const access = await getSuperAdminAccess();
  enforceSuperAdminAccess(access);
  return <div className="flex min-h-screen bg-paper"><SuperAdminSidebar /><div className="min-w-0 flex-1">{children}</div></div>;
}