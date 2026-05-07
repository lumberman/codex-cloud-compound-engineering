# Codex Cloud Compound Engineering Environment

This folder contains a Codex Cloud setup kit for the Compound Engineering plugin.

It installs:

- Compound Engineering converted for Codex via `bunx @every-env/compound-plugin install compound-engineering --to codex`
- `agent-browser`
- `gh`
- `jq`
- `vhs`
- `silicon`
- `ffmpeg`
- `ast-grep`
- the `ast-grep` agent skill

## Use In Codex Cloud

1. Open Codex settings, then create or edit a cloud environment.
2. In the setup script field, use this bootstrap command to pull the latest setup from GitHub:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/lumberman/codex-cloud-compound-engineering/main/setup-from-github.sh)"
```

3. Or paste the contents of `setup.sh` directly into the setup script field.
4. If you commit/copy this kit into a repo instead, use:

```bash
bash setup.sh
```

5. In the optional maintenance script field, paste `maintenance.sh`, or use:

```bash
bash maintenance.sh
```

6. Add the contents of `AGENTS.md.snippet` to your repository root `AGENTS.md`.
7. Start a Codex Cloud task and run this from the task terminal if you want to verify the environment:

```bash
bash verify.sh
```

## Notes

- Codex Cloud setup scripts run with internet access. The agent phase has internet off by default unless you enable it in the environment settings.
- Setup scripts run in a separate Bash session, so the script appends PATH updates to `~/.bashrc`.
- The Compound Engineering plugin conversion writes to `~/.codex/prompts` and `~/.codex/skills` inside the cloud container.
- The `ast-grep` agent skill is installed to `~/.agents/skills/ast-grep`.
- `vhs` is installed through Go.
- `silicon` is installed through Cargo. If Cargo is missing, the script installs a minimal Rust toolchain with `rustup`.
- If `agent-browser install` fails in setup, normal coding still works, but browser screenshot/reel workflows may need a follow-up environment tweak.

## Official References

- Codex cloud environments: https://developers.openai.com/codex/cloud/environments
- AGENTS.md discovery: https://developers.openai.com/codex/guides/agents-md
- Codex skills locations: https://developers.openai.com/codex/skills
- Compound Engineering plugin: https://github.com/EveryInc/compound-engineering-plugin
