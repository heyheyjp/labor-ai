import { checkHealth } from "@/lib/api-client";

export default async function HealthPage() {
  const health = await checkHealth();

  return (
    <main className="flex min-h-screen items-center justify-center">
      <div>
        <h1 className="text-xl font-semibold mb-2">API Health</h1>
        <p>
          Status: <span className="font-mono">{health.status}</span>
        </p>
      </div>
    </main>
  );
}
