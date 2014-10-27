module Importer
  module Teams

    extend ActiveSupport::Concern

    module ClassMethods
      # allow self to import dependent data
      def import_csv
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
  end
end