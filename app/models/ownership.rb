class Ownership < ActiveRecord::Base

  belongs_to :player
  belongs_to :team


  def self.completed_drafts
    select(
      "
        ownerships.id as ownership_id,
        players.id as player_id, 
        players.name player_name, 
        positions.name as position_name,
        ownerships.pick as pick, 
        ownerships.round as round, 
        teams.id as team_id, 
        teams.name as team_name, 
        divisions.name as division_name
      "
    ).joins(
      "
        INNER JOIN players on ownerships.player_id = players.id
        INNER JOIN positions on players.position_id = positions.id
        INNER JOIN teams on ownerships.team_id = teams.id
        INNER JOIN divisions on teams.division_id = divisions.id        
      "
    ).order(
      "ownerships.pick DESC"
    )
  end

  def self.next_to_draft
    select(
      "
        ownerships.id as id,
        ownerships.picked_at as picked_at,
        ownerships.id as ownership_id, 
        ownerships.pick as pick, 
        ownerships.round as round, 
        teams.id as team_id, 
        teams.name as team_name, 
        divisions.name as division_name
      "
    ).joins(
      "
        INNER JOIN teams on ownerships.team_id = teams.id
        INNER JOIN divisions on teams.division_id = divisions.id        
      "
    ).where(
      "
        ownerships.picked_at IS NULL
      "
    ).order(
      "
        ownerships.pick ASC
      "
    ).first
  end



  def self.has_drafts_left?
    where("player_id IS NULL").first.present?
  end

  def self.no_drafts_left?
    !self.has_drafts_left?
  end

  def self.import_csv
    path = Rails.root.join('config', 'imports', "order.csv")
    # use a hash rather than using detect method a ton of times
    name_teams = {}
    # just realized data provided in csv files is not consistent,
    # so I must adjust to make work
    Team.all.each {|team| name_teams[team.name.split(/\s+/).last] = team}
    ownerships = []
    SmarterCSV.process(
      path, 
      :chunk_size => 75
    ) do |chunk|
      chunk.each do |o_attrs|
        Rails.logger.info(o_attrs.to_s)
        o_attrs[:team_id] = name_teams[o_attrs.delete(:team_name).split(/\s+/).last].id
        ownerships << Ownership.new(o_attrs)
      end
    end

    Ownership.import ownerships
  end
end
