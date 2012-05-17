#
# Cookbook Name:: aybu
# Recipe:: default
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

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
include_recipe "acl::dedicated_hosting"

grp = node["acl"]["hosting"]["group"]
usr = node['aybu']['system_user']
venv_path = "#{node[:python][:virtualenvs_dir]}"
node.set_unless['aybu']['system_user_password'] = secure_password
root = node['aybu']['rootdir']

user usr do
  action :create
  comment "AyBu"
  uid 999
  gid grp
  home root
  shell "/bin/bash"
  password node['aybu']['user_password']
  supports :manage_home => true
  notifies :run, "script[setfacl-#{venv_path}-aybu]", :immediately
end

script "setfacl-#{venv_path}-aybu" do
  action :nothing
  interpreter "bash"
  user "root"
  code <<-EOH
  setfacl -R -m default:user:#{usr}:rwx -m user:#{usr}:rwx #{venv_path}
  EOH
end

directory "#{root}/.ssh" do
  owner usr
  group grp
  mode "0700"
  action :create
  recursive true
end

cookbook_file "#{root}/.ssh/id_rsa" do
  source "ssh_key.pem"
  mode "0600"
  owner usr
  group grp
end

%w{archives bin code configs logs run sites system}.each do |dir|
  directory "#{root}/#{dir}" do
    owner usr
    group grp
    mode 02775
    action :create
  end
end

unless Chef::Config[:solo]
  ruby_block "save node data" do
    block do
      node.save
    end
    action :create
  end
end

include_recipe "aybu::code"