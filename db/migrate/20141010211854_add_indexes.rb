class AddIndexes < ActiveRecord::Migration
  def change
    add_index :ownerships, [:player_id, :team_id], :name => "pt_idx", :unique=>true
    add_index :players, :position_id, :name => "position_id_idx"
    add_index :players, [:name, :position_id], :name => "np_idx", :unique=>true
    add_index :teams, :division_id, :name => "division_id idx"
    add_index :teams, [:name, :division_id], :name => "nd_idx", :unique=>true

    add_index :teams, :name, :name=>"name_idx", :unique=>true
    add_index :positions, :name, :name=>"name_idx", :unique=>true
    add_index :divisions, :name, :name=>"name_idx", :unique=>true
    # cannot add index to players name, could lead to collisions 
  end
end
