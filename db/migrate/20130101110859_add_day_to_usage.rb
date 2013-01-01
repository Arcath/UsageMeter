class AddDayToUsage < ActiveRecord::Migration
  def change
    add_column :usages, :day, :integer
  end
end
