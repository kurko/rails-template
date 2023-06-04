# README

- [Introduction](docs/),

## Setup

🌿 Run `bin/setup` to run bundle, yarn install, create and migrate databases.
It will run `db:seed` automatically which creates tons of content.

🆘 If you're lost why the app is not booting, run `bin/doctor`. It will give
you a checklist of expected things that could be broken.

If you need to delete all data and start over, run `bin/reset_db`.

## Developing

There are two contexts: the content app or the betting system (see intro above).

- Run `bin/dev-web` to run `rails server`, including css and js compilers
- Run `bin/dev-all` to run all the above, plus `sidekiq`, `clockwork` and other
  processes necessary.
