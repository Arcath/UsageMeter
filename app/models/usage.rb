class Usage < ActiveRecord::Base
  attr_accessible :device_id, :in, :month, :out, :year, :day
  
  belongs_to :device
end
