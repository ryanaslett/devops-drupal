package { [ 'mysql', 'httpd', 'php-mysql' ]:
  ensure => present,
} ->

package { 'php':
  ensure => '5.3.2',
}

service { 'mysql', 'httpd']:
  ensure => running,
  enable => true,
} ->

$sites = [ 'one', 'two', 'three' ]

drupal::site { hiera('sites'):
  ensure => present,
}



