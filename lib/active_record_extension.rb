module ActiveRecordExtension

  extend ActiveSupport::Concern

  # def association_loaded?(name)
  #   association_instance_get(name).present?
  # end

  module ClassMethods

    def empty_and_reset_table
      self.delete_all
      ActiveRecord::Base.connection.execute("ALTER TABLE #{self.table_name} AUTO_INCREMENT = 1")
    end

    # example call: ActiveRecord::Base.array_attr_pred_sql(array, attribute, predicate) 
    # args: array, attribute, predicate
    # return: sql string   
    def array_attr_pred_sql(array, attribute, predicate)
      array ||= []
      arr = array.collect do |element| 
        element = element.to_s 
        if element !~ /^'/
          element = "'"+ element
        end
        if element !~ /'$/
          element = element + "'"
        end
        element
      end
      attribute ||= "id"
      predicate ||= "IN"
      arr = "(" + arr.join(",") + ")"
      if arr == "()"
        #Empty array, just set array, @attribute, and predicate to nil
        arr = attribute = predicate = nil
      end
      [attribute, predicate, arr].join(" ")
    end


    def array_attr_order_field_sql(array, attribute)
      array ||= []
      attribute ||= "id"
      attr_array_str = ([attribute] + array).join(",")
      start_f = "FIELD("
      end_f = ")"
      if array.blank?
        #Empty array, just set array, @attribute, and predicate to nil
        attr_array_str = attribute = start_f = end_f = nil
      end

       [start_f , attr_array_str , end_f].join
    end
  end
end



ActiveRecord::Base.send(:include, ActiveRecordExtension)