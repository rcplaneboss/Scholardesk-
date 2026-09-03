import type { Metadata } from "next";
import "./globals.css";
import { Lora, Plus_Jakarta_Sans } from "next/font/google";

const jakarta = Plus_Jakarta_Sans({ subsets: ["latin"], variable: "--font-jakarta" });
const lora = Lora({ subsets: ["latin"], variable: "--font-lora" });

export const metadata: Metadata = {
  title: "ScholarDesk | School management made simple",
  description: "A secure school management workspace for Nigerian schools.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" dir="ltr">
      <body className={`${jakarta.variable} ${lora.variable}`}>{children}</body>
    </html>
  );
}
