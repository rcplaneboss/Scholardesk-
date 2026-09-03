"use client";

import { LockKeyhole } from "lucide-react";
import type { ModuleKey } from "@/lib/super-admin/types";
import { moduleDetails } from "@/lib/super-admin/data";

export function ModuleToggle({ module, enabled }: { module: ModuleKey; enabled: boolean }) {
  const detail = moduleDetails[module];
  return <div className="flex items-center justify-between gap-5 border-t border-line py-5 first:border-t-0 first:pt-0 last:pb-0"><div><p className="font-bold text-navy">{detail.label} module</p><p className="mt-1 max-w-xl text-sm leading-6 text-muted">{detail.description}</p></div><button type="button" disabled aria-label={`${detail.label} module ${enabled ? "enabled" : "disabled"}`} className="relative h-7 w-12 shrink-0 cursor-not-allowed rounded-full bg-gray-200 opacity-70"><span className={`absolute top-1 size-5 rounded-full bg-white shadow-sm ${enabled ? "left-6" : "left-1"}`} /><LockKeyhole className="absolute -right-6 text-muted/60" size={13} /></button></div>;
}