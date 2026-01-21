# Claude Plugins Marketplace

Personal Claude Code plugin marketplace with shared skills and configurations.

## Installation

Add this marketplace to your Claude Code:

```bash
/plugin marketplace add AIRoutine/ClaudePlugins
```

Then install plugins:

```bash
/plugin install uno-dev
```

## Available Plugins

| Plugin | Description | Keywords |
|--------|-------------|----------|
| [uno-dev](plugins/uno-dev) | Uno Platform development skills for cross-platform .NET apps | `uno-platform`, `xaml`, `dotnet`, `cross-platform`, `mvux`, `winui` |

## Structure

```
ClaudePlugins/
├── .claude-plugin/
│   └── marketplace.json        # Marketplace configuration
├── plugins/
│   └── uno-dev/
│       ├── .claude-plugin/
│       │   └── plugin.json     # Plugin configuration
│       └── skills/
│           └── SKILL.md        # Skill definition
├── settings-templates/
│   └── settings.json           # Example settings for projects
└── README.md
```

## Settings Templates

Copy settings from `settings-templates/` to your project's `.claude/settings.json` as needed.

## Adding New Skills

1. Create a new folder under `plugins/<plugin-name>/skills/<skill-name>/`
2. Add a `SKILL.md` with YAML frontmatter
3. Commit and push

## Adding New Plugins

1. Create folder `plugins/<plugin-name>/.claude-plugin/plugin.json`
2. Create skills under `plugins/<plugin-name>/skills/`
3. Add plugin to `marketplace.json` `plugins` array with `name`, `path`, and `description`
4. Commit and push

## License

MIT
