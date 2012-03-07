class puppet::server::install {
  package { 'puppet-server': ensure => installed, require => Yumrepo["puppetlabs"] }
  package { 'mysql-devel': ensure => installed }
  package { 'ruby-devel': ensure => '1.8.7.352-1.8.amzn1'}
  package { 'activerecord': ensure => '3.0.9', provider => gem }
  
  service { "puppet":
  	enable 	=> true,
  	ensure 	=> running,
  	name 	=> "puppet",
  	require => [Package["puppet"], Package["mysql"], Service["puppetmaster"]],
  	subscribe => Service["puppetmaster"],
  }
  
  service { "puppetmaster":
  	enable 	=> false,
  	ensure 	=> stopped,
  	name 	=> "puppetmaster",
  	require => [Package["puppet-server"], Package["mysql"]],
  }

  exec { "puppetmaster-run-once":
    command => "/etc/init.d/puppetmaster start && /etc/init.d/puppetmaster stop",
    creates => "/var/lib/puppet/ssl/certs/puppet.${domain}.pem",
    require => [Service["puppetmaster"],mysql::db["puppet"]],
    notify  => Service["puppet"],
  }
    
  class { 'mysql::server':
  	config_hash => { 'root_password' => 'password' },
  	require => Service["mysqld"],
  }

  class { 'mysql': }
  
  mysql::db { 'puppet':
	  user     => 'puppet',
	  password => 'password',
	  host     => 'localhost',
	  grant    => ['all'],
	}
}
