class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.integer :team_id
      t.integer :player_id
      t.integer :round
      t.integer :pick
      t.datetime :picked_at
    end
  end
end
