import { DatabaseZap } from "lucide-react";

export function DataUnavailable({ title = "Platform data is not connected" }: { title?: string }) {
  return <div className="rounded-xl border border-gold/30 bg-gold-soft/40 p-6"><div className="flex gap-4"><div className="grid size-10 shrink-0 place-items-center rounded-lg bg-white text-gold shadow-sm"><DatabaseZap size={19} /></div><div><h2 className="font-serif text-xl font-semibold text-navy">{title}</h2><p className="mt-2 max-w-2xl text-sm leading-6 text-muted">This platform view is ready for Supabase-backed data, but the profile, schools, module, and notification schemas have not been connected yet. No placeholder counts or toggle changes are shown.</p></div></div></div>;
}