class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :codename
      t.integer :level
      t.boolean :active

      t.timestamps
    end
  end
end
