class UsersController < ApplicationController
  def index
    @users = User.all
    @total_in = 0
    @total_out = 0
  end
end