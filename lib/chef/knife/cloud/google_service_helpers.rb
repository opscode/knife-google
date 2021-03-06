# frozen_string_literal: true
#
# Author:: Chef Partner Engineering (<partnereng@chef.io>)
# Copyright:: Copyright (c) Chef Software Inc.
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

class Chef::Knife::Cloud
  module GoogleServiceHelpers
    REQUIRED_KEYS = [:gce_project].freeze

    def create_service_instance
      Chef::Knife::Cloud::GoogleService.new(
        project:       config[:gce_project],
        zone:          config[:gce_zone],
        wait_time:     config[:request_timeout],
        refresh_rate:  config[:request_refresh_rate],
        max_pages:     config[:gce_max_pages],
        max_page_size: config[:gce_max_page_size]
      )
    end

    def check_for_missing_config_values!(*keys)
      keys_to_check = REQUIRED_KEYS + keys

      missing = keys_to_check.select { |x| config[x].nil? }

      unless missing.empty?
        message = "The following required parameters are missing: #{missing.join(", ")}"
        ui.error(message)
        raise message
      end
    end

    def private_ip_for(server)
      server.network_interfaces.first.network_ip
    rescue NoMethodError
      "unknown"
    end

    def public_ip_for(server)
      server.network_interfaces.first.access_configs.first.nat_ip
    rescue NoMethodError
      "unknown"
    end

    def valid_disk_size?(size)
      size.between?(10, 10_000)
    end
  end
end
