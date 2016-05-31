#    Copyright 2015 Mirantis, Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

class calico::bird (
  $node_role,
  $asnumber = '64511',
  $src_addr = undef,
  $rr_clients = undef,
  $rr_servers = undef,
  ) {

  package { 'bird':
    ensure => installed,
  } ->

  file { '/etc/bird/custom.conf':
    ensure => present,
  }  
  file { '/etc/bird/bird.conf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template("calico/bird-${node_role}.conf.erb"),
  } ~>

  service { 'bird':
    ensure     => running,
    enable     => true,
    hasrestart => false,
    restart    => '/usr/sbin/birdc configure'
  }

}