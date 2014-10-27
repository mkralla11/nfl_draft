class Ownership < ActiveRecord::Base
  include Importer::Ownerships
  belongs_to :player
  belongs_to :team

  def self.undrafted
    where("ownerships.picked_at IS NULL").order("ownerships.pick ASC")
  end


  def self.completed_drafts
    select(
      "
        ownerships.id as id,
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

end
