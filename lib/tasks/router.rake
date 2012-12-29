require 'resolv'

namespace :router do
  desc "Pull Usage from router"
  task :pull => :environment do
    puts "Connecting to router @ http://#{ROUTER_IP}"
    system("curl http://#{ROUTER_IP}/user/js/traffic.js > /tmp/router_traffic.js")
  end
  
  desc "update devices"
  task :devices => :environment do
    data = data_array
    devices = device_hash(data)
    devices.each do |ip, data|
      device = Device.find_or_create_by_ip(ip)
      device.mac = data[0]
      begin
        device.hostname = Resolv.getname(ip)
      rescue
        device.hostname = data[1]
      end
      device.save
      
      year = Time.now.year
      month = Time.now.month 
      
      if device.usages.count == 0
        usage = device.usages.new
        usage.year = year
        usage.month = month
        usage.save
      end
      
      if device.usages.last.year == year && device.usages.last.month == month
        usage = device.usages.last
      else
        usage = device.usages.new
        usage.year = year
        usage.month = month
      end
      usage.out = data[2]
      usage.in = data[3]
      usage.save
    end
  end
end

def data_array
  f = File.open("/tmp/router_traffic.js").read
  data_array = f.scan(/data = \[\n(.*)\n\];\n\n \n\];/m).join
  eval("@data = #{data_array}")
  return @data
end

def device_hash(days)
  hash = {}
  days.each do |array|
    array[1].each do |i|
      if i =~ /\./
        hash[i] = [array[1][array[1].index(i)+1], '-Unknown-']
      end
    end
  
    array[2].each do |i|
      if i =~ /\./
        hash[i] ||= ['-Unknown-', '-Unknown-']
        hash[i][2] ||= 0
        hash[i][3] ||= 0
        hash[i][2] += array[2][array[2].index(i)+1].to_i
        hash[i][3] += array[2][array[2].index(i)+2].to_i
      end
    end
  end
  return hash
end