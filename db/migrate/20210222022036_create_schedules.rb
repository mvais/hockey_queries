class CreateSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :schedules do |t|
      t.string  :game_id, null: false
      t.integer :season, null: false
      t.date    :game_date, null: false
      t.string  :visitor_team_name, null: false
      t.string  :visitor_team_abrv, null: false
      t.integer :visitor_team_goals, null: false, default: 0
      t.string  :home_team_name, null: false
      t.string  :home_team_abrv, null: false
      t.integer :home_team_goals, null: false, default: 0
      t.string :game_ended_status, default: 'REG'

      t.timestamps
    end
  end
end
