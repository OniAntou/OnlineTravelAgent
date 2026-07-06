const isTest = process.env.NODE_ENV === "test" || process.env.VITEST === "true";

function readPort(): number {
  const port = Number.parseInt(process.env.PORT ?? "3000", 10);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error("PORT must be a valid TCP port");
  }
  return port;
}

function requireEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (value) return value;

  if (isTest) {
    return `test-${name.toLowerCase()}`;
  }

  throw new Error(`${name} environment variable is required`);
}

function readCorsOrigins(): string[] {
  const raw = process.env.CORS_ORIGINS?.trim();
  if (!raw) {
    if (process.env.NODE_ENV === "production") {
      throw new Error("CORS_ORIGINS environment variable is required in production");
    }

    return ["http://localhost:3000", "http://10.0.2.2:3000", "http://localhost:5173"];
  }

  const origins = raw
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);

  if (!origins.length) {
    throw new Error("CORS_ORIGINS must contain at least one origin");
  }

  return origins;
}

function readTrustProxy(): boolean | number | string {
  const raw = process.env.TRUST_PROXY?.trim();
  if (!raw) return false;
  if (raw === "true") return true;
  if (raw === "false") return false;

  const hopCount = Number.parseInt(raw, 10);
  if (Number.isInteger(hopCount) && hopCount >= 0) {
    return hopCount;
  }

  return raw;
}

export const env = {
  port: readPort(),
  jwtSecret: requireEnv("JWT_SECRET"),
  adminPassword: requireEnv("ADMIN_PASSWORD"),
  corsOrigins: readCorsOrigins(),
  trustProxy: readTrustProxy(),
};
