require "support/shared/integration/integration_helper"
require "chef/mixin/shell_out"

describe "LWRPs with inline resources" do
  include IntegrationSupport
  include Chef::Mixin::ShellOut

  let(:chef_dir) { File.expand_path("../../../../bin", __FILE__) }

  let(:chef_client) { "bundle exec chef-client --minimal-ohai" }

  when_the_repository "has a cookbook with a unified_mode resource with a delayed notification" do
    before do
      directory "cookbooks/x" do

        file "resources/unified_mode.rb", <<-EOM
          unified_mode true
          resource_name :unified_mode
          provides :unified_mode

          action :doit do
            klass = new_resource.class
            var = "foo"
            ruby_block "second block" do
              block do
                puts "\nsecond: \#\{var\}"
              end
              action :nothing
            end
            var = "bar"
            ruby_block "first block" do
              block do
                puts "\nfirst: \#\{var\}"
              end
              notifies :run, "ruby_block[second block]", :delayed
            end
            var = "baz"
          end
        EOM

        file "recipes/default.rb", <<-EOM
          unified_mode "whatever"
        EOM

      end # directory 'cookbooks/x'
    end

    it "should complete with success" do
      file "config/client.rb", <<~EOM
        local_mode true
        cookbook_path "#{path_to('cookbooks')}"
        log_level :warn
      EOM

      result = shell_out("#{chef_client} -c \"#{path_to('config/client.rb')}\" --no-color -F doc -o 'x::default'", cwd: chef_dir)
      # the "first block" resource runs before the assignment to baz in compile time
      expect(result.stdout).to include("first: bar")
      # we should not run the "first block" at compile time
      expect(result.stdout).not_to include("first: baz")
      # (and certainly should run it this early)
      expect(result.stdout).not_to include("first: foo")
      # the delayed notification should still fire and run after everything else
      expect(result.stdout).to include("second: baz")
      # the action :nothing should suppress any other running of the second block
      expect(result.stdout).not_to include("second: foo")
      expect(result.stdout).not_to include("second: bar")
      result.error!
    end
  end

  when_the_repository "has a cookbook with a no unified_mode resource with an immediate notification" do
    before do
      directory "cookbooks/x" do

        file "resources/unified_mode.rb", <<-EOM
          unified_mode true
          resource_name :unified_mode
          provides :unified_mode
          action :doit do
            klass = new_resource.class
            var = "foo"
            ruby_block "second block" do
              block do
                puts "\nsecond: \#\{var\}"
              end
              action :nothing
            end
            var = "bar"
            ruby_block "first block" do
              block do
                puts "\nfirst: \#\{var\}"
              end
              notifies :run, "ruby_block[second block]", :immediate
            end
            var = "baz"
          end
        EOM

        file "recipes/default.rb", <<-EOM
          unified_mode "whatever"
        EOM

      end # directory 'cookbooks/x'
    end

    it "should complete with success" do
      file "config/client.rb", <<~EOM
        local_mode true
        cookbook_path "#{path_to('cookbooks')}"
        log_level :warn
      EOM

      result = shell_out("#{chef_client} -c \"#{path_to('config/client.rb')}\" --no-color -F doc -o 'x::default'", cwd: chef_dir)
      # the "first block" resource runs before the assignment to baz in compile time
      expect(result.stdout).to include("first: bar")
      # we should not run the "first block" at compile time
      expect(result.stdout).not_to include("first: baz")
      # (and certainly should run it this early)
      expect(result.stdout).not_to include("first: foo")
      # the immediate notifiation fires immediately
      expect(result.stdout).to include("second: bar")
      # the action :nothing should suppress any other running of the second block
      expect(result.stdout).not_to include("second: foo")
      expect(result.stdout).not_to include("second: baz")
      result.error!
    end
  end

  when_the_repository "has a cookbook with a normal resource with an delayed notification with global resource converge mode off" do
    before do
      directory "cookbooks/x" do

        file "resources/unified_mode.rb", <<-EOM
          resource_name :unified_mode
          provides :unified_mode

          action :doit do
            klass = new_resource.class
            var = "foo"
            ruby_block "second block" do
              block do
                puts "\nsecond: \#\{var\}"
              end
              action :nothing
            end
            var = "bar"
            ruby_block "first block" do
              block do
                puts "\nfirst: \#\{var\}"
              end
              notifies :run, "ruby_block[second block]", :delayed
            end
            var = "baz"
          end
        EOM

        file "recipes/default.rb", <<-EOM
          unified_mode "whatever"
        EOM

      end # directory 'cookbooks/x'
    end

    it "should complete with success" do
      file "config/client.rb", <<~EOM
        resource_unified_mode_default true
        local_mode true
        cookbook_path "#{path_to('cookbooks')}"
        log_level :warn
      EOM

      result = shell_out("#{chef_client} -c \"#{path_to('config/client.rb')}\" --no-color -F doc -o 'x::default'", cwd: chef_dir)
      # the "first block" resource runs before the assignment to baz in compile time
      expect(result.stdout).to include("first: bar")
      # we should not run the "first block" at compile time
      expect(result.stdout).not_to include("first: baz")
      # (and certainly should run it this early)
      expect(result.stdout).not_to include("first: foo")
      # the delayed notification should still fire and run after everything else
      expect(result.stdout).to include("second: baz")
      # the action :nothing should suppress any other running of the second block
      expect(result.stdout).not_to include("second: foo")
      expect(result.stdout).not_to include("second: bar")
      result.error!
    end
  end

  when_the_repository "has a cookbook with a normal resource with an immediate notification with global resource converge mode off" do
    before do
      directory "cookbooks/x" do

        file "resources/unified_mode.rb", <<-EOM
          resource_name :unified_mode
          provides :unified_mode
          action :doit do
            klass = new_resource.class
            var = "foo"
            ruby_block "second block" do
              block do
                puts "\nsecond: \#\{var\}"
              end
              action :nothing
            end
            var = "bar"
            ruby_block "first block" do
              block do
                puts "\nfirst: \#\{var\}"
              end
              notifies :run, "ruby_block[second block]", :immediate
            end
            var = "baz"
          end
        EOM

        file "recipes/default.rb", <<-EOM
          unified_mode "whatever"
        EOM

      end # directory 'cookbooks/x'
    end

    it "should complete with success" do
      file "config/client.rb", <<~EOM
        resource_unified_mode_default true
        local_mode true
        cookbook_path "#{path_to('cookbooks')}"
        log_level :warn
      EOM

      result = shell_out("#{chef_client} -c \"#{path_to('config/client.rb')}\" --no-color -F doc -o 'x::default'", cwd: chef_dir)
      # the "first block" resource runs before the assignment to baz in compile time
      expect(result.stdout).to include("first: bar")
      # we should not run the "first block" at compile time
      expect(result.stdout).not_to include("first: baz")
      # (and certainly should run it this early)
      expect(result.stdout).not_to include("first: foo")
      # the immediate notifiation fires immediately
      expect(result.stdout).to include("second: bar")
      # the action :nothing should suppress any other running of the second block
      expect(result.stdout).not_to include("second: foo")
      expect(result.stdout).not_to include("second: baz")
      result.error!
    end
  end

  when_the_repository "has global resource converge mode off" do
    before do
      directory "cookbooks/x" do

        file "recipes/default.rb", <<-EOM
          var = "foo"
          ruby_block "first block" do
            block do
              puts "\nfirst: \#\{var\}"
            end
          end
          var = "bar"
        EOM

      end # directory 'cookbooks/x'
    end

    it "should complete with success" do
      file "config/client.rb", <<~EOM
        resource_unified_mode_default true
        local_mode true
        cookbook_path "#{path_to('cookbooks')}"
        log_level :warn
      EOM

      result = shell_out("#{chef_client} -c \"#{path_to('config/client.rb')}\" --no-color -F doc -o 'x::default'", cwd: chef_dir)
      # in recipe mode we should still run normally with a compile/converge mode
      expect(result.stdout).to include("first: bar")
      expect(result.stdout).not_to include("first: foo")
      result.error!
    end
  end
end
