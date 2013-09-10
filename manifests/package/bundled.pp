class drupal::package::bundled (
  $installroot = $drupal::installroot,
  $docroot = $drupal::docroot,
  $version = $drupal::drupalversion,
) {

  $php_modules = $osfamily ? {
    'RedHat' =>  ['gd', 'pdo', 'xml'],
    default  =>  ['gd', 'mbstring', 'pdo', 'xml'],
  }

  php::module { $php_modules:
    ensure => installed,
    before => Exec['install drupal'],
  }

  file { "/tmp/drupal-${version}.tar.gz":
    ensure => file,
    source => "puppet:///modules/drupal/drupal-${version}.tar.gz",
    before => Exec['install drupal'],
  }
  exec { 'install drupal':
    command => "/bin/tar -xf /tmp/drupal-${version}.tar.gz",
    cwd     => $installroot,
    creates => "${installroot}/drupal-${version}",
    before  => File[$docroot],
  }
  file { $docroot:
    ensure => symlink,
    target => "drupal-${version}",
  }
}