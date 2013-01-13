class Device < ActiveRecord::Base
  attr_accessible :hostname, :ip, :mac
  
  has_many :usages
  belongs_to :user
  
  def self.unclaimed
    devices = where(user_id: nil)
  end
  
  def self.unclaimed_data(year = Time.now.year, month = Time.now.month)
    total_in = 0
    total_out = 0
    unclaimed.each do |device|
      usage = device.usages.where(:year => year, :month => month).first
      if usage
        total_in += usage.in
        total_out += usage.out
      end
    end
    return [total_in, total_out]
  end
  
  def usage_for_month(year = Time.now.year, month = Time.now.month)
    total = [0, 0]
    usages.where(:year => year, :month => month).each do |usage|
      total[0] += usage.in
      total[1] += usage.out
    end
    return total
  end
  
  def usage_for(year = Time.now.year, month = Time.now.month, day = Time.now.day)
    (usages.where(:year => year, :month => month, :day => day).first || usages.new({year: year, month: month, day: day}))
  end
  
  def self.update_data
    if which "wget"
      system("wget http://#{ROUTER_IP}/user/js/traffic.js -O /tmp/router_traffic.js")
    else
      system("curl http://#{ROUTER_IP}/user/js/traffic.js > /tmp/router_traffic.js")
    end
    
    data = data_array
    @remove_total = {}
    data.each do |data_day|
      year, month, day = data_day[0][5].scan(/_(.*)-(.*)-(.*)\./).first.map {|i| i.to_i }
      data_day[1].each do |host|
        if host =~ /\./
          device = Device.find_or_create_by_ip(host)
          device.mac = data_day[1][data_day[1].index(host)+1]
          begin
            device.hostname = Resolv.getname(ip)
          rescue
            device.hostname = "-Unknown-"
          end
          device.save
        end
      end
      data_day[2].each do |raw_usage|
        if raw_usage =~ /\./
          @remove_total["#{raw_usage}-in"] ||= 0
          @remove_total["#{raw_usage}-out"] ||= 0
          usage_array = [raw_usage, data_day[2][data_day[2].index(raw_usage)+1].to_i, data_day[2][data_day[2].index(raw_usage)+2].to_i]
          device = Device.find_by_ip(usage_array[0])
          begin
            usage = device.usage_for(year,month,day)
          rescue NoMethodError
            device = Device.find_or_create_by_ip(usage_array[0])
            begin
              device.hostname = Resolv.getname(ip)
            rescue
              device.hostname = "-Unknown-"
            end
            device.save
            usage = device.usage_for(year,month,day)
          end
          usage.out = (usage_array[1] - @remove_total["#{raw_usage}-out"])
          usage.in = (usage_array[2] - @remove_total["#{raw_usage}-in"])
          usage.in = 0 if usage.in <= 0
          usage.out = 0 if usage.out <= 0
          @remove_total["#{raw_usage}-in"] = usage_array[2]
          @remove_total["#{raw_usage}-out"] = usage_array[1]
          usage.save
        end
      end
    end
  end
  
  def self.data_array
    f = File.open("/tmp/router_traffic.js").read
    data_array = f.scan(/data = \[\n(.*)\n\];\n\n \n\];/m).join
    eval("@data = #{data_array}")
    return @data
  end
  
  def self.which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = "#{path}/#{cmd}#{ext}"
        return exe if File.executable? exe
      }
    end
    return nil
  end
end
