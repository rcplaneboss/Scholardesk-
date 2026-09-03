export type ModuleKey = "attendance" | "fees" | "results";

export type ModuleState = Record<ModuleKey, boolean>;

export type PlatformSchool = {
  id: string;
  name: string;
  subscriptionStatus: string;
  trialEndsAt: string | null;
  isActive: boolean;
  modules: ModuleState;
};

export type PlatformMetric = {
  label: string;
  value: string;
  detail: string;
};

export type DataAvailability = {
  available: boolean;
  message: string;
};