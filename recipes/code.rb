#
# Cookbook Name:: aybu
# Recipe:: code
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

code_dir = "#{node['aybu']['rootdir']}/code"
venv = 'aybu'
venv_path = "#{node[:python][:virtualenvs_dir]}/#{venv}"
chishop = "http://chishop.asidev.net/pypi"
usr = node['aybu']['system_user']
grp = node["acl"]["hosting"]["group"]

python_virtualenv venv do
  action :create
  no_site_packages true
  notifies :run, "script[install_extra_venv_software]", :immediately
  
end

script "install_extra_venv_software" do
  interpreter "bash"
  user usr
  code <<-EOH
    source #{venv_path}/bin/activate
    pip install -U pip
    pip install psycopg2
    pip install http://projects.unbit.it/downloads/uwsgi-lts.tar.gz
  EOH
  notifies :run, "script[fix_venv_perms]", :immediately
  action :nothing
end

script "fix_venv_perms" do
  interpreter "bash"
  user "root"
  cwd "/"
  code <<-EOH
    chgrp -R #{grp} #{venv_path}
  EOH
  action :nothing
end

%w{aybu-core aybu-themes-pyramid aybu-website aybu-controlpanel aybu-manager aybu-manager-cli}.each do |repo|
  checkout = "#{node['aybu']['hg']['url']}/#{repo}"
  hg "#{code_dir}/#{repo}" do
    repository checkout
    reference node['aybu']['hg']['branch']
    key "#{node['aybu']['rootdir']}/.ssh/id_rsa"
    action :clone
    owner usr
    group grp
    not_if "test -d #{checkout}"
    notifies :run, "script[install_#{repo}]", :immediately
  end

  script "install_#{repo}" do
    interpreter "bash"
    user usr
    cwd checkout
    code <<-EOH
      source #{venv_path}/bin/activate
      pip install --extra-index-url #{chishop} -e ./
    EOH
    action :nothing
  end
end





