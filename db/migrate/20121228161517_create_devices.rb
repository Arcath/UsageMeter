class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :ip
      t.string :mac
      t.string :hostname

      t.timestamps
    end
  end
end
