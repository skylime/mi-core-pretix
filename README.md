# mi-core-pretix

This repository is based on [Joyent mibe](https://github.com/joyent/mibe). Please note this repository should be build with the [mi-core-base](https://github.com/skylime/mi-core-base) mibe image.

## description

This image install and configure [pretix](https://pretix.eu/) the ticketing software for events. No variables need to be configured.

## mdata variables

- `pretix_name`: Name of the pretix instance
- `pretix_locale_default`: Default locale used in pretix (de)
- `pretix_locale_timezone`: Timezone used in pretix (Europe/Berlin)
- `pretix_pgsql_pw`: Password for PostgreSQL, automatically generated if not set

### mail

The email configuration uses the your settings from `core-base`. But you could use different settings.

- `pretix_mail_from`: By default tickets@HOSTNAME
- `pretix_mail_host`: By default 127.0.0.1, you should change it if you do not use the configuration from core-base
- `pretix_mail_user`: Authentication username for SMTP
- `pretix_mail_pass`: Authentication password for SMTP
