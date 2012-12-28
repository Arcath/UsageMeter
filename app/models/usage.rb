class Usage < ActiveRecord::Base
  attr_accessible :device_id, :in, :month, :out, :year
  
  belongs_to :device
end
