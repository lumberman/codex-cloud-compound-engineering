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
- `playwright`
- the `ast-grep` agent skill
- a `ce` compatibility CLI so terminal checks can run `ce verify`, `ce list`, `ce brainstorm`, or `ce plan` without confusing Codex skills with repo scripts

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

5. In the optional maintenance script field, use this bootstrap command to pull the maintenance script from GitHub:

```bash
TMP_DIR="$(mktemp -d)"
curl -fsSL "https://github.com/lumberman/codex-cloud-compound-engineering/archive/main.tar.gz" \
  | tar -xz -C "$TMP_DIR" --strip-components=1
bash "$TMP_DIR/maintenance.sh"
rm -rf "$TMP_DIR"
```

6. If you commit/copy this kit into a repo instead, you can use:

```bash
bash maintenance.sh
```

7. Add the contents of `AGENTS.md.snippet` to your repository root `AGENTS.md`. This is important: it tells Codex Cloud agents that Compound Engineering is exposed as Codex skills/prompts, not as `ce` shell commands or `pnpm ce:*` scripts.
8. Start a Codex Cloud task and run this from the task terminal if you want to verify the environment:

```bash
bash verify.sh
```

## Notes

- Codex Cloud setup scripts run with internet access. The agent phase has internet off by default unless you enable it in the environment settings.
- Setup scripts run in a separate Bash session, so the script appends PATH updates to `~/.bashrc`.
- The Compound Engineering plugin conversion writes to `~/.codex/prompts` and `~/.codex/skills` inside the cloud container.
- Compound Engineering workflows are invoked as Codex skills/prompts in the agent context. They are not installed as real shell commands or `pnpm ce:*` package scripts.
- The setup installs Playwright globally and exports `NODE_PATH` so simple checks like `node -e 'require("playwright")'` can resolve it.
- The setup installs a small `ce` compatibility CLI, plus `ce:brainstorm`/`ce:plan`/`ce:work` style aliases. `ce verify` checks tools, `ce list` lists expected skills, and `ce brainstorm`/`ce plan`/`ce work` print the Codex skill to invoke. The CLI does not run the CE workflows itself.
- The `ast-grep` agent skill is installed to `~/.agents/skills/ast-grep`.
- `vhs` is installed through Go.
- `silicon` is installed from the upstream GitHub `v0.5.3` tag through Cargo. The setup installs the XCB, fontconfig, freetype, harfbuzz, png, and oniguruma development libraries it needs on Debian/Ubuntu images.
- If `agent-browser install` fails in setup, normal coding still works, but browser screenshot/reel workflows may need a follow-up environment tweak.

## Official References

- Codex cloud environments: https://developers.openai.com/codex/cloud/environments
- AGENTS.md discovery: https://developers.openai.com/codex/guides/agents-md
- Codex skills locations: https://developers.openai.com/codex/skills
- Compound Engineering plugin: https://github.com/EveryInc/compound-engineering-plugin
