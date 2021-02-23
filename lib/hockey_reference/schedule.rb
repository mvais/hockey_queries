require 'httparty'

module HockeyReference
  class Schedule

    def self.scrape(season)
      html = request(season)

      schedule = []

      html.css('#games tbody > tr').each do |row|
        table_data = row.css('td')

        schedule.push({
          'game_id': row.css('th').first['csk'],
          'season': season,
          'game_date': row.css('th').first.text,
          'visitor_team_name': table_data[0].text,
          'visitor_team_abrv': table_data[0].children.first['href'].split('/')[2],
          'home_team_name': table_data[2].text,
          'home_team_abrv': table_data[2].children.first['href'].split('/')[2],
          'visitor_team_goals': table_data[1].text,
          'home_team_goals': table_data[3].text,
          'game_status': table_data[4].text
        })
      end

      schedule
    end

    def self.query
      %Q(
        WITH VISITOR_TEAM_STATS AS (
          SELECT
            visitor_team_abrv abrv,
            COUNT(*) games_played,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals THEN 0 END) total_wins,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals THEN 0 END) total_losses,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals AND game_ended_status = '' THEN 0 END) regulation_wins,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals AND game_ended_status = 'OT' THEN 0 END) overtime_wins,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals AND game_ended_status = 'SO' THEN 0 END) shootout_wins,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals AND game_ended_status = '' THEN 0 END) regulation_losses,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals AND game_ended_status = 'OT' THEN 0 END) overtime_losses,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals AND game_ended_status = 'SO' THEN 0 END) shootout_losses
          FROM schedules
          GROUP BY visitor_team_abrv
        ), HOME_TEAM_STATS AS (
          SELECT
            home_team_abrv abrv,
            COUNT(*) games_played,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals THEN 0 END) total_wins,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals THEN 0 END) total_losses,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals AND game_ended_status = '' THEN 0 END) regulation_losses,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals AND game_ended_status = 'OT' THEN 0 END) overtime_losses,
            COUNT(CASE WHEN visitor_team_goals > home_team_goals AND game_ended_status = 'SO' THEN 0 END) shootout_losses,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals AND game_ended_status = '' THEN 0 END) regulation_wins,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals AND game_ended_status = 'OT' THEN 0 END) overtime_wins,
            COUNT(CASE WHEN visitor_team_goals < home_team_goals AND game_ended_status = 'SO' THEN 0 END) shootout_wins
          FROM schedules
          GROUP BY home_team_abrv
        )
      SELECT
        vts.abrv,
        (vts.games_played + hts.games_played) games_played,
        (vts.total_wins + hts.total_wins) total_wins,
        (vts.total_losses + hts.total_losses) total_losses,
        (vts.regulation_wins + hts.regulation_wins) regulation_wins,
        (vts.overtime_wins + hts.overtime_wins) overtime_wins,
        (vts.shootout_wins + hts.shootout_wins) shootout_wins,
        (vts.regulation_losses + hts.regulation_losses) regulation_losses,
        (vts.overtime_losses + hts.overtime_losses) overtime_losses,
        (vts.shootout_losses + hts.shootout_losses) shootout_losses
      FROM VISITOR_TEAM_STATS vts
      INNER JOIN HOME_TEAM_STATS hts ON vts.abrv = hts.abrv
      )
    end

    class << self

      private

      def request(season)
        page = HTTParty.get("https://www.hockey-reference.com/leagues/NHL_#{season}_games.html", {
          headers: {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
          }
        })

        html = Nokogiri::HTML(page.body)
      end
    end
  end
end
