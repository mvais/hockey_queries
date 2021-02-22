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
