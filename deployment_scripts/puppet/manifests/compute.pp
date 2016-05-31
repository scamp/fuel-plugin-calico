#    Copyright 2016 Mirantis, Inc.
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

notice('MODULAR: calico/compute.pp')

include calico

Service {
  ensure => running,
  enable => true,
}

# Deploy etcd proxy
class { 'calico::etcd':
  node_role     => 'proxy',
  bind_host     => $calico::params::mgmt_ip,
  bind_port     => $calico::params::etcd_port,
  cluster_nodes => $calico::params::etcd_servers_named_list,
}

class { 'calico::bird':
  node_role  => 'client',
  asnumber   => $calico::params::asnumber,
  src_addr   => $calico::params::ex_ip,
  rr_servers => $calico::params::controller_ex_ips,
}

$cgroup_acl_string='["/dev/null", "/dev/full", "/dev/zero","/dev/random", "/dev/urandom","/dev/ptmx","/dev/kvm", "/dev/kqemu","/dev/rtc","/dev/hpet", "/dev/vfio/vfio","/dev/net/tun"]'

ini_setting { 'set_cgroup_acl_string':
  ensure  => present,
  path    => '/etc/libvirt/qemu.conf',
  setting => 'cgroup_device_acl',
  value   => $cgroup_acl_string,
} ~>
service { 'libvirtd': }

file_line { 'remove-linuxnet_interface_driver':
  line   => '#linuxnet_interface_driver removed by calico plugin',
  match  => '^linuxnet_interface_driver.?=',
  path   => '/etc/nova/nova.conf',
} ~>
service { 'nova-compute':}

package { ['calico-compute','calico-dhcp-agent','dnsmasq']:
  ensure => installed,
} ->
package { 'dnsmasq-base':
  ensure => latest,
} ->
file { '/etc/calico/felix.cfg':
  ensure  => present,
  content => template('calico/felix.cfg.erb'),
} ~>
service { 'calico-felix': } ->
service { 'calico-dhcp-agent': }