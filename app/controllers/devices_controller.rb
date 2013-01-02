require 'resolv'

class DevicesController < ApplicationController
  def index
    Device.update_data
    @devices = Device.all
    @total_in = 0
    @total_out = 0
  end
  
  def show
    @device = Device.find(params[:id])
    @usages = @device.usages.order("created_at desc").limit(31)
  end
end