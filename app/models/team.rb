class Team < ActiveRecord::Base
  include Importer::Teams
  has_many :ownerships
  has_many :players, :through=>:ownership
  belongs_to :division

  # kind of a unique query. A bunch of ways to do this.
  # The scope below returns the correct record type
  # and allows for duplicate teams with different
  # round and pick numbers attached
  scope :with_drafts_left, ->{
    Team.select(
      "
        o.pick as pick, 
        o.round as round, 
        teams.id as team_id, 
        teams.name as team_name, 
        d.name as division_name
      "
    ).joins(
      "
      LEFT JOIN ownerships o on o.team_id = teams.id
      INNER JOIN divisions d on d.id = teams.division_id
      "
    ).where(
      "o.player_id is NULL"
    ).group(
      "o.id"
    ).order(
      "o.pick ASC"
    )
  }



  def self.make_next_draft!(params={})
    if owning = Ownership.next_to_draft and undrafted_player_id = Player.undrafted.sample.try(:player_id)
      if params["pick-type"] == "random"
        # call sample ruby core method to get 
        # random element from ruby arr
        owning.player_id = undrafted_player_id
        owning.picked_at = DateTime.now
        owning.save!
      else
        # pick-type == "manual"
        # which means a user manually clicked
        # on a player to draft them
      end
      # re-query to include additional record assoc info
      Ownership.completed_drafts.where("ownerships.id = #{owning.id}").first
    end
  end

end
