#
# Cookbook Name:: aybu
# Recipe:: utils
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

cookbook_file "/usr/local/bin/sites_mem_usage.sh" do
  source "sites_mem_usage.sh"
  owner "root"
  group "root"
  mode 0755
end

template "#{node['check_mk']['plugins_dir']}/check_aybu" do
  source "check_mk_agent_plugin.py.erb"
  owner "root"
  group "root"
  mode 0755
end

