module Draft
  module FullDrafter
    extend ActiveSupport::Concern
    module ClassMethods

      def execute_full_draft
        owned = []
        remaining_players = []
        Player.undrafted.find_each {|rp| remaining_players << rp}
        remaining_players = remaining_players.shuffle
        time = DateTime.now

        Ownership.undrafted.each do |uo|
          rp = nil
          remaining_players.present? ? rp = remaining_players.shift : break
          uo.player_id = rp.player_id
          uo.picked_at = time
          owned << uo
        end


        # unbelievably efficient, one query, all complete
        Ownership.import owned, :on_duplicate_key_update => [:player_id, :picked_at]
      end

    end
  end
end