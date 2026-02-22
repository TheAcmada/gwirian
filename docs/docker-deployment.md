## Deploying with Docker

We provide pre-built Docker images that can be used to run Gwirian on your own server. Images are built and published to [GitHub Container Registry (GHCR)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) on every push to `main` and on version tags (e.g. `v1.0.0`).

If you don't need to change the source code, and just want the out-of-the-box Gwirian experience, this can be a great way to get started.

### Mounting a storage volume

The standard Gwirian setup keeps all of its storage inside the path `/rails/storage`.
By default Docker containers don't persist storage between runs, so you'll want to mount a persistent volume into that location.

The simplest way to do this is with the `--volume` flag with `docker run`. For example:

```sh
docker run --volume gwirian:/rails/storage ghcr.io/theacmada/gwirian:main
```

Use the `:main` tag for the latest build from the main branch, or a version tag such as `:v1.0.0`.

That will create a named volume (called `gwirian`) and mount it into the correct path.
Docker will manage where that volume is actually stored on your server.

You can also specify the data location yourself, mount a network drive, and more.
Check the Docker documentation to find out more about what's available.

### Configuring with environment variables

To configure your Gwirian installation, you can use environment variables.
Gwirian has several of them.
Many of these are optional, but at a minimum you'll want to configure your secret key, and your SMTP email settings.

#### Secret Key Base

Various features inside Gwirian rely on cryptography to work.
To set this up, you need to provide a secret value that will be used as the basis of those secrets.
This value can be anything, but it should be unguessable, and specific to your instance.

You can use any long random string for this, or you can have the Gwirian codebase generate one for you by running:

```sh
bin/rails secret
```

Once you have one, set it in the `RAILS_MASTER_KEY` environment variable:

```sh
docker run --env RAILS_MASTER_KEY=abcdefabcdef ...
```

#### SMTP Email

Gwirian needs to be able to send email for its sign up/sign in flow, and for its regular summary emails.
The easiest way to set this up is to use a 3rd-party email provider (such as Resend, Sendgrid, and so on).
You can then plug all your SMTP settings from that provider into Gwirian via the following environment variables:

- `MAILER_FROM_ADDRESS` - the "from" address that Gwirian should use to send email
- `SMTP_HOST` - the address of the SMTP server you'll send through
- `SMTP_PORT` - the port number
- `SMTP_USERNAME`/`SMTP_PASSWORD` - the credentials for logging in to the SMTP server


You can find out more about all these settings in the [Rails Action Mailer documentation](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration).

#### Base URL

Gwirian needs to know the public URL of your instance so it can generate correct links in certain situations (like when sending emails).
Set `BASE_URL` to the full URL where your Gwirian instance is accessible:

```sh
docker run --env BASE_URL=https://gwirian.example.com ...
```

#### Elasticsearch URL

Gwirian uses Elasticsearch for fulltext search and indexing. Set `ELASTICSEARCH_URL` to the full URL where your Elasticsearch instance is accessible:

```sh
docker run --env ELASTICSEARCH_URL=https://gwirian.example.com:9200 ...
```

See `docker-compose.yml` for an example of how to use the Elasticsearch Docker image.
