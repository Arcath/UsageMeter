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
      total_in += usage.in
      total_out += usage.out
    end
    return [total_in, total_out]
  end
end
