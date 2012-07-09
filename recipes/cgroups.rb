#
# Cookbook Name:: aybu
# Recipe:: cgroups
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

cgroups = node['cgroups']['basepath']
controllers = node['aybu']['cgroup_controllers']
path = node['aybu']['cgroup_rel_path']
usr = node['aybu']['system_user']
grp = node["acl"]["hosting"]["group"]

controllers.each do |ctrl|
  cg = "#{cgroups}/#{ctrl}#{path}"
  directory cg do
    owner usr
    group grp
    mode "0775"
    action :create
    recursive true
  end
end

template "/etc/rc.local.d/aybu_create_cgroups.sh" do
  owner "root"
  group "root"
  source "aybu_create_cgroups.sh.erb"
  mode 0775
  variables(
    :user => usr,
    :group => grp,
    :root => cgroups
  )
end

template "/usr/local/bin/fix_sites_cgroup_perms.sh" do
  owner "root"
  group "root"
  source "fix_sites_cgroup_perms.sh.erb"
  mode 0775
  variables(
    :user => usr,
    :path => path,
    :root => path.split('/')[1]
  )
end

cron "fix_cgroup_perms" do
  minute "*/2"
  command "/usr/local/bin/fix_sites_cgroup_perms.sh"
end
