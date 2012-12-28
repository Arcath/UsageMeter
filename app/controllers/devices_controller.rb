class DevicesController < ApplicationController
  def index
    @devices = Device.all
    @total_in = 0
    @total_out = 0
  end
  
  def show
    @device = Device.find(params[:id])
  end
end