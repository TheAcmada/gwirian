## Development

The SaaS package is a Rails engine loaded through `Gemfile.saas`. It adds the `gwirian-saas` gem from this directory plus Paddle and Sentry dependencies, mounts subscription and Paddle webhook routes, and prepends plan-limit checks into workspace, project, feature, scenario, API, and MCP creation flows.

To make Gwirian run in SaaS mode for local development, run this in the terminal:

```sh
bin/rails saas:enable
```

This creates `tmp/saas.txt`. On the next boot, `Gwirian.configure_bundle` switches Bundler to `Gemfile.saas`.

To go back to open source mode:

```sh
bin/rails saas:disable
```

You can also set `SAAS=true` for a single command or process. Set `SAAS=false` to force open source mode even if `tmp/saas.txt` exists.

Use the repository binstubs (`bin/rails`, `bin/kamal`, and friends) when switching modes so the bundle is configured before Rails boots. If you invoke Bundler directly in SaaS mode, pass `BUNDLE_GEMFILE=Gemfile.saas`.

## How to update Gwirian

After making changes to this gem, you need to update Gwirian to pick up the changes:

```sh
BUNDLE_GEMFILE=Gemfile.saas bundle update --conservative gwirian-saas
```

## SaaS environment variables

The engine reads these optional production settings:

- `PADDLE_API_KEY`, `PADDLE_CLIENT_TOKEN`, and `PADDLE_WEBHOOK_SECRET` for subscription billing.
- `SENTRY_DSN` and `KAMAL_VERSION` for Sentry reporting. Sentry is skipped in local environments and can also be skipped with `SKIP_TELEMETRY=true`.
- `PADDLE_PRICE_STARTER`, `PADDLE_PRICE_PROFESSIONAL`, and `PADDLE_PRICE_TEAM` map paid plans to Paddle price IDs.

## Environments

Gwirian is deployed with [Kamal](https://kamal-deploy.org/). You'll need to have the Doppler CLI set up in order to access the secrets that are used when deploying. Provided you have that, it should be as simple as `bin/kamal deploy` to the correct environment.

## License

gwirian-saas is released under the [O'Saasy License](LICENSE.md).
