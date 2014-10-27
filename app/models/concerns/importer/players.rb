module Importer
  module Players

    extend ActiveSupport::Concern

    module ClassMethods
      # allow self to import dependent data
      def import_csv
        path = Rails.root.join('config', 'imports', "players.csv")
        # use the parent association position as the
        # model to import as well
        position_players = {}
        p_id = 0

        SmarterCSV.process(
          path, 
          { :chunk_size => 75, 
            :key_mapping => {
              :player_name => :name
            }
          }
        ) do |chunk|
          chunk.each do |pp_attrs|
            # normalize tables, putting a player's position
            # in the position table, and utilize a foreign key
            # to relate it.
            pn = pp_attrs.delete(:position).to_sym
            if !position_players[pn].nil?
              the_id = position_players[pn][:position].id
            else
              p_id = p_id + 1
              the_id = p_id
              position_players[pn] = {}
              position_players[pn][:players] = []
              position = Position.new(:name=>pn.to_s)
              position.id = the_id
              position_players[pn][:position] = position
            end
            position_players[pn][:players] << Player.new(pp_attrs.merge(:position_id=>the_id))
          end
        end

        Position.import position_players.values.collect {|pp| pp[:position]}
        Player.import position_players.values.collect {|pp| pp[:players]}.flatten
      end
    end
  end
end