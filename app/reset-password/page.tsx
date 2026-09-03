import Link from "next/link";
import { redirect } from "next/navigation";
import { ArrowLeft, BookOpen } from "lucide-react";
import { createSupabaseServerClient } from "@/lib/supabase/server";

async function sendRecoveryEmail(formData: FormData) {
  "use server";
  const email = String(formData.get("email") ?? "");
  const supabase = await createSupabaseServerClient();
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"}/reset-password`,
  });
  redirect(error ? `/reset-password?error=${encodeURIComponent(error.message)}` : "/reset-password?sent=1");
}

export default async function ResetPasswordPage({ searchParams }: { searchParams: Promise<{ error?: string; sent?: string }> }) {
  const params = await searchParams;
  return <main className="min-h-screen bg-paper px-6 py-10 sm:px-10"><div className="mx-auto max-w-md"><Link href="/login" className="inline-flex items-center gap-2 text-sm font-semibold text-muted hover:text-navy"><ArrowLeft size={16} /> Back to sign in</Link><div className="mt-20 rounded-2xl border border-line bg-white p-7 shadow-[var(--shadow)] sm:p-9"><div className="grid size-12 place-items-center rounded-xl bg-navy text-gold"><BookOpen size={23} /></div><h1 className="mt-7 font-serif text-3xl font-semibold text-navy">Reset your password</h1><p className="mt-3 text-sm leading-6 text-muted">Enter your account email and we&apos;ll send a secure recovery link.</p>{params.sent ? <p className="mt-6 rounded-lg bg-success-soft p-4 text-sm font-semibold text-success">Check your inbox for the recovery link.</p> : <form action={sendRecoveryEmail} className="mt-7 space-y-5"><label className="block text-sm font-semibold text-navy" htmlFor="recovery-email">Email address<input id="recovery-email" name="email" type="email" placeholder="you@example.com" className="mt-2 w-full rounded-lg border border-line bg-paper px-4 py-3 text-sm outline-none placeholder:text-muted/60 focus:border-gold" required /></label>{params.error && <p className="rounded-lg bg-danger-soft p-3 text-sm text-danger">{params.error}</p>}<button type="submit" className="w-full rounded-lg bg-navy px-4 py-3.5 text-sm font-bold text-white hover:bg-navy-soft">Send recovery link</button></form>}</div></div></main>;
}