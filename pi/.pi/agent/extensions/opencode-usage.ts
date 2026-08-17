import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import { readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { homedir } from "node:os";

interface SessionUsage {
	cost: number;
	tokens: number;
	updatedAt: string;
}

interface UsageStore {
	sessions: Record<string, SessionUsage>;
}

const USAGE_FILE = join(homedir(), ".pi", "agent", "opencode-usage.json");

async function readStore(): Promise<UsageStore> {
	if (!existsSync(USAGE_FILE)) return { sessions: {} };
	try {
		const data = await readFile(USAGE_FILE, "utf8");
		return JSON.parse(data);
	} catch {
		return { sessions: {} };
	}
}

async function writeStore(store: UsageStore): Promise<void> {
	await writeFile(USAGE_FILE, JSON.stringify(store, null, 2));
}

function sumBranchUsage(entries: any[]): { cost: number; tokens: number } {
	let cost = 0;
	let tokens = 0;
	for (const entry of entries) {
		if (entry.type === "message" && entry.message) {
			const msg = entry.message;
			if (msg.role === "assistant") {
				const usage = (msg as AssistantMessage).usage;
				cost += usage?.cost?.total ?? 0;
				tokens += usage?.totalTokens ?? 0;
			} else if (msg.role === "toolResult" && msg.usage) {
				cost += msg.usage.cost?.total ?? 0;
				tokens += msg.usage.totalTokens ?? 0;
			}
		} else if (entry.type === "compaction" && entry.usage) {
			cost += entry.usage.cost?.total ?? 0;
			tokens += entry.usage.totalTokens ?? 0;
		} else if (entry.type === "branch_summary" && entry.usage) {
			cost += entry.usage.cost?.total ?? 0;
			tokens += entry.usage.totalTokens ?? 0;
		}
	}
	return { cost, tokens };
}

function formatCost(cost: number): string {
	return `$${cost.toFixed(4)}`;
}

function formatTokens(tokens: number): string {
	if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(2)}M`;
	if (tokens >= 1_000) return `${(tokens / 1_000).toFixed(1)}k`;
	return `${tokens}`;
}

function getTotalCost(store: UsageStore): number {
	return Object.values(store.sessions).reduce((sum, s) => sum + s.cost, 0);
}

function getTotalTokens(store: UsageStore): number {
	return Object.values(store.sessions).reduce((sum, s) => sum + s.tokens, 0);
}

export default function (pi: ExtensionAPI) {
	let currentSessionFile: string | undefined;

	async function updateCurrentSession(
		ctx: any,
	): Promise<{ store: UsageStore; cost: number; tokens: number } | undefined> {
		if (!currentSessionFile) return;
		const branch = ctx.sessionManager.getBranch();
		const { cost, tokens } = sumBranchUsage(branch);
		const store = await readStore();
		store.sessions[currentSessionFile] = {
			cost,
			tokens,
			updatedAt: new Date().toISOString(),
		};
		await writeStore(store);
		return { store, cost, tokens };
	}

	async function setStatus(ctx: any, store: UsageStore) {
		if (!currentSessionFile) return;
		const session = store.sessions[currentSessionFile];
		if (!session) return;
		const total = getTotalCost(store);
		ctx.ui.setStatus(
			"opencode-usage",
			`${formatCost(session.cost)} session | ${formatCost(total)} total`,
		);
	}

	pi.on("session_start", async (_event, ctx) => {
		currentSessionFile = ctx.sessionManager.getSessionFile();
		const result = await updateCurrentSession(ctx);
		if (result) await setStatus(ctx, result.store);
	});

	pi.on("turn_end", async (_event, ctx) => {
		const result = await updateCurrentSession(ctx);
		if (result) await setStatus(ctx, result.store);
	});

	pi.on("agent_settled", async (_event, ctx) => {
		const result = await updateCurrentSession(ctx);
		if (result) await setStatus(ctx, result.store);
	});

	pi.registerCommand("usage", {
		description: "Show opencode usage stats (session + total across all sessions)",
		handler: async (_args, ctx) => {
			const result = await updateCurrentSession(ctx);
			const store = result?.store ?? (await readStore());
			const totalCost = getTotalCost(store);
			const totalTokens = getTotalTokens(store);

			const lines = ["Opencode Usage"];
			if (result) {
				lines.push(
					`  Session: ${formatCost(result.cost)} (${formatTokens(result.tokens)} tokens)`,
				);
			}
			lines.push(
				`  Total:   ${formatCost(totalCost)} (${formatTokens(totalTokens)} tokens)`,
			);

			const entries = Object.entries(store.sessions).sort(
				(a, b) =>
					new Date(b[1].updatedAt).getTime() -
					new Date(a[1].updatedAt).getTime(),
			);
			if (entries.length > 0) {
				lines.push("");
				lines.push("Recent sessions:");
				for (const [file, usage] of entries.slice(0, 10)) {
					const name = file.replace(/^.*\//, "").replace(/\.jsonl$/, "");
					lines.push(
						`  ${name}: ${formatCost(usage.cost)} (${formatTokens(usage.tokens)} tokens)`,
					);
				}
			}

			ctx.ui.notify(lines.join("\n"), "info");
		},
	});
}
