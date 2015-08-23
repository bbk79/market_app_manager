## Markets Service Manager

### Dependencies
- $ gem install bundler (if bundler is not installed)
- $ bundle install

### Run Tests
- $ ruby test/test\_service\_manager.rb

### CLI

- $ ./sm_cli apps [YYYY-MM-DD] [--config-dir=path/to/config/dir]
 - Lists apps that should be running on a given ISO 8601 date. Defaults to today if no date is provided.
 - Config files are loaded from ./config/ by default. This path may be overridden using --config-dir option.
- $ ./sm_cli commands [YYYY-MM-DD] [--config-dir=path/to/config/dir] [--apps=a1,a2,...]
 - Lists daily app start and stop commands for 7 days from a given ISO 8601 date (inclusive). Defaults to today if no date is provided.
 - All apps are included by default, optionally a comma separated list of apps can be used.
 - Config files are loaded from ./config/ by default. This path may be overridden using --config-dir option.
