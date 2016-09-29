# frozen_string_literal: true
require "chef/knife"

class Chef
  class Knife
    class RetentionCookbook < Knife
      banner "knife retention cookbook [COOKBOOK] (options)"

      deps do
        require "chef/search/query"
        require "chef/knife/search"
        require "chef/cookbook_version"
      end

      option :clobber,
             long: "--clobber",
             description: "Actually delete cookbooks from the Chef Server forever",
             boolean: true,
             default: false

      def run
        cookbook_name = name_args[0] if name_args.length.positive?
        clobber = config[:clobber]

        ui.info "Running in Evaluation Mode no cookbooks will be deleted" unless clobber

        if cookbook_name
          cleanup_cookbook(cookbook_name, clobber)
        else
          cleanup_all_cookbooks(clobber)
        end
      end

      private

      def cleanup_all_cookbooks(clobber)
        Chef::CookbookVersion.list.keys.each do |cookbook_name|
          ui.info "Evaluating #{cookbook_name}"
          cleanup_cookbook(cookbook_name, clobber)
          ui.info ""
        end
      end

      def cleanup_cookbook(cookbook, clobber)
        latest_version = Chef::CookbookVersion.load(cookbook)
        ui.info "Latest Version: #{latest_version.version}"

        # Lets get all the cookbook versions that we could care less about
        find_unused_versions(cookbook).each do |version|
          destroy_cookbook_version(cookbook, version[:version], clobber)
        end
      end

      def destroy_cookbook_version(cookbook, version, clobber)
        if clobber
          delete_object(Chef::CookbookVersion, "#{cookbook} version #{version}", "cookbook") do
            rest.delete("cookbooks/#{cookbook}/#{version}")
          end
        else
          ui.info "Unused Version: #{version}"
        end
      end

      def max_results
        Chef::Node.list.count || 1000
      end

      def search_args
        {
          rows: max_results,
          filter_result: {
            name: ["name"],
            cookbooks: ["cookbooks"],
            ohai_time: ["ohai_time"]
          }
        }
      end

      def find_unused_versions(cookbook)
        # get all the version information for the cookbook
        version_info_for_cookbook(cookbook).take_while do |version|
          # These are package that are not used and are considered old as they
          # are after the first used version still
          version unless version[:used]
        end
      end

      def version_info_for_cookbook(cookbook_name)
        nodes = all_nodes_for_cookbook(cookbook_name)
        versions = Chef::CookbookVersion.available_versions(cookbook_name).map do |version|
          used_by_node = nodes.any? { |n| n["cookbooks"][cookbook_name]["version"] == version }

          {
            version: Chef::Version.new(version),
            used: used_by_node
          }
        end

        # Sort and take out the latests version so we do not delete it
        versions.sort_by { |v| v[:version] }[0..-2]
      end

      def search_nodes(query)
        Chef::Search::Query.new.search(:node, query, search_args).first
      end

      def all_nodes_for_cookbook(cookbook_name)
        search_nodes("cookbooks_#{cookbook_name}:*")
      end
    end
  end
end
