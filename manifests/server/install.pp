class puppet::server::install {
  package { 'puppet-server': ensure => installed, require => Yumrepo["puppetlabs"] }
}
