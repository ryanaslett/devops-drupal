class drupal::package::remote (
  $docroot = $drupal::docroot,
  $version = $drupal::drupalversion,
) {

  exec { 'install drupal':
    command => "/bin/tar -xf /tmp/drupal-${version}.tar.gz --strip=1 -C ${docroot}",
    onlyif  => "/usr/bin/curl http://ftp.drupal.org/files/projects/drupal-${version}.tar.gz -o /tmp/drupal-${version}.tar.gz",
  }

}
