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

notice('MODULAR: calico/controller.pp')

include calico
class neutron {}
class { 'neutron' :}

# Open etcd ports
firewall { '400 etcd':
  dport  => [
    $calico::params::etcd_port,
    $calico::params::etcd_peer_port
  ],
  proto  => 'tcp',
  action => 'accept',
} ->
# Deploy etcd cluster member
class { 'calico::etcd':
  node_role     => 'server',
  bind_host     => $calico::params::mgmt_ip,
  bind_port     => $calico::params::etcd_port,
  peer_host     => $calico::params::mgmt_ip,
  peer_port     => $calico::params::etcd_peer_port,
  cluster_nodes => $calico::params::etcd_servers_named_list,
}

# Open bgp port
firewall { '410 bird':
  dport  => '179',
  proto  => 'tcp',
  action => 'accept',
} ->
class { 'calico::bird':
  node_role  => 'rr',
  asnumber   => $calico::params::asnumber,
  src_addr   => $calico::params::ex_ip,
  rr_servers => $calico::params::non_client_peers,
  rr_clients => $calico::params::client_peers,
}

# stub package for 'neutron::plugins::ml2' class
package { 'neutron':
  name   => 'binutils',
  ensure => installed,
} ->
package { 'calico-control':
  ensure => installed,
} ->
class { 'neutron::plugins::ml2':
  type_drivers          => ['local','flat'],
  mechanism_drivers     => 'calico',
  tenant_network_types  => 'local',
  path_mtu              => $calico::params::physical_net_mtu,
  enable_security_group => true,
} ~> 
service { 'neutron-server':
  ensure => running,
  enable => true,
}
