class Player < ActiveRecord::Base
  include Importer::Players
  has_one :ownership
  has_one :team, :through=>:ownership
  belongs_to :position

  scope :undrafted, ->{
    select(
      "
        players.id as player_id, 
        players.name as player_name, 
        pos.name as position_name
      "
    ).joins(
      "
        LEFT JOIN ownerships o on o.player_id = players.id
        INNER JOIN positions pos on players.position_id = pos.id
      "
    ).where(
      "o.id is NULL"
    )
  }

end
