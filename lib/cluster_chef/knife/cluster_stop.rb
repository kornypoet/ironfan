#
# Author:: Philip (flip) Kromer (<flip@infochimps.com>)
# Copyright:: Copyright (c) 2011 Infochimps, Inc
# License:: Apache License, Version 2.0
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

require 'socket'
require 'chef/knife'
require 'json'
require 'formatador'

class Chef
  class Knife
    class ClusterStop < Knife      
      deps do
        require 'chef/json_compat'
        require 'tempfile'
        require 'highline'
        require 'net/ssh'
        require 'net/ssh/multi'
        Chef::Knife::Ssh.load_deps
      end rescue nil
      
      banner "knife cluster stop CLUSTER_NAME FACET_NAME (options)"
      
      attr_accessor :initial_sleep_delay

      option :yes,
        :long => "--yes",
        :description => "Skip confirmation that you want to stop the cluster."
      
      option :dry_run,
      :long => "--dry-run",
      :description => "Don't really run, just use mock calls"
      
      def h
        @highline ||= HighLine.new
      end
      
      
      def run
        require 'fog'
        require 'highline'
        require 'net/ssh/multi'
        require 'readline'
        $: << Chef::Config[:cluster_chef_path]+'/lib'
        require 'cluster_chef'
        $stdout.sync = true

        #
        # Put Fog into mock mode if --dry_run
        #
        if config[:dry_run]
          Fog.mock!
          Fog::Mock.delay = 0
        end
        
        #
        # Load the facet
        #
        
        cluster_name = @name_args
        raise "Launch the cluster as: knife cluster stop CLUSTER_NAME FACET_NAME (options)" if cluster_name.nil? #blank?

        target = ClusterChef.get_cluster_slice *@name_args
        target.cluster.resolve!

        unless config[:yes]
          puts "This action will stop the following nodes:"
          target.display
          puts "Unless these nodes are backed by EBS volumes, this will result in loss of all data not saved elsewhere. Even if they are EBS backed, there may still be some data loss."
          puts "Are you absolutely certain that you want to perform this action? (Type 'Yes' to confirm)"
          confirm = STDIN.readline
          if confirm.chomp != "Yes"
            puts "Aborting!"
            exit 1
          end
        end

        puts
        target.stop
        target.display

      end
    end
  end
end
