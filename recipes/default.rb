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


include_recipe "aybu::user"
include_recipe "aybu::system"
include_recipe "aybu::cgroups"
include_recipe "aybu::database"
include_recipe "aybu::code"
include_recipe "aybu::install"
include_recipe "aybu::utils"

