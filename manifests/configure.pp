class drupal::configure {

  if $drupal::installtype == 'package' {
    file { $drupal::docroot:
      ensure => link,
      target => $drupal::installroot,
    }
  }

}
