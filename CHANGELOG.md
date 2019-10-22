# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

Nothing here yet

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

