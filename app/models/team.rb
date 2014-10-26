class Team < ActiveRecord::Base
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
    if params["pick-type"] == "random"
      owning = Ownership.next_to_draft
      draftable_players = Player.undrafted
      # call sample ruby core method to get 
      # random element from ruby arr
      owning.player_id = draftable_players.sample.player_id
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




  def self.import_csv
    path = Rails.root.join('config', 'imports', "teams.csv")
    division_teams = {}
    d_id = 0
    SmarterCSV.process(
      path, 
      { :chunk_size => 75, 
        :key_mapping => {
          :team_name => :name
        }
      }
    ) do |chunk|
      chunk.each do |dt_attrs|
        # normalize tables, putting a team's division
        # in the division table, and utilize a foreign key
        # to relate it.
        dn = dt_attrs.delete(:division).to_sym

        if !division_teams[dn].nil?
          the_id = division_teams[dn][:division].id
        else
          d_id = d_id + 1
          the_id = d_id
          division_teams[dn] = {}
          division_teams[dn][:teams] = []
          division = Division.new(:name=>dn.to_s)
          division.id = the_id
          division_teams[dn][:division] = division
        end

        division_teams[dn][:teams] << Team.new(dt_attrs.merge(:division_id=>the_id))
      end
    end
    
    Team.import division_teams.values.collect {|dt| dt[:teams]}.flatten
    Division.import division_teams.values.collect {|dt| dt[:division]}
  end
end
