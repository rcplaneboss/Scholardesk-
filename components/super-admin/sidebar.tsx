"use client";

import Link from "next/link";
import { BarChart3, Building2, CircleHelp, LayoutDashboard, Menu, X } from "lucide-react";
import { useState } from "react";

const links = [{ href: "/super-admin", label: "Overview", icon: LayoutDashboard }, { href: "/super-admin/schools", label: "Schools", icon: Building2 }, { href: "/super-admin/sms-analytics", label: "SMS analytics", icon: BarChart3 }];

export function SuperAdminSidebar() {
  const [open, setOpen] = useState(false);
  return <><button type="button" aria-label="Open platform navigation" onClick={() => setOpen(true)} className="fixed right-5 top-5 z-20 grid size-11 place-items-center rounded-lg border border-line bg-white text-navy shadow-sm lg:hidden"><Menu size={19} /></button><aside className={`fixed inset-y-0 left-0 z-30 w-72 bg-navy px-6 py-7 text-white transition-transform lg:static lg:block lg:w-64 lg:translate-x-0 ${open ? "translate-x-0" : "-translate-x-full"}`}><div className="flex items-center justify-between"><Link href="/super-admin" className="font-serif text-xl font-semibold">Scholar<span className="text-gold">Desk</span></Link><button type="button" aria-label="Close platform navigation" onClick={() => setOpen(false)} className="text-white/70 lg:hidden"><X size={19} /></button></div><p className="mt-2 text-xs font-bold uppercase tracking-[.16em] text-gold">Platform control</p><nav className="mt-12 space-y-2">{links.map(({ href, label, icon: Icon }) => <Link key={href} href={href} onClick={() => setOpen(false)} className="flex items-center gap-3 rounded-lg px-3 py-3 text-sm font-semibold text-white/70 hover:bg-white/10 hover:text-white"><Icon size={18} />{label}</Link>)}</nav><div className="mt-auto pt-12"><Link href="/super-admin?tour=1" className="flex items-center gap-3 rounded-lg px-3 py-3 text-sm font-semibold text-white/70 hover:bg-white/10 hover:text-white"><CircleHelp size={18} />Help and onboarding</Link></div></aside>{open && <button type="button" aria-label="Close navigation overlay" onClick={() => setOpen(false)} className="fixed inset-0 z-20 bg-navy/30 lg:hidden" />}</>;
}