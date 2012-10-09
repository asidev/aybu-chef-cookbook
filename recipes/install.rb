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
configs = "#{root}/configs"
api_dir = "#{sites}/#{api_domain}"
api_logs_dir = "#{logs}/#{api_domain}"
grp = node["acl"]["hosting"]["group"]
usr = node['aybu']['system_user']
config_file = "#{api_dir}/production.ini"
restart_nginx = "#{node['aybu']['rootdir']}/bin/restart_nginx.sh"
venv = node['aybu']['venv']
venv_path = "#{node[:python][:virtualenvs_dir]}/#{venv}"

zmq_conf = node['aybu']['zmq']

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

script "populate_manager_db" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    #{venv_path}/bin/python #{root}/code/aybu-manager/create_initial_data.py #{config_file}
  EOH
  action :run
  not_if "test -f #{root}/code/aybu-manager/.populated_do_not_remove"
end

file "#{root}/code/aybu-manager/.populated_do_not_remove" do
  action :create_if_missing
  owner "root"
  group "root"
  mode "0600"
end

directory "#{configs}/nginx" do
  owner usr
  group grp
  mode 0775
  action :create
end

directory "#{configs}/uwsgi" do
  owner usr
  group grp
  mode 0775
  action :create
end

directory "#{configs}/supervisor" do
  owner usr
  group grp
  mode 0775
  action :create
end

case node['aybu']['process_manager']
when "supervisor"
  link "#{node['supervisor']['dir']}/aybu" do
    to "#{configs}/supervisor"
  end

  supervisor_program "api_rest" do
    command "#{venv_path}/bin/uwsgi --ini-paste #{config_file}"
    stopsignal :INT
    user 'aybu'
    autostart true
    autorestart true
    action [:enable, :start]
  end

  supervisor_program "api_worker" do
    command "#{venv_path}/bin/aybu_manager_worker #{config_file}"
    stopsignal :INT
    user 'aybu'
    autostart true
    autorestart true
    redirect_stderr true
    action [:enable, :start]
  end

  supervisor_group "manager" do
    programs ["api_rest", "api_worker"]
  end

when "upstart"
  directory "/etc/init" do
    user "root"
    group node["acl"]["hosting"]["group"]
    mode 0775
  end

  {'api_worker' => 'aybu_manager_worker',
   'api_server' => 'uwsgi --die-on-term --ini-paste'}.each do |srv, cmd|
    template "/etc/init/aybu_#{srv}.conf" do
      source "#{srv}.upstart.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :cmd => "#{venv_path}/bin/#{cmd}",
        :config_file => config_file
      )
    end

    link "/etc/init.d/aybu_#{srv}" do
      to "/lib/init/upstart-job"
    end

    service "aybu_#{srv}" do
      action [:enable, :start]
    end
  end

  #install the upstart script to create cgroups
  template "/etc/init/aybu_create_cgroups.conf" do
    owner "root"
    group "root"
    source "aybu_create_cgroups.upstart.erb"
    variables(
      :user => usr,
      :group => grp,
      :root => node['cgroups']['basepath']
    )
  end

end

firewall_rule "aybu_manager_zmq" do
    port node['aybu']['zmq']['status_pub_port']
    action :allow
    protocol :tcp
end

template "#{configs}/nginx/api.aybu.it.conf" do
  source "manager_api_nginx.conf.erb"
  owner usr
  group group
  mode 0644
  notifies :reload, "service[nginx]"
end

script "set_venv_acl_aybu" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
    find #{venv_path} -type d -print0 | xargs -0 setfacl -m user:#{usr}:rwx -m default:user:#{usr}:rwx
    find #{venv_path} -type f -print0 | xargs -0 setfacl -m user:#{usr}:rwx
  EOH
  action :run
end