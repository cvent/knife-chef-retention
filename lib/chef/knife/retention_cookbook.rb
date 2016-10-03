# frozen_string_literal: true
require "chef/knife"

class Chef
  class Knife
    class CookbookRetention < Knife
      banner "knife cookbook retention [COOKBOOK] (options)"

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

      option :extra_versions,
             short: "-e VALUE",
             long: "--extra-versions VALUE",
             description: "The number of extra versions to keep (Default: 1)",
             default: 1

      def run
        cookbook_name = name_args[0] if name_args.length.positive?
        clobber = config[:clobber]
        extra_versions = config[:extra_versions].to_i

        ui.info "Running in Evaluation Mode no cookbooks will be deleted" unless clobber
        ui.info "Keeping the top #{extra_versions} unused versions" if extra_versions.positive?

        if cookbook_name
          cleanup_cookbook(cookbook_name, extra_versions, clobber)
        else
          cleanup_all_cookbooks(extra_versions, clobber)
        end
      end

      private

      def cleanup_all_cookbooks(extra_versions, clobber)
        Chef::CookbookVersion.list.keys.each do |cookbook_name|
          ui.info "Evaluating #{cookbook_name}"
          cleanup_cookbook(cookbook_name, extra_versions, clobber)
          ui.info ""
        end
      end

      def cleanup_cookbook(cookbook, extra_versions, clobber)
        latest_version = Chef::CookbookVersion.load(cookbook)
        ui.info "Latest Version: #{latest_version.version}"

        # Lets get all the cookbook versions that we could care less about
        out_of_retention_cookbooks(cookbook, extra_versions).each do |version|
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

      def out_of_retention_cookbooks(cookbook, extra_versions)
        # get all the version information for the cookbook
        unused_versions = cookbook_versions(cookbook).take_while do |version|
          # These are package that are not used and are considered old as they
          # are after the first used version still
          version unless version[:used]
        end

        save_some_versions(unused_versions, extra_versions)
      end

      def save_some_versions(versions, extra_versions)
        # Just removes the top X which since we sort is the top X newest versions
        Array(versions.slice(0, versions.length - extra_versions))
      end

      def cookbook_versions(cookbook_name)
        nodes = all_nodes_for_cookbook(cookbook_name)
        versions = Chef::CookbookVersion.available_versions(cookbook_name).map do |version|
          used_by_node = nodes.any? { |n| n["cookbooks"][cookbook_name]["version"] == version }

          {
            version: Chef::Version.new(version),
            used: used_by_node
          }
        end

        versions.sort_by { |v| v[:version] }
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
