#
# Cookbook Name:: nodejs-deploy
# Recipe:: default
#
# Copyright 2017, glmanhtu
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'nodejs-deploy::server'
include_recipe 'nodejs-deploy::forward'
include_recipe "nodejs::npm"

profile = node['nodejs-deploy']['profile']
max_memory = node['nodejs-deploy']['build']['max_memory']
source_dir = "#{node['nodejs-deploy']['dir']}/#{node['nodejs-deploy']['application']['name']}"
client_dir = node['nodejs-deploy']['git']['project_location']
repo = "#{source_dir}/repo"

npm_package_dir = "/usr/local/nodejs-binary-#{node['nodejs']['version']}/bin";

data_bag_name = node['nodejs-deploy']['git']['databag']['name']
data_bag_key = node['nodejs-deploy']['git']['databag']['key']
data_bag_property = node['nodejs-deploy']['git']['databag']['property']

private_ssh_key = ""

directory source_dir do  
  mode '0755'
  action :create
  recursive true
end

package 'Install Python' do
    package_name 'python'
end


if node['nodejs-deploy']['git']['private']
  encrypted_key = Chef::EncryptedDataBagItem.load(data_bag_name, data_bag_key)
  private_ssh_key = encrypted_key[data_bag_property]

  file "/tmp/git_private_key" do
    mode "400"
    sensitive true
    content private_ssh_key
  end

  file "/tmp/git_wrapper.sh" do
    mode "0755"
    sensitive true
    content "#!/bin/sh\nexec /usr/bin/ssh -o \"StrictHostKeyChecking=no\" -i /tmp/git_private_key \"$@\""
  end

  git repo do
    repository node['nodejs-deploy']['git']['url']
    branch node['nodejs-deploy']['git']['branch']
    action :sync
    ssh_wrapper "/tmp/git_wrapper.sh"
  end


  file "/tmp/git_private_key" do
    action :delete
  end
else
  
  file "/tmp/git_wrapper.sh" do
    mode "0755"
    content "#!/bin/sh\nexec /usr/bin/ssh -o \"StrictHostKeyChecking=no\" \"$@\""
  end

  git repo do
    repository node['nodejs-deploy']['git']['url']
    branch node['nodejs-deploy']['git']['branch']
    action :sync
    ssh_wrapper "/tmp/git_wrapper.sh"
  end
end

["bower", "gulp"].each do |npm_package|
    nodejs_npm npm_package
end

bash 'Prepare project' do
  code "cd #{source_dir}/repo/#{client_dir} && #{npm_package_dir}/npm install node-gyp"
end

nodejs_npm "Install project npm dependencies" do
  path "#{source_dir}/repo/#{client_dir}"
  json true
end

bash 'Install bower package dependencies' do
  code "cd #{source_dir}/repo/#{client_dir} && #{npm_package_dir}/bower install --allow-root"
end

bash 'Build project' do
  code "cd #{source_dir}/repo/#{client_dir} && #{npm_package_dir}/gulp build --max_old_space_size=#{max_memory} --env=#{profile}"
end

bash 'Delete old server' do
  code "rm -rf #{node['nodejs-deploy']['server']['root']}/*"
end

bash 'Deploy new server' do
  code "cp -R #{source_dir}/repo/#{client_dir}/release/*  #{node['nodejs-deploy']['server']['root']}/"
end

service 'nginx' do
  action :restart
end