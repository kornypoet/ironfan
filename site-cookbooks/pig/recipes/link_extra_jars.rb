#
# Cookbook Name::       pig
# Recipe::              link_extra_jars
# Author::              Philip (flip) Kromer - Infochimps, Inc
#
# Copyright 2011, Philip (flip) Kromer - Infochimps, Inc
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
#

#
# Link hbase, zookeeper, etc jars to $PIG_HOME/lib
#
node[:pig][:extra_jars].each do |jar|
  link File.join(node[:pig][:home_dir], 'lib', File.basename(jar)) do
    to        jar
    action    :create
  end
end

#
# Link hbase configuration to $PIG_HOME/conf
#
node[:pig][:extra_confs].each do |xml_conf|
  link "/usr/local/share/pig/conf/#{File.basename(xml_conf)}" do
    to xml_conf
    action :create
  end
end