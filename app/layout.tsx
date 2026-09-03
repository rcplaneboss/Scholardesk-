import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";
import { Lora, Plus_Jakarta_Sans } from "next/font/google";

const jakarta = Plus_Jakarta_Sans({ subsets: ["latin"], variable: "--font-jakarta" });
const lora = Lora({ subsets: ["latin"], variable: "--font-lora" });

export const metadata: Metadata = {
  title: "ScholarDesk | School management made simple",
  description: "A secure school management workspace for Nigerian schools.",
};

/**
 * Root layout component that wraps all pages with global styles and font configuration.
 * @param children - The page content to render
 * @returns The HTML structure with configured fonts and global styles
 */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" dir="ltr">
      <body className={`${jakarta.variable} ${lora.variable}`}>{children}</body>
    </html>
  );
}
