current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "admin"
client_key               "#{current_dir}/admin.pem"
validation_client_name   "cheforg-validator"
validation_key           "#{current_dir}/cheforg-validator.pem"
chef_server_url          "https://chef-server.devdomain.tk/organizations/cheforg"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntaxcache"
cookbook_path            ["#{current_dir}/../cookbooks"]