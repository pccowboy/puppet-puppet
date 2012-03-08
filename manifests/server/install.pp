class puppet::server::install {
  package { 'puppet-server': ensure => installed, require => Yumrepo["puppetlabs"] }
  package { 'mysql-devel': ensure => installed }
  package { 'ruby-devel': ensure => '1.8.7.352-1.8.amzn1'}
  package { 'ruby-mysql': ensure => installed}
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
    command => "/etc/init.d/puppetmaster start; sleep 10; /usr/sbin/puppetd -d -t; /usr/sbin/puppetd -d -t; /etc/init.d/puppetmaster stop",
    path	=> "/bin:/usr/bin:/usr/sbin",
    require => [Service["puppetmaster"], mysql::db['puppet']],
    notify  => Service["puppet"],
    before	=> [Exec["db-index"], Package["foreman"]],
    logoutput => true,
  }

  exec{"db-index":
  	command		=> 'echo "use puppet; create index exported_restype_title on resources (exported, restype, title(50));" | mysql -u puppet -ppassword puppet',
    refreshonly => true,
    path		=> "/bin:/usr/bin",
    require		=> Service["puppet"],
    subscribe	=> Exec["puppetmaster-run-once"],
  }
    
  class { 'mysql::server':
  	config_hash => { 'root_password' => 'password' },
  }

  class { 'mysql': }
  
  mysql::db { 'puppet':
	  user     => 'puppet',
	  password => 'password',
	  host     => 'localhost',
	  grant    => ['all'],
	}
}
