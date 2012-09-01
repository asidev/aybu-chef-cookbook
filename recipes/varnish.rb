#
# Cookbook Name:: aybu
# Recipe:: varnish
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

additional_includes = node['varnish']['additional_includes']
if not additional_includes.include? "aybu.vcl"
  additional_includes << "aybu.vcl"
  node.set['varnish']['additional_includes'] = additional_includes
end

template "#{node["varnish"]["dir"]}/aybu.vcl" do
  source "aybu.vcl.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :run, "execute[reload_vcl]"
end
