## Development

To make Gwirian run in SaaS mode, run this in the terminal:

```ruby
bin/rails saas:enable
```

To go back to open source mode:

```ruby
bin/rails saas:disable
```

## How to update Gwirian

After making changes to this gem, you need to update Fizzy to pick up the changes:

```ruby
BUNDLE_GEMFILE=Gemfile.saas bundle update --conservative gwirian-saas
```

## Environments

Gwirian is deployed with [Kamal](https://kamal-deploy.org/). You'll need to have the Doppler CLI set up in order to access the secrets that are used when deploying. Provided you have that, it should be as simple as `bin/kamal deploy` to the correct environment.

## License

gwirian-saas is released under the [O'Saasy License](LICENSE.md).
