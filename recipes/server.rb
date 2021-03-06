#
# Cookbook Name:: nodejs-deploy
# Recipe:: server
#
# Copyright 2017, glmanhtu
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'chef_nginx::source'

directory node['nodejs-deploy']['server']['root'] do  
  mode '0755'
  action :create
  recursive true
end

template "/etc/nginx/sites-available/#{node['nodejs-deploy']['server']['host_name']}.conf" do
  source 'server-site.conf.erb'
  mode '0755'  
  variables({
    server_port: node['nodejs-deploy']['server']['port'],
    server_root: node['nodejs-deploy']['server']['root'],
    server_hostname: node['nodejs-deploy']['server']['host_name']
  })
end

nginx_site "#{node['nodejs-deploy']['server']['host_name']}.conf" do
  enable true
end