import Link from "next/link";
import { ArrowLeft, ShieldCheck } from "lucide-react";
import { DataUnavailable } from "@/components/super-admin/unavailable";
import { ModuleToggle } from "@/components/super-admin/module-toggle";
import { defaultModuleState } from "@/lib/super-admin/data";

export default function SchoolDetailPage({ params }: { params: Promise<{ "school-id": string }> }) {
  return <SchoolDetail params={params} />;
}

async function SchoolDetail({ params }: { params: Promise<{ "school-id": string }> }) {
  const { "school-id": schoolId } = await params;
  return <main className="mx-auto max-w-5xl px-6 py-8 sm:px-10 lg:px-12"><Link href="/super-admin/schools" className="inline-flex items-center gap-2 text-sm font-semibold text-muted hover:text-navy"><ArrowLeft size={16} /> Back to schools</Link><header className="mt-10"><p className="text-sm font-bold uppercase tracking-[.16em] text-gold">School detail</p><h1 className="mt-2 font-serif text-4xl font-semibold text-navy">School configuration</h1><p className="mt-3 text-muted">Tenant reference: {schoolId}</p></header><div className="mt-8"><DataUnavailable title="School details are not connected" /></div><section className="mt-8 rounded-xl border border-line bg-white p-6 shadow-[var(--shadow)] sm:p-8"><div className="flex items-start gap-4"><div className="grid size-11 place-items-center rounded-lg bg-gold-soft text-navy"><ShieldCheck size={20} /></div><div><h2 className="font-serif text-2xl font-semibold text-navy">Module access</h2><p className="mt-2 text-sm leading-6 text-muted">These controls are intentionally read-only until a server-side school and audit repository is connected.</p></div></div><div className="mt-8">{Object.entries(defaultModuleState()).map(([module, enabled]) => <ModuleToggle key={module} module={module as "attendance" | "fees" | "results"} enabled={enabled} />)}</div></section><section className="mt-5 rounded-xl border border-line bg-white p-6 shadow-[var(--shadow)]"><h2 className="font-serif text-2xl font-semibold text-navy">School administrators</h2><p className="mt-2 text-sm text-muted">Administrator accounts will appear here after the profiles and invitations schema is connected.</p></section></main>;
}