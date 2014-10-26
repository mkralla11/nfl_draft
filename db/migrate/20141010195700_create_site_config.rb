class CreateSiteConfig < ActiveRecord::Migration
  def change
    create_table :site_configs do |t|
      t.string :name
      t.boolean :as_boolean
      t.integer :as_integer
      t.string :as_string
      t.datetime :as_datetime
      t.timestamps
    end
  end
end
