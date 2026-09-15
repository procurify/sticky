<p align="center">
  <img src="https://raw.githubusercontent.com/lord/img/master/logo-slate.png" alt="Slate: API Documentation Generator" width="226">
  <br>
  <a href="https://travis-ci.org/lord/slate"><img src="https://travis-ci.org/lord/slate.svg?branch=master" alt="Build Status"></a>
</p>

<p align="center">Slate helps you create beautiful, intelligent, responsive API documentation.</p>

<p align="center"><img src="https://raw.githubusercontent.com/lord/img/master/screenshot-slate.png" width=700 alt="Screenshot of Example Documentation created with Slate"></p>

<p align="center"><em>The example above was created with Slate. Check it out at <a href="https://lord.github.io/slate">lord.github.io/slate</a>.</em></p>


Getting Started with Slate
------------------------------

### Prerequisites

You're going to need:

 - **Linux or macOS** — Windows may work, but is unsupported.
 - **Ruby, version 3.3.0 or newer**
 - **Bundler** — If Ruby is already installed, but the `bundle` command doesn't work, just run `gem install bundler` in a terminal.

If you are on an M1 machine, you may experience problems installing `ruby`, please following this guide here
https://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/?utm_source=stackoverflow&utm_campaign=51126403

### Developing Locally

1. Clone this repo at `https://github.com/procurify/sticky.git`
2. `cd slate`
3. Initialize and start Slate:

```shell
bundle install
bundle exec middleman server
```

You can now see the docs at http://localhost:4567. Whoa! That was fast!

Now that Slate is all set up on your machine, you'll probably want to learn more about [editing Slate markdown](https://github.com/lord/slate/wiki/Markdown-Syntax), or [how to publish your docs](https://github.com/lord/slate/wiki/Deploying-Slate).

If you'd prefer to use Docker, instructions are available [in the wiki](https://github.com/lord/slate/wiki/Docker).

### Deploying to Github Pages

Merging to `master` publishes the site automatically. CircleCI builds the docs on every branch and pull request (the rendered `api_docs/build/` directory is stored as a job artifact) and, on `master` only, pushes the result to the `gh-pages` branch that GitHub Pages serves at https://procurify.github.io/sticky/. A merge that does not change rendered output will not create a new `gh-pages` commit.

`./deploy.sh` remains the manual fallback if you need to publish from a local checkout:

```shell
cd api_docs
bundle install
./deploy.sh
```

Requires Ruby 3.3+ and push access to the repo. Use `./deploy.sh --source-only` to build without pushing and inspect `api_docs/build/` first. To roll back the live site, revert the change on `master` and let CI republish, or run `./deploy.sh` locally from the older revision.
