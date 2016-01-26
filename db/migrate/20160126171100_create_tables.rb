# -*- coding: utf-8 -*-
class CreateTables < ActiveRecord::Migration
  class Train < ActiveRecord::Base ; end
  def change
    create_table :trains do |t|
      t.string :name, null: false
      t.datetime :time
      t.string :description
      t.integer :watching, null: false
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        Train.create!(name: "京浜東北根岸線", watching: 1)
        Train.create!(name: "都営三田線", watching: 1)
        Train.create!(name: "山手線", watching: 1)
      end
    end
  end
end
