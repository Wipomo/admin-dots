#!/usr/bin/env ruby

require 'erb'
require 'yaml'

# License info:
# Cloned from https://github.com/mattly/nginx_config_generator/blob/9057034a496fb12bce495c91e7cd6b0d9439cd4b/LICENSE
# Many changes since.

def error(message) puts(message) || exit end
def file(file) "#{File.dirname(__FILE__)}/#{file}" end

if ARGV.include? '--example'
  example = file 'config.yml.example'
  error open(example).read 
end

env_in  = ENV['NGINX_CONFIG_YAML']
env_out = ENV['NGINX_CONFIG_FILE']

error "Usage: generate_nginx_config [config file] [out file]" if ARGV.empty? && !env_in

overwrite = %w(-y -o -f --force --overwrite).any? { |f| ARGV.delete(f) }

data = File.read('config.yml')
config   = YAML.load(ERB.new(data).result)
template = if custom_template_index = (ARGV.index('--template') || ARGV.index('-t'))
  custom = ARGV[custom_template_index+1]
  error "=> Specified template file #{custom} does not exist." unless File.exist?(custom)
  ARGV.delete_at(custom_template_index) # delete the --argument
  ARGV.delete_at(custom_template_index) # and its value
  custom
else
  file 'nginx.erb'
end

tmpldata = File.read(template)
processed = ERB.new(tmpldata, nil, '>').result(binding)
open(out_file, 'w+').write(processed)
error "=> Wrote #{out_file} successfully."
