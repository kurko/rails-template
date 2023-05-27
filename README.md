# Rails Template 💎

A Ruby on Rails web application boilerplate with my preferred dependencies all
pre-installed to save time.

## How to use

Generate a new application this template:

```sh
rails new AmazingApp \
  -d postgresql \
  -m https://raw.githubusercontent.com/kurko/rails-template/master/template.rb
```

## Install

Add the following lines to your `~/.railsrc` if you want all your new projects
to source my template.

```sh
-d postgresql
-m https://raw.githubusercontent.com/kurko/rails-template/master/template.rb
```

## What it includes?

* [Devise](https://github.com/heartcombo/devise)
* [Foreman](https://github.com/ddollar/foreman)
* RSpec

Inspired by and loosely based on Matt Brictson's
[mattbrictson/rails-template](https://github.com/mattbrictson/rails-template).
