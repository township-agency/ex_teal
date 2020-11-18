# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.12.0](https://www.github.com/township-agency/ex_teal/compare/v0.11.2...v0.12.0) (2020-11-18)


### Features

* Select refactor ([#43](https://www.github.com/township-agency/ex_teal/issues/43)) ([667dbd9](https://www.github.com/township-agency/ex_teal/commit/667dbd9b7d7e27ad1ae848c657d6d2988b8c8fef))

### [0.11.2](https://www.github.com/township-agency/ex_teal/compare/v0.11.1...v0.11.2) (2020-11-17)


### Bug Fixes

* Action Relationship Params are non-empty ([#41](https://www.github.com/township-agency/ex_teal/issues/41)) ([592c220](https://www.github.com/township-agency/ex_teal/commit/592c220b8f4a2d59405dc915169cf450e6265848))

### [0.11.1](https://www.github.com/township-agency/ex_teal/compare/v0.11.0...v0.11.1) (2020-11-13)


### Bug Fixes

* Fix Naive DateTime Selector ([#39](https://www.github.com/township-agency/ex_teal/issues/39)) ([226b8c4](https://www.github.com/township-agency/ex_teal/commit/226b8c4b35ab007bc35545b504e6e772745c87cc))

## [0.11.0](https://www.github.com/township-agency/ex_teal/compare/v0.10.4...v0.11.0) (2020-11-04)


### Features

* Enable Naive DateTime Fields ([4b96d70](https://www.github.com/township-agency/ex_teal/commit/4b96d70b68871f4d6141b456b2e906605b459a1f)), closes [#36](https://www.github.com/township-agency/ex_teal/issues/36)
* Update BooleanGroup for ecto 3.5 ([#35](https://www.github.com/township-agency/ex_teal/issues/35)) ([49228f0](https://www.github.com/township-agency/ex_teal/commit/49228f08e15f5a8b473079b8d02b7023b0e491be))


### Bug Fixes

* Day Light Savings brittle tests ([a5f7261](https://www.github.com/township-agency/ex_teal/commit/a5f7261c281418ffe65603a723e7440f03c15254))

### [0.10.4](https://www.github.com/township-agency/ex_teal/compare/v0.10.3...v0.10.4) (2020-10-27)


### Bug Fixes

* Enable ex_teal_dependency_container to include it's params. ([#33](https://www.github.com/township-agency/ex_teal/issues/33)) ([f96edc2](https://www.github.com/township-agency/ex_teal/commit/f96edc2a309ce6a1c3825a1f8e0cefc3f20a774e))

### [0.10.3](https://www.github.com/township-agency/ex_teal/compare/v0.10.2...v0.10.3) (2020-10-14)


### Bug Fixes

* Use the correct select props and events for the non-searchable attach view ([#30](https://www.github.com/township-agency/ex_teal/issues/30)) ([d17e02d](https://www.github.com/township-agency/ex_teal/commit/d17e02d6e17eb4eff7c17faf1b738a87ac77eb1e))
* Value Format should be a string, not charlist ([#31](https://www.github.com/township-agency/ex_teal/issues/31)) ([e2d8137](https://www.github.com/township-agency/ex_teal/commit/e2d8137db56ebade99d3a813799f56fb9bff193c))

### [0.10.2](https://www.github.com/township-agency/ex_teal/compare/v0.10.1...v0.10.2) (2020-10-09)


### Bug Fixes

* Query Params need to be snake cased ([#28](https://www.github.com/township-agency/ex_teal/issues/28)) ([e48a952](https://www.github.com/township-agency/ex_teal/commit/e48a9529c0c584e5297917365622377b6f133460))

### [0.10.1](https://www.github.com/township-agency/ex_teal/compare/v0.10.0...v0.10.1) (2020-10-09)


### Bug Fixes

* Actions should use all index filtering tools when building a query ([9c55bcf](https://www.github.com/township-agency/ex_teal/commit/9c55bcfcb00fe6ea5e6bd6450176d8d5caa20f71))
* Include the version.txt in the release ([6ecf7d7](https://www.github.com/township-agency/ex_teal/commit/6ecf7d7ffaad5f2d55708e63f59aed45703b5ecd))

## [0.10.0](https://www.github.com/township-agency/ex_teal/compare/0.9.3...v0.10.0) (2020-09-16)


### Features

* Trend and Value metrics should use formatting ([89797bd](https://www.github.com/township-agency/ex_teal/commit/89797bd3231637722290ccda82431072e75a3750))


### Bug Fixes

* Adjust partition metric size ([0bffd66](https://www.github.com/township-agency/ex_teal/commit/0bffd66db9cf79840b7aca79cdf428f1ffd5197c))
* Card Wrapper xl window size was being purged ([#21](https://www.github.com/township-agency/ex_teal/issues/21)) ([7c3f977](https://www.github.com/township-agency/ex_teal/commit/7c3f977d831cadabd1e7979a71bcfa355b2af943))
* Fix compile warning ([9299be5](https://www.github.com/township-agency/ex_teal/commit/9299be5510575288df0fb6f213c15eb5c9a05b88))

### [0.9.3](https://github.com/township-agency/ex_teal/compare/0.9.2...0.9.3) (2020-08-26)

#### Features

* Partition Metrics
* Teal Themes

### Bug Fixes

* Darken h3 side-nav headers
* Card Wrapper was losing it's xl break points

### [0.9.2](https://github.com/township-agency/ex_teal/compare/0.9.1...0.9.2) (2020-08-26)

#### Features

* Metric Style Improvements
* Metrics have their own time controls again
* Time controls are configurable per metric.

### [0.9.1](https://github.com/township-agency/ex_teal/compare/0.9.0...0.9.1) (2020-08-24)

### Features

* New Boolean Group Field

### [0.9.0](https://github.com/township-agency/ex_teal/compare/0.8.8...0.9.0) (2020-07-28)

### Features

* A complete rewrite of Metrics to introduce `Trend` metrics.


### [0.8.8](https://github.com/township-agency/ex_teal/compare/0.8.7...0.8.8) (2020-06-22)

### Bug Fixes

* Empty `HasOne` fields threw an error.

### [0.8.7](https://github.com/township-agency/ex_teal/compare/v0.8.6...v0.8.7) (2020-06-20)

### Bug Fixes

* Invalid 204 Status

### [0.8.6](https://github.com/township-agency/ex_teal/compare/v0.8.5...v0.8.6) (2020-06-19)

### Bug Fixes

* HasOne Index Field had a bad url ([af5c411](https://github.com/township-agency/ex_teal/commit/af5c411ec5483b57571e34b49cedf104919437c3))
* UpdateAttached does not function. ([#8](https://github.com/township-agency/ex_teal/issues/8)) ([d4aee01](https://github.com/township-agency/ex_teal/commit/d4aee01e871299f149b7fad7760352f39ffa8159)), closes [#9](https://github.com/township-agency/ex_teal/issues/9)


### 0.8.5 (2020-06-15)

### Features

* **export:** Configurable export ([#4](https://github.com/township-agency/ex_teal/issues/4)) ([4fccd4d](https://github.com/township-agency/ex_teal/commit/4fccd4df3abf63ec29db5ea765b7667bc59400a7))

### Bug Fixes

* Resources with panels were broken ([aaaa485](https://github.com/township-agency/ex_teal/commit/aaaa48521d9c36f0f75b7bbbe91491af0b6b3bc3))
* Use Dialyxir in Test ([#5](https://github.com/township-agency/ex_teal/issues/5)) ([ef28bc9](https://github.com/township-agency/ex_teal/commit/ef28bc90116186b163ba7e353cf2647d28e2a1ad))

## [0.8.4] - 2020-05-26
### Fixes
- Forgot to compile assets

## [0.8.3] - 2020-05-26

### Changed
- Changed the function arguments for search.

## [0.8.2] - 2020-05-11

### Added
- The Many To Many Attach view can now use searchable relationships.
- Unified UX and engineering ergonomics for searchable results.

## [0.8.1] - 2020-05-07

### Changed
- Updated Download Icon
- Export file name now uses the resources uri rather then it's title

## [0.8.0] - 2020-05-06

### Added

Teal has removed the concept of static, per-field filters for automatically
build `field_filters`.  These filters can now be combined, extended and can use
far more advanced and useful customizable operators.

- New dynamic filters.  See below for required changes.
- New Table UX
- Export as a CSV

### Depreciated

To update to 0.8.0:

1. Remove the `filters/0` functions from your resources
2. Remove old filters
3. If you need to extend the logic of the included field filters, use the
   `ExTeal.Field.filter_as/2` function to modify the appropriate field and
   define a custom module that implements the behaviour of
   `ExTeal.FieldFilter`

## [0.7.9] - 2020-04-13

### Fixes
- An Empty MultiSelect Form

## [0.7.8] - 2020-04-02

### Added
- Help Text

## [0.7.7] - 2020-03-25

### Added
- Ability to override the default search tool.

## [0.7.6] - 2020-02-11

### Added
- Ability to skip the sanitizers on a per resource basis.

## [0.7.5] - 2020-02-03

### Added
- Action queries now use the `Index` functionality for preloads.

## [0.7.4] - 2020-01-23

### Changes

- Adds the `ActionResponse` struct that allows completed actions to change the
    user interface.

## [0.7.3] - 2020-01-09

### Fixes

- Fixes a regression in the update to `apply_options_for` for `update`

## [0.7.2] - 2020-01-09

### Fixes

- Fixes a regression in the update to `apply_options_for` for the create-fields

## [0.7.1] - 2020-01-09

### Fixes

- Fixes a regression in the update to `apply_options_for`

## [0.7.0] - 2020-01-09

### Breaking Changes
- [breaking] Changes `ExTeal.Field.apply_options_for` to accept a third
    argument.  See [!77](https://gitlab.motel-lab.com/Teal/ex_teal/merge_requests/77)

## [0.6.1] - 2020-01-09

### Adds
- Adds a `default_order` callback to the resource to allow engineers to define
    the default order of a resource.

## [0.6.0] - 2020-01-06

### Adds
- Adds a `dropdown_content` function to the `AuthProvider`.
- Adds an `Array` field

### Changes
- [breaking] Changes `gravatar` to `avatar_url` for the current_user map

### Fixes
- Cleans up the spec for `current_user_for`

## [0.5.0] - 2019-12-09

### Adds
- DateTime field
- `luxon` datetime library

### Removes
- `date-fns` date parsing

### Changes
- Refactors `Date`, and `DateTimePicker` fields

### Depreciates
- `Date.with_options/2` was depreciated in favor of `Date.format/2` and
    `Date.picker_format/2`.  Will be removed in `1.0.0`

## [0.4.4] - 2019-10-22

### Fixes
- Excerpts were ignoring line breaks
- Rich Text field content was being sanitized
- Flatpickr date time styles were missing

## [0.4.3] - 2019-10-11

### Fixes
- Broken Form submission when panels are used
- Broken Address Fields

## [0.4.2] - 2019-09-19

### Adds
- `as_html` field modifier
- Computed fields with a new `get` field modifier

## [0.4.1] - 2019-09-12

### Fixes
- Dashboard was missing cards

## [0.4.0] - 2019-09-05

### Adds
- Value Metrics
- Dashboards
- A default dashboard
- Pagination Labels to Resource Index Tables
- Resource Index Tables can be searched
- BelongsTo fields can be searched

### Fixes
- An empty string is now sanitized to nil

## [0.3.6] - 2019-08-06

### Fixes
- Styles for a better nav layout
- Global Search was broken
- Field visibility for Pivot Fields

## [0.3.5] - 2019-07-26

### Fixes
- Don't attempt to sanitize non-bitstring params

## [0.3.4] - 2019-07-26

### Fixes
- Edge Cases in new Attribute Logic

## [0.3.3] - 2019-07-25

### Fixes
- Broken Router and CSRF Plugin

## [0.3.2] - 2019-07-25

### Fixes
- Broken Dependencies

## [0.3.1] - 2019-07-24

### Adds
- XSS Protection

### Changed
- Cleaned up Router

## [0.3.0] - 2019-07-15

### Adds
- CSRF Protection (Thanks @lkoller)
- ManyToMany Fields and Relationships with pivot fields and sorting.

## [0.2.4] - 2019-06-26

### Changed
- Changed the HasOne field to be represented by a simplified resource index table.

## [0.2.3] - 2019-06-25

### Added
- HasOne Field

### Fixed
- Detail Page not changing if the ids are identical after switching resources


## [0.2.2] - 2019-06-11

### Fixed
- Broken Default Logo
- Attributes that have "null" values should be transformed to `nil`

## [0.2.1] - 2019-06-07

### Removed
- Teal Page Components

## [0.2.0] - 2019-06-04

### Added
- Boot Process for Plugins
- Script and Style definitions for a Plugin

### Changed
- Major rework of the front end.  If this wasn't pre-release software, it would
    be considered a breaking change.

## [0.1.8] - 2019-05-09

### Changed
- Simplified Mount Point

## [0.1.7] - 2019-05-06

### Added
- Color Picker

### Fixes
- Subtitles not displayed while searching
- Broken default Teal logo in sidenav

## [0.1.6] - 2019-03-08

### Added
- Additional, dropdown options for viewing more resources without pagination


## [0.1.5] - 2019-01-14

### Fixes
- Missing `window.teal` in axios error interceptor
- Aggressive `id` requirement that broke pages.

## [0.1.4] - 2018-12-17

### Added
- Actions
- Multi-Select on Index Views
- New tool for easier development of teal alongside a parent app.
- LiveReload and HMR while developing the Vue App
### Changed
- Upgraded Vue-CLI Dependencies
- Applied new Vue-CLI Linter Rules
### Fixes
- Broken Delete Icon on the ResourceTable

## [0.1.3] - 2018-11-29

Fixes:
- Missing Static Index File in production environments

## [0.1.2] - 2018-11-28

Fixes:

- Sets the correct location for the static index file

## [0.1.1] - 2018-11-28

Adds:

- Client assets compiled for production.

## [0.1.0] - 2018-11-28

### Initial Release
