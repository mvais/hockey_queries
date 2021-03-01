module ApplicationHelper
  def sortable(column, column_id)
    direction = column_id.to_i == sort_column.to_i && sort_direction == 'desc' ? 'asc' : 'desc'
    link_to column, { sort: column_id, direction: direction }
  end
end
