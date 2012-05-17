#
# Cookbook Name:: aybu
# Recipe:: database
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
node.set_unless['aybu']['aybu_manager_db_password'] = secure_password

connection_info = {
  :host => "127.0.0.1", 
  :port => 5432, 
  :username => 'postgres', 
  :password => node['postgresql']['password']['postgres']
}

postgresql_database_user "aybu_manager" do
	connection connection_info
	password node['aybu']['aybu_manager_db_password']
	action :create
end

postgresql_database "aybu_manager" do
  connection connection_info
  action :create
  owner "aybu_manager"
end