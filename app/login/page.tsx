import Link from "next/link";
import { redirect } from "next/navigation";
import { ArrowLeft, BookOpen, Eye, LockKeyhole } from "lucide-react";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { resolveUserDestination } from "@/lib/auth";

/**
 * Server action that handles user sign-in with email and password.
 * @param formData - Form data containing email and password fields
 */
async function signIn(formData: FormData) {
  "use server";
  const email = String(formData.get("email") ?? "");
  const password = String(formData.get("password") ?? "");
  const supabase = await createSupabaseServerClient();
  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error) redirect(`/login?error=${encodeURIComponent(error.message)}`);
  const destination = await resolveUserDestination(supabase, data.user.id);
  redirect(destination ?? "/login?error=account-setup");
}

/**
 * Login page component that displays the sign-in form and handles user authentication.
 * @returns The login page with email/password form and branding
 */
export default function LoginPage() {
  return <main className="grid min-h-screen bg-paper lg:grid-cols-2"><section className="flex items-center justify-center px-6 py-12 sm:px-12"><div className="w-full max-w-md"><Link href="/" className="mb-14 inline-flex items-center gap-2 text-sm font-semibold text-muted hover:text-navy"><ArrowLeft size={16} /> Back to home</Link><div className="mb-10 flex items-center gap-3"><div className="grid size-11 place-items-center rounded-xl bg-navy text-gold"><BookOpen size={22} /></div><span className="font-serif text-xl font-semibold text-navy">Scholar<span className="text-gold">Desk</span></span></div><h1 className="font-serif text-4xl font-semibold text-navy">Sign in to your account</h1><p className="mt-3 text-muted">Access your school portal securely.</p><form action={signIn} className="mt-9 space-y-5"><label className="block text-sm font-semibold text-navy" htmlFor="email">Email address<input id="email" name="email" type="email" placeholder="you@example.com" className="mt-2 w-full rounded-lg border border-line bg-white px-4 py-3 text-sm outline-none placeholder:text-muted/60 focus:border-gold" required /></label><label className="block text-sm font-semibold text-navy" htmlFor="password">Password<div className="relative mt-2"><input id="password" name="password" type="password" placeholder="Enter your password" className="w-full rounded-lg border border-line bg-white px-4 py-3 pr-11 text-sm outline-none placeholder:text-muted/60 focus:border-gold" required /><Eye className="absolute right-4 top-3.5 text-muted" size={17} /></div></label><div className="flex justify-end"><Link href="/reset-password" className="text-xs font-bold text-navy hover:text-gold">Forgot password?</Link></div><button type="submit" className="w-full rounded-lg bg-navy px-4 py-3.5 text-sm font-bold text-white hover:bg-navy-soft">Sign in</button></form><p className="mt-8 text-center text-xs text-muted">Need access? Contact your school administrator.</p></div></section><section className="relative hidden overflow-hidden bg-navy lg:flex lg:items-end"><div className="absolute inset-0 bg-[radial-gradient(circle_at_70%_20%,rgb(212_175_55_/_22%),transparent_35%)]" /><div className="relative max-w-lg p-16 text-white"><LockKeyhole className="mb-8 text-gold" size={34} /><h2 className="font-serif text-5xl leading-tight">Your school, in one clear view.</h2><p className="mt-6 text-lg leading-8 text-white/70">Keep the important work close, connected, and ready for the day ahead.</p></div></section></main>;
}