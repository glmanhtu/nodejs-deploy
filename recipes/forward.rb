#
# Cookbook Name:: nodejs-deploy
# Recipe:: forward
#
# Copyright 2017, glmanhtu
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'chef_nginx::source'

if node['nodejs-deploy']['forward']['enable']
    template "/etc/nginx/sites-available/#{node['nodejs-deploy']['forward']['from']['host']}.forward.conf" do
      source 'server-forward.conf.erb'
      mode '0755'      
      variables({
        server_port: node['nodejs-deploy']['forward']['from']['port'],
        server_hostname: node['nodejs-deploy']['forward']['from']['host'],
        server_forward_host: node['nodejs-deploy']['forward']['to']['host'],
        server_forward_port: node['nodejs-deploy']['forward']['to']['port']
      })
    end

    nginx_site "#{node['nodejs-deploy']['forward']['from']['host']}.forward.conf" do
      enable true
    end
else
  Chef::Log.debug('Ignore forwarding host')
end