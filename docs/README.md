# lazytam docs

Everything we've decided and everything we plan, in one place. Start with the vision,
then read whatever you need.

## Plan

| Doc | Answers |
|---|---|
| [vision.md](vision.md) | Why lazytam exists, who it's for, the target machine, goals and non-goals |
| [requirements.md](requirements.md) | What lazytam must do (functional) and how well (non-functional), with IDs and status |
| [roadmap.md](roadmap.md) | What's done, what's next, and everything we could build, phase by phase |
| [decisions/](decisions/README.md) | Every decision we've made, why, and what it rules out |

## How it works

| Doc | Covers |
|---|---|
| [architecture.md](architecture.md) | The three config layers, install, rendering, updates, where state lives |
| [modules.md](modules.md) | What each module installs and how to write one |
| [themes.md](themes.md) | Theme format, color keys, templates, wallpapers, Omarchy compatibility |
| [brand.md](brand.md) | Logo, colors, type, voice, the Figma file, README headers |

## Keeping this up to date

- **Made a decision?** Add a record in [decisions/](decisions/README.md), even a short one.
  If it replaces an older one, mark the old one *Superseded* and link both ways.
- **Finished or started something on the roadmap?** Update its status in
  [roadmap.md](roadmap.md) and the matching requirement in [requirements.md](requirements.md).
- **Changed how something works?** Update the "How it works" doc in the same pull request.

Statuses used everywhere: **Done**, **Partial**, **Planned**, **Idea**, **Dropped**.
