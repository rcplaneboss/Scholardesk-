import type { ModuleKey, ModuleState, PlatformMetric, PlatformSchool } from "./types";

export const moduleDetails: Record<ModuleKey, { label: string; description: string }> = {
  attendance: { label: "Attendance", description: "Attendance tracking and parent SMS notifications" },
  fees: { label: "Fees", description: "Fee management, payment recording, and overdue reminders" },
  results: { label: "Results", description: "Subjects, score entry, and report card generation" },
};

export const platformMetrics: PlatformMetric[] = [
  { label: "Total schools", value: "Unavailable", detail: "Requires platform schema" },
  { label: "Active subscriptions", value: "Unavailable", detail: "Requires platform schema" },
  { label: "Students across platform", value: "Unavailable", detail: "Requires roster data" },
  { label: "SMS sent, last 30 days", value: "Unavailable", detail: "Requires notification log" },
  { label: "Fee assignments", value: "Unavailable", detail: "Requires fee data" },
  { label: "Payments recorded", value: "Unavailable", detail: "Requires payment data" },
];

export async function listPlatformSchools(): Promise<PlatformSchool[]> {
  return [];
}

export async function updateSchoolModule(
  schoolId: string,
  module: ModuleKey,
  enabled: boolean,
): Promise<{ ok: false; message: string }> {
  if (!schoolId || !module || typeof enabled !== "boolean") {
    return { ok: false, message: "Invalid module configuration." };
  }
  return { ok: false, message: "Module configuration is unavailable until the school schema is connected." };
}

export function defaultModuleState(): ModuleState {
  return { attendance: true, fees: true, results: true };
}