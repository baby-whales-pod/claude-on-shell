# Example: Claude Code on the `shell` template

An example `sbx` sandbox, built from the **shell template**, where:

1. the **Claude CLI** is installed in the image (via a *template* / Dockerfile);
2. the agent is **authenticated at load time**, without an interactive `/login`
   (via a *kit*).

Authentication relies on sbx's native model: **credentials stay on the host**
and the **proxy** injects them into requests to `api.anthropic.com`. Nothing
secret enters the container.

```
claude-on-shell/
├── template/
│   └── Dockerfile      # FROM docker/sandbox-templates:shell + install Claude CLI
├── kit/
│   └── spec.yaml       # schema v1 (kind: agent) — legacy reference
├── kit-v2/
│   └── spec.yaml       # schema v2 (kind: sandbox) — recommended
└── README.md
```

- **Template docs**: https://docs.docker.com/ai/sandboxes/customize/templates/
- **Kit docs**: https://docs.docker.com/ai/sandboxes/customize/kits/

> Two kits are provided: `kit/` in the deprecated **v1** schema (kept as a
> reference) and `kit-v2/` in the current **v2** schema. Prefer `kit-v2/`.

---

## 1. Build the image (the template)

```bash
docker build -t sbx-examples/claude-on-shell:latest template/
```

> The tag **must** match `sandbox.image` in `kit-v2/spec.yaml`.
> The template starts from `docker/sandbox-templates:shell` (bash, git, gh,
> docker CLI, ripgrep… plus sbx's credential-proxy tooling already present) and
> adds the Claude CLI on top.

## 2. Provide the API key on the host

The proxy discovers `ANTHROPIC_API_KEY` directly in the host environment (where
you run `sbx run`) and injects it into requests to Anthropic.

```bash
export ANTHROPIC_API_KEY=sk-ant-...
```

> The real secret never enters the container: the proxy substitutes it for the
> placeholder value `proxy-managed` seeded by the kit in `settings.json`.

## 3. Run the sandbox (the kit)

The kit is `kind: sandbox`: it registers an agent named `claude-on-shell`. Pass
it both via `--kit` **and** as the agent name:

```bash
sbx run claude-on-shell --kit ./kit-v2/
```

To work on a code directory, add the path:

```bash
sbx run claude-on-shell --kit ./kit-v2/ /path/to/my/project
```

On open, Claude Code starts straight into its TUI (no onboarding/trust prompt,
no `/login`): the proxy authenticates every API call.

---

## How load-time authentication works

| Piece | Role |
| ----- | ---- |
| `credentials[].apiKey.name` | Host env var the proxy reads (`ANTHROPIC_API_KEY`). |
| `credentials[].apiKey.inject[]` | Per-domain injection: the proxy replaces the `x-api-key` header with the real host secret. |
| `credentials[].oauth` | Subscription mode: the proxy seeds sentinels in `~/.claude/.credentials.json` and exchanges OAuth tokens on the agent's behalf. |
| `commands.install` → `~/.claude.json` | Sets onboarding / trust / bypass flags → no "trust this project?" dialog. |
| `commands.install` → `settings.json` | Adds `apiKeyHelper: "echo proxy-managed"` → Claude does not ask for `/login`. |
| `caps.network.allow` | Opens network egress only to the Anthropic domains. |

## v1 → v2 migration map

| v1 (deprecated) | v2 |
| --- | --- |
| `kind: agent` | `kind: sandbox` |
| `agent:` block | `sandbox:` block |
| `agent.persistence` | *removed (no effect)* |
| `credentials.sources.anthropic.env: [X]` | `credentials: [ {service, apiKey.name: X} ]` |
| `network.serviceDomains` | `credentials[].apiKey.inject[].domain` |
| `network.serviceAuth` | `credentials[].apiKey.inject[].header` / `.format` |
| `network.allowedDomains` | `caps.network.allow` |

## Validate / package the kit

```bash
sbx kit validate ./kit-v2/          # well-formed?
sbx kit inspect  ./kit-v2/          # image, credentials, commands…
sbx kit pack     ./kit-v2/ -o claude-on-shell-kit.zip   # distributable
```

## Customize

- **Docker-in-Docker**: start from `docker/sandbox-templates:shell-docker` in the
  Dockerfile and add `LABEL com.docker.sandboxes.start-docker="true"`.
- **Extra tools**: add `RUN apt-get install …` (as `USER root`, then back to
  `USER agent`) in the template, or a `commands.install` command in the kit.
