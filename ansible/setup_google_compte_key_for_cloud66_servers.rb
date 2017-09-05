#Later migrate to ansible custom taks or role and ip's in host file so that there is no duplication of hosts
require 'byebug'

def c66_servers
  [
    {c66_stack: "Open Layer", c66_server: "princesscecile", ip: "104.196.217.100", zone: "us-east1-b", gc_name: 'c66open-layerimpala-xam'},
    {c66_stack: "Open Layer", c66_server: "bulldog", ip: "35.185.71.173", zone: "us-east1-b", gc_name: 'c66open-layerbulldog-yby'},
    {c66_stack: "Open Layer", c66_server: "chubbyboy", ip: "35.196.151.142", zone: "us-east1-b", gc_name: 'c66open-layerchubbyboy-gws'},
    {c66_stack: "Open Layer", c66_server: "fatboy", ip: "35.185.3.77", zone: "us-east1-b", gc_name: 'c66open-layerfatboy-dxh'},
    {c66_stack: "Open Layer", c66_server: "workhorse", ip: "35.185.19.193", zone: "us-east1-b", gc_name: 'c66open-layerworkhorse-bso'},
    #
    {c66_stack: "open_layer_api", c66_server: "panther", ip: "104.196.19.208", zone: "us-east1-b", gc_name: 'c66open-layer-apipanther'},
  ]
end

def setup_authorized_keys_with_my_google_key_on_cloud66_servers
  c66_servers.each do |hash|
    pub_key = `cat ~/.ssh/google_compute_engine.pub`
    shell_script = "
      if grep -Fxq '#{pub_key.strip}' ~/.ssh/authorized_keys
      then
        echo 'key exists'
      else
        echo '#{pub_key.strip}' >> ~/.ssh/authorized_keys
      fi
    "
    #Please check if it already exists, then only add
    command = "cx run -s '#{hash[:c66_stack]}' --server '#{hash[:c66_server]}' -e production \"#{shell_script}\""
    # command = "cx run -s '#{hash[:c66_stack]}' --server '#{hash[:c66_server]}' -e production 'echo foo'"
    puts "EXECUTING: #{command}"
    output = `#{command}`
    puts "OUTPUT: #{output}"
    result = $?.success?
    puts "SUCCESS: #{result}"
    raise "Command failed" unless result
  end
end

def allow_ssh_access_for_cloud66_servers
  c66_servers.each do |hash|
    command = "gcloud compute instances add-tags #{hash[:gc_name]} --zone #{hash[:zone]} --tags default-ssh"
    puts "EXECUTING: #{command}"
    output = `#{command}`
    puts "OUTPUT: #{output}"
    puts "SUCCESS: #{$?.success?}"
  end
end

allow_ssh_access_for_cloud66_servers
setup_authorized_keys_with_my_google_key_on_cloud66_servers
