# Sharp in Session

This is our own fork of `sharp`, with some changes to make it work with our specific needs.
Here are some details of how sharp is architected, so if someone has to come back to this project in 2 years, they can understand what's going on.

## High level overview

About `sharp-libvips` there is another `README.session.md` file that explains the high level overview of how that part works and how to make a new release.

The way sharp is architected is that it uses prebuilt binaries of our own `sharp-libvips`.
This `sharp` repository is not doing much but preparing the binaries and some scripts so that an app can use `yarn add sharp`, and it will

- download the prebuilt binaries
- create a sharp.node module, depending on the current architecture
- allow sharp to be loaded by the final application depending on the runtime platform (see `lib/sharp.js`)

The build through CI will create an umbrella project named `@img/sharp`, and then a `@img/sharp-<platform>` project for each platform that were built.

## Build output

The same logic as for `sharp-libvips` is used. We don't publish to npm, but we publish our builds of `@img/sharp` and `@img/sharp-<platform>` to our own github repo as [releases](https://github.com/session-foundation/sharp/releases/tag/v0.34.6). It has

- the umbrella project `@img/sharp`, published as `sharp-0.34.6.tgz`
- the platform-specific projects `@img/sharp-xxx`, ..., published as `img-sharp-xxx-0.34.6.tgz`

### Important detail

This is setup all in a bit of a weird way because when this projects builds through the CI, it will create a release of

- the umbrella project with version `0.34.6` for instance,
- the platform-specific projects with version `0.34.6-<platform>` for instance

But the umbrella project will link to those in its own `package.json`.
What I mean is that you'll get a release on github that has a `sharp/package.json` that is referencing other artefacts of that same.
And of course, if one of those is missing, you'll get an error when trying to install the umbrella project from `session-desktop`

i.e. you'll get

- a `sharp/package.json` in `sharp-0.34.6.tgz` stored at `https://github.com/session-foundation/sharp/releases/download/v0.34.6/sharp-0.34.6.tgz`
- and in that package.json, you'll have entries like `https://github.com/session-foundation/sharp/releases/download/v0.34.6/img-sharp-darwin-x64-0.34.6.tgz`

## Publishing a new release

The same logic as for `sharp-libvips` is used. You'd need to first update `sharp-libvips` if a change is needed and publish a new version of it on github.
Once you have the new version of `sharp-libvips`, you can get ready to draft a new release of sharp. Make sure that `sharp-libvips` release is indeed published on github (as the CI will only draft it).

The next steps are:

- search and replace all of the previous version of sharp `0.34.6` with the new version `0.34.7`. This should change all of the references to `optionalDependencies` in the root `package.json`, and all of the references in the `npm/*/package.json` files.
- search and replace all of the previous version of `sharp-libvips` `1.2.4` with the new version `1.2.5`. This should also change all of the references to `optionalDependencies` in the root `package.json`, and all of the references in the `npm/*/package.json` files.
- commit and force push the changes and the tag: `git tag -d v0.34.7; git tag v0.34.7 && git push foundation -f && git push foundation -f tags/v0.34.7`
- this should then trigger the CI to build the new release on all supported platforms and the umbrella project.

## Use in Session Desktop

If you override a force push to the same tag and want to update it on session-desktop, you'll need to first remove sharp from session-desktop.
You can do those steps:

```bash
cd ~/session-desktop
yarn remove sharp --ignore-scripts # this is important to clear up stored checksums
yarn cache clean
yarn add https://github.com/session-foundation/sharp/releases/download/v0.34.6/sharp-0.34.6.tgz
```

And hopefully, you'll get your updated version of sharp + sharp-libvips ready for a release of session-desktop!

Note: sometimes github/yarn **http **cache is getting in the way, and reports that no such package is found. Try a few times and it should hopefully fix itself.
