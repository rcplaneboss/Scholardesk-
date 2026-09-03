import Link from "next/link";
import { ArrowRight, BookOpen } from "lucide-react";

/**
 * Home page component that displays the landing page with ScholarDesk branding and navigation options.
 * @returns The home page with sign-in and find school links
 */
export default function Home() {
  return <main className="grid min-h-screen place-items-center bg-paper px-6 py-10"><div className="w-full max-w-lg text-center"><div className="mx-auto grid size-14 place-items-center rounded-2xl bg-navy text-gold"><BookOpen size={28} /></div><h1 className="mt-7 font-serif text-5xl font-semibold text-navy">Scholar<span className="text-gold">Desk</span></h1><p className="mt-4 text-muted">Secure school attendance, fees, results, and parent notifications in one workspace.</p><div className="mt-9 flex flex-col justify-center gap-3 sm:flex-row"><Link href="/login" className="inline-flex items-center justify-center gap-2 rounded-lg bg-navy px-6 py-3.5 text-sm font-bold text-white hover:bg-navy-soft">Sign in <ArrowRight size={16} /></Link><Link href="/find-school" className="rounded-lg border border-line bg-white px-6 py-3.5 text-sm font-bold text-navy hover:border-gold">Find your school</Link></div></div></main>;
}
