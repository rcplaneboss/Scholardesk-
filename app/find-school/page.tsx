"use client";

import Link from "next/link";
import { ArrowLeft, BookOpen, Search } from "lucide-react";
import { FormEvent, useState } from "react";

/**
 * Find school page component that allows users to search for their school by name or code.
 * @returns The find school page with search functionality
 */
export default function FindSchoolPage() {
  const [query, setQuery] = useState("");
  const [searched, setSearched] = useState(false);
  /**
   * Handles the search form submission and updates the searched state.
   * @param event - The form submission event
   */
  function handleSubmit(event: FormEvent<HTMLFormElement>) { event.preventDefault(); setSearched(Boolean(query.trim())); }
  return <main className="min-h-screen bg-paper px-6 py-10 sm:px-10"><div className="mx-auto max-w-2xl"><Link href="/" className="inline-flex items-center gap-2 text-sm font-semibold text-muted hover:text-navy"><ArrowLeft size={16} /> Back to home</Link><div className="py-20 text-center"><div className="mx-auto grid size-14 place-items-center rounded-2xl bg-navy text-gold"><BookOpen size={26} /></div><h1 className="mt-7 font-serif text-4xl font-semibold text-navy">Find your school</h1><p className="mx-auto mt-3 max-w-md text-muted">Enter your school&apos;s name or code to continue.</p><form onSubmit={handleSubmit} className="mx-auto mt-9 flex max-w-xl gap-2 rounded-xl border border-line bg-white p-2 shadow-[var(--shadow)]"><label className="sr-only" htmlFor="school-search">Search for your school</label><Search className="ml-3 mt-3.5 text-muted" size={18} /><input id="school-search" value={query} onChange={(event) => { setQuery(event.target.value); setSearched(false); }} placeholder="Search for your school..." className="min-w-0 flex-1 bg-transparent px-2 py-3 text-sm outline-none" /><button type="submit" className="rounded-lg bg-navy px-5 text-sm font-bold text-white hover:bg-navy-soft">Search</button></form>{searched && <div className="mt-8 rounded-xl border border-line bg-white p-6 text-left"><p className="font-semibold text-navy">No schools found</p><p className="mt-1 text-sm text-muted">Check the spelling or ask your school administrator for its code.</p></div>}<p className="mt-8 text-xs text-muted">For privacy, schools appear only after you search.</p></div></div></main>;
}