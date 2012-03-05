class puppet::server::install {
  package { 'puppet-server': ensure => installed, require => Yumrepo["puppetlabs"] }
  package { 'ruby-devel': ensure => '1.8.7.352'}
  package { 'mysql': ensure => installed, provider => gem }
}
