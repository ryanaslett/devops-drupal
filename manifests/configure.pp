class drupal::configure {

  if $drupal::installtype == 'package' {
    file { $drupal::docroot:
      ensure => link,
      target => $drupal::installroot,
    }
  }

  file { "${docroot}/.htaccess":
    ensure  => file,
    source  => 'puppet:///modules/drupal/htaccess',
    require => Package['drupal7'],
  }
}
