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

notice('MODULAR: calico/repo.pp')

include calico

# Bird PPA
apt::source { 'bird-repo':
  location    => 'http://ppa.launchpad.net/cz.nic-labs/bird/ubuntu',
  repos       => 'main',
  release     => 'trusty',
  include_src => false,
}

# Calico PPA
apt::source { 'calico-repo':
  location    => "http://ppa.launchpad.net/project-calico/${calico::params::calico_release}/ubuntu",
  repos       => 'main',
  release     => 'trusty',
  include_src => false,
}
