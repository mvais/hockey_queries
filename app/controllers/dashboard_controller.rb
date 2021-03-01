class DashboardController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    sql = %Q(
        WITH VISITOR_TEAM_STATS AS (
          SELECT
            visitor_team_name team_name,
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
          GROUP BY visitor_team_abrv, visitor_team_name
        ), HOME_TEAM_STATS AS (
          SELECT
            home_team_name team_name,
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
          GROUP BY home_team_abrv, home_team_name
        )
      SELECT
        vts.team_name,
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
      ORDER BY #{sort_column} #{sort_direction};
    )

    @standings = ActiveRecord::Base.connection.execute(sql).to_a
  end

  private

  def sort_column
    params[:sort] || 4
  end

  def sort_direction
    params[:direction] || 'desc'
  end
end
