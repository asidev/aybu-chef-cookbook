
default['aybu']['rootdir'] = "/var/www/aybu"
default['aybu']['venv'] = 'aybu'
default['aybu']['system_user'] = 'aybu'
default['aybu']['system_group'] = 'asidev'
default['aybu']['hg']['reference'] = 'release'
default['aybu']['hg']['url'] = 'ssh://hg@bitbucket.org/asidev'
default['aybu']['uwsgi_version'] = "1.4.1"
default['aybu']['api_domain'] = 'api.aybu.it'
default['aybu']['api_http'] = "https"
default['aybu']['database_prefix'] = 'aybu__'
default['aybu']['backup_dir'] = "/var/backups/aybu"
default['aybu']['smtp_host'] = "localhost"
default['aybu']['smtp_port'] = "25"
default['aybu']['cgroup_rel_path'] = "/sites/aybu"
default['aybu']['cgroup_controllers'] = ['cpu', 'blkio', 'memory']

case platform
when "ubuntu"
  default['aybi']['process_manager'] = 'upstart'
else
  default['aybi']['process_manager'] = 'supervisor'
end

default['aybu']['supervisor_prefix'] = 'aybu_env'
default['aybu']['upstart_prefix'] = 'aybu'

default['aybu']['zmq']['queue_addr'] = "127.0.0.1"
default['aybu']['zmq']['daemon_addr'] = "127.0.0.1"
default['aybu']['zmq']['queue_port'] = 8997
default['aybu']['zmq']['daemon_port'] = 8998
default['aybu']['zmq']['status_pub_addr'] = "0.0.0.0"  # autogen on ip from ohai
default['aybu']['zmq']['status_pub_port'] = 8999
default['aybu']['zmq']['timeout'] = 1000
default['aybu']['zmq']['result_ttl'] = 43200

default['aybu']['redis']['addr'] = "127.0.0.1"
default['aybu']['redis']['port'] = "6379"

default['aybu']['uwsgi']['fastrouter']['addr'] = "127.0.0.1"
default['aybu']['uwsgi']['fastrouter']['base_port'] = 15000
default['aybu']['uwsgi']['subscription_server']['addr'] = "127.0.0.1"
default['aybu']['uwsgi']['subscription_server']['base_port'] = 17000
default['aybu']['uwsgi']['stats_server']['addr'] = "127.0.0.1"
default['aybu']['uwsgi']['stats_server']['emperor_base_port'] = 19000
default['aybu']['uwsgi']['stats_server']['fastrouter_base_port'] = 21000
default['aybu']['uwsgi']['stats_server']['instance_base_port'] = 23000

default['aybu']['uwsgi']['options']['post-buffering'] = 1024
default['aybu']['uwsgi']['options']['processes'] = 1
default['aybu']['uwsgi']['options']['threads'] = 5
default['aybu']['uwsgi']['options']['reload-on-rss'] = 96

default['aybu']['varnish']['address'] = "127.0.0.1"
default['aybu']['varnish']['port'] = "80"

# override various attributes
set['supervisor']['admin_group'] = "#{node['aybu']['system_group']}"
set['nginx']['additional_includes'] = ["#{node['aybu']['rootdir']}/configs/nginx/*.conf"]