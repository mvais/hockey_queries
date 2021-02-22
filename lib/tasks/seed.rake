# rails hockey_reference:seed_schedule
namespace :hockey_reference do
  desc "Seed NHL Schedule"
  task :seed_schedule => :environment do
    (2004..2020).to_a.each do |season|
      HockeyReference::Schedule.scrape(season).each do |schedule|
        game = Schedule.find_by(game_id: schedule[:game_id])

        if game.blank?
          Schedule.create(
            game_id: schedule[:game_id],
            season: season,
            game_date: schedule[:game_date],
            visitor_team_name: schedule[:visitor_team_name],
            visitor_team_abrv: schedule[:visitor_team_abrv],
            visitor_team_goals: schedule[:visitor_team_goals],
            home_team_name: schedule[:home_team_name],
            home_team_abrv: schedule[:home_team_abrv],
            home_team_goals: schedule[:home_team_goals],
            game_ended_status: schedule[:game_status]
          )

          puts "Created #{schedule[:game_id]} - #{schedule[:visitor_team_abrv]} vs #{schedule[:home_team_abrv]}"
        end
      end
    end
  end

  # desc "TODO"
  # task :my_task2 => :environment do
  # end
end
