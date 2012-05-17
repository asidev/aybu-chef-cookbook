#
# Cookbook Name:: aybu
# Recipe:: install
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

api_domain = node['aybu']['api_domain']
root = node['aybu']['rootdir']
sites = "#{root}/sites"
logs = "#{root}/logs"
api_dir = "#{sites}/#{api_domain}"
api_logs_dir = "#{logs}/#{api_domain}"
grp = node["acl"]["hosting"]["group"]
usr = node['aybu']['system_user']
config_file = "#{api_dir}/production.ini"
restart_nginx = "#{node['aybu']['rootdir']}/bin/restart_nginx.sh"

zmq_conf = node['aybu']['zmq']
if not zmq_conf['status_pub_addr']
  zmq_conf['status_pub_addr'] = node['ipaddress']
end

directory api_dir do
  owner usr
  group grp
  mode 02755
  action :create
end

directory api_logs_dir do
  owner usr
  group grp
  mode 02755
  action :create
end

template "#{api_dir}/main.py" do
  source "main.py.erb"
  owner usr
  group grp
  mode 0664
  variables(
    :config => config_file
  )
end

template config_file do
  source "aybu_manager_config.ini.erb"
  mode 0664
  owner usr
  group grp
  variables(
    :database_password => node['aybu']['aybu_manager_db_password'],
    :zmq_conf => zmq_conf,
    :uwsgi_conf => node['aybu']['uwsgi'],
    :restart_nginx => restart_nginx
  )
end




