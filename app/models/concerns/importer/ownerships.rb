module Importer
  module Ownerships
    extend ActiveSupport::Concern

    module ClassMethods
      def import_csv
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
  end
end