
  # installs apache, php, mysql, etc
  class { 'requirements':
    database       => $database,
    dbuser         => $dbuser,
    dbpassword     => $dbpassword,
    dbhost         => $dbhost,
  } ->

  class { 'drupal':
    database       => $database,
    dbuser         => $dbuser,
    dbpassword     => $dbpassword,
    dbhost         => $dbhost,
    dbdriver       => $dbdriver,
    admin_password => $admin_password,
    repository     => 'git://github.com/user/repo.git',
  } ->

  drupal::site { 'mysite.example.com':
    docroot   => '/path/to/docroot',
    admin     => 'admin',
    password  => 'password',
    admintheme => 'sometheme',
    
  }

  drupal::site { 'dev.mysite.example.com':
    docroot   => '/path/to/devdocroot',
    admin     => 'admin',
    password  => 'password',
    admintheme => 'sometheme',
    
  }

  drupal::site { 'dev.mysite.example.com':
    docroot   => '/path/to/devdocroot',
    admin     => 'admin',
    password  => 'password',
    admintheme => 'sometheme',
  }
  
  drupal::module { 'date':
    ensure => present,
    site   => Drupal::Site['mysite.example.com'],
    patch  => [ '/path/to/patch', '/path/to/second' ]
  }
  
  drupal::module { 'date':
    ensure => present,
    site   => Drupal::Site['mysite.example.com'],
    source  => '/path/to/mod.tar.gz',
  }
  
  drupal::variable { 'somevariable':
    ensure => present,
    value  => 'somevalue',
    site   => Drupal::Site['mysite.example.com'],
  }
  
  
  
  
  
  git clone --recursive --branch 7.x http://git.drupal.org/project/drupal.git
git clone --recursive --branch 7.x-5.x http://git.drupal.org/project/drush.git
