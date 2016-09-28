[![Gem Version](https://img.shields.io/gem/v/knife-chef-retention.svg?style=flat-square)](https://rubygems.org/gems/knife-chef-retention)
[![Gem Dowloads](https://img.shields.io/gem/dt/knife-chef-retention.svg?style=flat-square)](https://rubygems.org/gems/knife-chef-retention)
[![Travis branch](https://img.shields.io/travis/cvent/knife-chef-retention/master.svg?style=flat-square)](https://travis-ci.org/cvent/knife-chef-retention)

Knife Chef Retention
=======================

The main purpose of this knife plugin is to help cleanup stale objects on your
chef server.  The main use case it to run retentions on cookbook versions.

## Installation
Installation is easy just as any other knife plugin, just install with the gem
command

```bash
# You can install to your chefdk environment
chef gem install knife-chef-retention

# Or to a regular ruby environment
gem install knife-chef-retention
```

## Usage

Everything suppose to be organized in an easy to navigate way.  Everything is
nested under `knife inventory` and the commands should be self documenting.
Below are some simple examples

```bash
knife retention

** RETENTION COMMANDS **
knife retention cookbooks
```

License and Author
==================

* Author:: Brent Montague (<bmontague@cvent.com>)

Copyright:: 2015, Cvent, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Please refer to the [license](LICENSE.md) file for more license information.
