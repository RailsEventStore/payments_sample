# frozen_string_literal: true

class CreateEventStoreEvents < ActiveRecord::Migration[7.1]
  def change
    create_table(:event_store_events_in_streams, force: false) do |t|
      t.string      :stream,      null: false
      t.integer     :position,    null: true
      t.references  :event,       null: false, type: :string, limit: 36, index: false
      t.datetime    :created_at,  null: false, precision: 6, index: true
    end
    add_index :event_store_events_in_streams, [:stream, :position], unique: true
    add_index :event_store_events_in_streams, [:stream, :event_id], unique: true
    add_index :event_store_events_in_streams, [:event_id]

    create_table(:event_store_events, force: false) do |t|
      t.references  :event,       null: false, type: :string, limit: 36, index: { unique: true }
      t.string      :event_type,  null: false, index: true
      t.json      :metadata
      t.json      :data,        null: false
      t.datetime    :created_at,  null: false, precision: 6, index: true
      t.datetime    :valid_at,    null: true,  precision: 6, index: true
    end

    add_foreign_key "event_store_events_in_streams", "event_store_events", column: "event_id", primary_key: "event_id"
  end
end
