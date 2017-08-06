default['nodejs-deploy']['application']['name'] = ''
default['nodejs-deploy']['dir'] = '/usr/local/nodejs-deploy'
default['nodejs-deploy']['server']['root'] = '/usr/local/nodejs-deploy/defaul-root'
default['nodejs-deploy']['server']['host_name'] = ''
default['nodejs-deploy']['server']['port'] = 80
default['nodejs-deploy']['profile'] = 'production'

default['nodejs-deploy']['forward']['enable'] = false
default['nodejs-deploy']['forward']['from']['host'] = ''
default['nodejs-deploy']['forward']['from']['port'] = '80'
default['nodejs-deploy']['forward']['to']['host'] = ''
default['nodejs-deploy']['forward']['to']['port'] = '8080'

default['nodejs-deploy']['build']['max_memory'] = 2000

default['nodejs-deploy']['git']['url'] = ''
default['nodejs-deploy']['git']['project_location'] = ""
default['nodejs-deploy']['git']['branch'] = 'master'
default['nodejs-deploy']['git']['private'] = false
default['nodejs-deploy']['git']['databag']['name'] = 'databag'
default['nodejs-deploy']['git']['databag']['key'] = 'private'
default['nodejs-deploy']['git']['databag']['property'] = 'private_ssh_key'

default['nodejs']['install_method'] = 'binary'


