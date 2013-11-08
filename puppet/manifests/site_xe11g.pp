#
# one machine setup with 11g XE database plus weblogic 10.3.6 patched to PS 6
#
# 
#
# needs  oradb, jdk7, wls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

node 'vagrantcentos64' {
  
   # include os2, db12c2, wls12_adf2, wls12c_adf_domain2, orautils, maintenance
   include os2, oraclexe
   
   # Class['os2'] -> Class['wls12_adf2'] -> Class['db12c2'] -> Class['wls12c_adf_domain2'] -> Class['maintenance']

   Class['os2'] -> Class['oraclexe']

}

# operating settings for Database & Middleware
class os2 {

  package { $remove:
    ensure  => absent,
  }

  $install = [ 'binutils.x86_64', 'libaio.x86_64','bc.x86_64']
               
               
  package { $install:
    ensure  => present,
  }

  class { 'limits':
    config => {
               '*'       => { 'nofile'   => { soft => '2048'   , hard => '8192',   },},
               'oracle'  => {  'nofile'  => { soft => '65536'  , hard => '65536',  },
                               'nproc'   => { soft => '2048'   , hard => '16384',   },
                               'memlock' => { soft => '1048576', hard => '1048576',},
                               'stack'   => { soft => '10240'  ,},},
               },
    use_hiera => false,
  }

  sysctl { 'kernel.msgmnb':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.msgmax':                 ensure => 'present', permanent => 'yes', value => '65536',}
  sysctl { 'kernel.shmmax':                 ensure => 'present', permanent => 'yes', value => '2588483584',}
  sysctl { 'kernel.shmall':                 ensure => 'present', permanent => 'yes', value => '2097152',}
  sysctl { 'fs.file-max':                   ensure => 'present', permanent => 'yes', value => '6815744',}
  sysctl { 'net.ipv4.tcp_keepalive_time':   ensure => 'present', permanent => 'yes', value => '1800',}
  sysctl { 'net.ipv4.tcp_keepalive_intvl':  ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'net.ipv4.tcp_keepalive_probes': ensure => 'present', permanent => 'yes', value => '5',}
  sysctl { 'net.ipv4.tcp_fin_timeout':      ensure => 'present', permanent => 'yes', value => '30',}
  sysctl { 'kernel.shmmni':                 ensure => 'present', permanent => 'yes', value => '4096', }
  sysctl { 'fs.aio-max-nr':                 ensure => 'present', permanent => 'yes', value => '1048576',}
  sysctl { 'kernel.sem':                    ensure => 'present', permanent => 'yes', value => '250 32000 100 128',}
  sysctl { 'net.ipv4.ip_local_port_range':  ensure => 'present', permanent => 'yes', value => '9000 65500',}
  sysctl { 'net.core.rmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.rmem_max':             ensure => 'present', permanent => 'yes', value => '4194304', }
  sysctl { 'net.core.wmem_default':         ensure => 'present', permanent => 'yes', value => '262144',}
  sysctl { 'net.core.wmem_max':             ensure => 'present', permanent => 'yes', value => '1048576',}


  # 2GB is the largest swapfle that XE allows

  exec { "create swap file":
    command => "/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048",
    creates => "/var/swap.1",
  }

 
  exec { "attach swap file":
    command => "/sbin/mkswap /var/swap.1 && /sbin/swapon /var/swap.1",
    require => Exec["create swap file"],
    unless => "/sbin/swapon -s | grep /var/swap.1",
  }

 
}


class oraclexe {

file {
    '/vagrant/sql/setUpSQL.sh':
    ensure  => 'present',
    mode    => '0755',
    owner    => 'vagrant';
}

exec { "Install Oracle XE 11g":
    command => "/bin/rpm -ivh /vagrant/oracle-xe-11.2.0-1.0.x86_64.rpm > /tmp/XEsilentinstall.log",
    require => Exec["attach swap file"],
    creates => "/etc/init.d/oracle-xe",
}

exec { "Configure Oracle XE":
    command => "/etc/init.d/oracle-xe configure responseFile=/vagrant/xe.rsp >> /tmp/XEsilentinstall.log" ,
    require => Exec["Install Oracle XE 11g"],
    # unless => "/sbin/swapon -s | grep /var/swap.1",
 }

 exec { "SetORACLE_ENVForVagrant":
    command => "/bin/echo . /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh  >> .bashrc" ,
    require => Exec["Configure Oracle XE"],
    user => "vagrant",
 }

 exec { "AddVagrantToDBAGroup":
    command => "/usr/sbin/usermod -g dba vagrant",
    require => Exec["SetORACLE_ENVForVagrant"],
 }

 exec { "UnlockHR":
    command => "/vagrant/sql/setUpSQL.sh",
    require => Exec["AddVagrantToDBAGroup"],
    user => "vagrant",
 }




}



