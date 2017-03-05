#
# Cookbook Name:: nodejs-deploy
# Recipe:: server
#
# Copyright 2017, glmanhtu
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nginx::default'

directory node['nodejs-deploy']['server']['root'] do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
end

package 'nginx' do
  action :install
end

template "/etc/nginx/sites-available/#{node['nodejs-deploy']['server']['host_name']}.conf" do
  source 'server-site.conf.erb'
  mode '0755'
  owner 'root'
  group 'root'
  variables({
    server_port: node['nodejs-deploy']['server']['port'],
    server_root: node['nodejs-deploy']['server']['root'],
    server_hostname: node['nodejs-deploy']['server']['host_name']
  })
end

nginx_site "#{node['nodejs-deploy']['server']['host_name']}.conf" do
  enable true
end