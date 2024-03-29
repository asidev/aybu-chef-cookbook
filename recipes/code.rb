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
venv = node['aybu']['venv']
venv_path = "#{node[:python][:virtualenvs_dir]}/#{venv}"
chishop = "http://chishop.asidev.net/simple"
usr = node['aybu']['system_user']
grp = node["acl"]["hosting"]["group"]

package "libzmq-dev"
package "imagemagick"
package "libenchant-dev"

python_virtualenv venv_path do
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

%w{aybu-core aybu-themes aybu-website aybu-controlpanel aybu-manager aybu-manager-cli}.each do |repo|
  checkout = "#{node['aybu']['hg']['url']}/#{repo}"
  pkg_name = repo.split("-")[0..1].join("_")
  repo_path = "#{code_dir}/#{repo}"

  git "#{code_dir}/#{repo}" do
    repository "git://github.com/asidev/#{repo}.git"
    reference "master"
    action :sync
    user usr
    group grp
  end

  script "install_#{repo}" do
    interpreter "bash"
    user "root"
    cwd repo_path
    code <<-EOH
      #{venv_path}/bin/pip install -e ./
    EOH
    not_if "test -f #{repo_path}/.installed_do_not_remove"
    action :run
  end

  file "#{repo_path}/.installed_do_not_remove" do
    action :create_if_missing
    owner "root"
    group "root"
    mode "0600"
  end

end
