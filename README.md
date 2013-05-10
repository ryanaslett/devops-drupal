Introduction
============

This is a module that allows you to manage many aspects of a multisite Drupal installation.

Features:

* Facts exposing core Drupal statistics
* Manages Drupal site variables
* Manages Drupal modules in all states. (absent, present/installed, disabled, uninstalled)
* Manages Drupal installation
    * Includes Drush for administration tasks
    * Multiple installation types:
        * Install from repositories
        * Install bundled tarball
        * Download directly from `d.o`
* Manages Drupal subsites (including `default`)
    * Includes vhost and database management if you're lazy
    * Configures `settings.php` for each subsite
        * Allows significant customization, with sane defaults
    * Installs site database with Drush

Limitations
============

This is still in early development. Pull requests are welcome!

If database management is enabled, the module will create a database and a
database user for each site. If you attempt to reuse either for multiple sites
you will get duplicate resource definitions and Puppet will squeal. If you wish
to reuse users or databases, manage them on your own.

I have not yet decided how I want to manage variables and modules for subsites.
Currently they're only managed for the `default` site. This is due to the uniqueness
constraint that resources have on their titles. As soon as I decide on the most
straightforward way to expose this to the user, this will be enabled.

This is currently only tested with CentOS using system packages, and with MySQL
and PgSQL. More testing and implementation is forthcoming.


Usage
============


### Managing the core Drupal installation on your node:

#### Classify and accept all defaults

    include drupal

#### Classify with a custom configuration

    class { 'drupal':
      installtype    => 'remote',
      database       => 'drupaldb',
      dbuser         => 'mydrupaluser',
      dbdriver       => 'pgsql',
    }

Many configuration options are simply passed directly to `drupal::site`, which is used
to create and manage the `default` site.

### Managing subsites within your Drupal installation:

    drupal::site { 'funky.monkey.com':
      ensure         => present,
      database       => 'funky',
      dbuser         => 'funky',
      dbdriver       => 'pgsql',
      managedatabase => true,
      managevhost    => true,
    }

More usage can be discovered by reading the source of `manifests/init.pp` and
`manifests/site.pp`. I will add more PuppetDoc as I have time and development stabilizes.

#### Managing variables and modules

    drupal_variable { 'clean_url':
      ensure => present,
      value  => 'TRUE',
    }

    drupal_module { 'trigger':
      ensure => present,
    }
    drupal_module { 'comment':
      ensure => absent,
    }

Contact
=======

* Author: Ben Ford
* Email: ben.ford@puppetlabs.com
* Twitter: @binford2k
* IRC (Freenode): binford2k


Special Thanks
=======

* Chris Bloom bloomcb@gmail.com: The man who knows no limits and provided some of the initial impetus
    for this project and someone to bounce ideas off.

License
=======

Copyright (c) 2013 Puppet Labs, info@puppetlabs.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.