# AGENTS.md

## Verification

After modifying code, run rubocop and rspec.

```sh
make rubocop
make rspec
```

- Both run in the running container. Start it with `make up` first if it is not running
- `make rubocop` runs with `-a`, so it may autocorrect files

## Comments

- Keep comments to a minimum. Do not write what the code already says
