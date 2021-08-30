# Superface Specification

Superface Profile and Map languages specification, research and demos.

[Read Profile Specification](https://spec.superface.dev/profile)
[Read Map Specification](https://spec.superface.dev/map)

## Draft specifications

The `draft` directory provides a copy of the specifications based on the currently-proposed changes. It's best to refer to the latest version found in the `latest` directory as the draft may still be in development and may change before it becomes a full version.

## How to create a new version

* All changes should start out as drafts. If there is no `draft` folder, create one by copying the `latest` directory.
* When it is time to convert the `draft` to the latest version, start by renaming the `latest` directory to the version number of the specification.
* Give the files in the `draft` directory a version based on the current day using the format YYYY.MM.DD.
* Rename the `draft` directory to `latest`.

## Develop spec

### Install and setup

```
$ yarn install
$ yarn build
```

### Profile specification

```
$ yarn watch:profile-spec
$ open public/draft/profile.html
```

### Map specification

```
$ yarn watch:map-spec
$ open public/draft/map.html
```
