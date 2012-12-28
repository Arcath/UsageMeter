class CreateUsages < ActiveRecord::Migration
  def change
    create_table :usages do |t|
      t.integer :device_id
      t.integer :year
      t.integer :month
      t.integer :in
      t.integer :out

      t.timestamps
    end
  end
end
