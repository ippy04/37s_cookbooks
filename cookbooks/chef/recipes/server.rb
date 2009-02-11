include_recipe "runit"
include_recipe "apache2"
include_recipe "passenger"

directory "/etc/chef" do
  owner "root"
  mode 0750
end

directory "/var/chef/log" do
  owner "root"
  mode 0750
end

template "/etc/chef/server.rb" do
  owner "root"
  mode 0640
  source "server.rb.erb"
  action :create
end

template "/etc/chef/client.rb" do
  owner "root"
  mode 0640
  source "client.rb.erb"
  action :create
end

gem_package "stompserver" do
  action :install
end
runit_service "stompserver"

package "couchdb"

directory "/var/lib/couchdb" do
  owner "couchdb"
  group "couchdb"
  recursive true
end

service "couchdb" do
  supports :restart => true, :status => true
  action [ :enable, :start ]
end

runit_service "chef-indexer" 

template "/etc/apache2/sites-available/chef-server" do
  source 'chef-server-vhost.conf.erb'
  action :create
  owner "root"
  group "www-data"
  mode 0640
end

template "/usr/lib/ruby/gems/1.8/gems/chef-server-0.5.3/lib/config.ru" do
  source 'config.ru.erb'
  action :create
  owner "root"
  group "www-data"
  mode 0644
end

template "/usr/lib/ruby/gems/1.8/gems/chef-server-0.5.3/lib/init.rb" do
  source 'init.rb.erb'
  action :create
  owner "root"
  group "www-data"
  mode 0644
end

apache_site "chef-server"