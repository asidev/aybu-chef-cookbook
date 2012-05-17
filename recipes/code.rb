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


package "libzmq-dev"
package "imagemagick"
package "libenchant-dev"

python_virtualenv venv do
  action :create
end

python_pip "pip" do
  action :upgrade
  virtualenv venv_path
end

python_pip "psycopg2" do
  action :install
  virtualenv venv_path
end

python_pip "uWSGI" do
  action :install
  version node['aybu']['uwsgi_version']
  virtualenv venv_path
end

%w{aybu-core aybu-themes-pyramid aybu-website aybu-controlpanel aybu-manager aybu-manager-cli}.each do |repo|
  checkout = "#{node['aybu']['hg']['url']}/#{repo}"
  hg "#{code_dir}/#{repo}" do
    repository checkout
    reference node['aybu']['hg']['reference']
    key "#{node['aybu']['rootdir']}/.ssh/id_rsa"
    action :clone
    owner usr
    group grp
  end

  script "install_#{repo}" do
    interpreter "bash"
    user "root"
    cwd "#{code_dir}/#{repo}"
    code <<-EOH
      #{venv_path}/bin/pip install --extra-index-url #{chishop} -e ./
    EOH
    action :run
  end
end





