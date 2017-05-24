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

npm_package_dir = "/usr/local/nodejs-binary-#{node['nodejs']['version']}/bin";

directory source_dir do
  owner 'ubuntu'
  group 'ubuntu'
  mode '0755'
  action :create
  recursive true
end

package 'Install Python' do
    package_name 'python'
end

file "/tmp/git_wrapper.sh" do
  owner "ubuntu"
  mode "0755"
  content "#!/bin/sh\nexec /usr/bin/ssh -o \"StrictHostKeyChecking=no\" -i /home/ubuntu/.ssh/id_rsa \"$@\""
end

git "#{source_dir}/repo" do
  repository node['nodejs-deploy']['git']['url']
  branch node['nodejs-deploy']['git']['branch']
  action :sync
  ssh_wrapper "/tmp/git_wrapper.sh"
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