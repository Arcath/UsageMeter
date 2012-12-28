class User < ActiveRecord::Base
  attr_accessible :name
  
  has_many :devices
  
  def device_usage(year = Time.now.year, month = Time.now.month)
    total_in = 0
    total_out = 0
    devices.each do |device|
      usage = device.usages.where(year: year, month: month).first
      total_in += usage.in
      total_out += usage.out
    end
    return [total_in, total_out]
  end
end
