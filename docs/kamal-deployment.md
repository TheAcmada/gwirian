## Deploying Gwirian with Kamal

If you'd like to run Gwirian on your own server while having the freedom to easily make changes to its code, we recommend deploying it with [Kamal](https://kamal-deploy.org/).
Kamal makes it easy to set up a bare server, copy the application to it, and manage the configuration settings that it uses.

This repo contains a starter deployment file that you can modify for your own specific use. That file lives at [config/deploy.yml](config/deploy.yml), which is the default place where Kamal will look for it.

The steps to configure your very own Gwirian are:

1. Fork the repo
2. Initialize Kamal by running `kamal init`. This command generates the `.kamal` directory along with the required configuration files, including `.kamal/secrets`.
3. Edit few things in config/deploy.yml and .kamal/secrets
4. Run `kamal setup` to do your first deploy.

We'll go through each of these in turn.

### Fork the repo

To make it easy to customise Gwirian's settings for your own instance, you should start by creating your own GitHub fork of the repo.
That allows you to commit your changes, and track them over time.
You can always re-sync your fork to pick up new changes from the main repo over time.


### Editing the configuration

The config/deploy.yml has been mostly set up for you, but you'll need to fill out some sections that are specific to your instance.
To get started, the parts you need to change are all in the "About your deployment" section.
We've added comments to that file to highlight what each setting needs to be, but the main ones are:

- `servers/web`: Enter the hostname of the server you're deploying to here. This should be an address that you can access via `ssh`.
- `ssh/user`: If you access your server a `root` you can leave this alone; if you use a different user, set it here.
- `proxy/ssl` and `proxy/host`: Kamal can set up SSL certificates for you automatically. To enable that, set the hostname again as `host`. If you don't want SSL for some reason, you can set `ssl: false` to turn it off.
- `env/clear/BASE_URL`: The public URL of your Gwirian instance (e.g., `https://gwirian.example.com`). Used when generating links.
- `env/clear/MAILER_FROM_ADDRESS`: This is the email address that Gwirian will send emails from. It should usually be an address from the same domain where you're running Gwirian.
- `env/clear/SMTP_HOST`: The address of an SMTP server that you can send email through. You can use a 3rd-party service for this, like Sendgrid or Postmark, in which case their documentation will tell you what to use for this.
- `env/clear/SMTP_PORT`: The port of the SMTP server used to send endmails.

Gwirian also requires a few environment variables to be set up, some of which contain secrets.
The simplest way to do this is to put them in a file called `.kamal/secrets`.
Because this file will contain secret credentials, it's important that you DON'T CHECK THIS FILE INTO YOUR REPO! You can add the filename to `.gitignore` to ensure you don't commit this file accidentally.

If you use a password manager like 1Password or Doppler, you can also opt to keep your secrets there instead.
Refer to the [Kamal documentation](https://kamal-deploy.org/docs/configuration/environment-variables/#secrets) for more information about how to do that.

To store your secrets, create the file `.kamal/secrets` and enter something like the following:

```ini
RAILS_MASTER_KEY=12345
SMTP_USERNAME=email-provider-username
SMTP_PASSWORD=email-provider-password
```

The values you enter here will be specific to you, and you can get or create them as follows:

- `RAILS_MASTER_KEY` should be a long, random secret. You can run `bin/rails secret` to create a suitable value for this.
- `SMTP_USERNAME` & `SMTP_PASSWORD` should be valid credentials for your SMTP server. If you're using a 3rd-party service here, consult their documentation for what to use.


Once you've made all those changes, commit them to your fork so they're saved.

### Deploy Gwirian!

You can now do your first deploy by running:

```sh
bin/kamal setup
```

This will set up Docker (if needed), build your Gwirian app container, configure it, and start it running.

After the first deploy is done, any subsequent steps won't need to do that initial setup. So for future deploys you can just run:

```sh
bin/kamal deploy
```


