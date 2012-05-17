#
# Cookbook Name:: aybu
# Recipe:: system
#
# Copyright 2012, Asidev s.r.l.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "redis::server"
restart_nginx = "#{node['aybu']['rootdir']}/bin/restart_nginx.sh"

cookbook_file restart_nginx do
  source "restart_nginx.sh"
  owner "root"
  group "root"
  mode "0775"
end

template "/etc/sudoers.d/aybu" do
  mode 0440
  source "sudoers.erb"
  owner "root"
  group "root"
  variables(
    :user => node['aybu']['system_user'],
    :script => restart_nginx
  )
end

