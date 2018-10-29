class AssigmentMatrix
  attr_accessor :data, :assigned_tasks

  def initialize(matrix)
    self.data = matrix
    self.original_data = matrix.map(&:clone)
    self.assigned_tasks = []
    self.marked_rows = []
    self.marked_columns = []
  end

  # Generate the lowest cost assigments.
  def lowest_assignment
    rows.map(&:reduce_by_min)
    unless assign_task
      cols.map(&:reduce_by_min)

      until assign_task
        self.marked_rows = []
        draw_lines
        reduce_remaining_cells
      end
    end

    assigment_detail
  end

  # Rows are agents
  def rows
    @_rows ||= data.map.with_index do |_row, index|
      Row.new(self, index)
    end
  end

  # Cols are tasks
  def cols
    @_cols ||= (0...cols_num).map do |index|
      Column.new(self, index)
    end
  end

  private

  attr_accessor :original_data, :marked_rows, :marked_columns
  alias :cols_with_line :marked_columns
  alias :rows_without_line :marked_rows

  def assignment_complete
    cols_num == assigned_tasks.length && assigned_tasks.all?
  end

  # Assign tasks to agent with lostest cost,
  # and return whether or not all the tasks have agent assigned to them.
  def assign_task
    reset_assigned_tasks

    recursive_assign_row([], 0)
    rows.each do |row|
      row.assinge_to = assigned_tasks.index(row.num)
    end
    cols.each_with_index do |col, index|
      col.assigned = assigned_tasks[index]
    end

    assignment_complete
  end

  # tasks is an array with index is the col (task), and the value in each index
  # is the row assigned to the task.
  # A row (agent) can only assign to a col (task) if it has 0 cost at the col.
  # The method will return whether or not all the remaing rows assign successfully.
  def recursive_assign_row(tasks, row_num)
    row = rows[row_num]

    current_tasks = tasks.clone
    next_row = row_num + 1
    # For each position that has 0, try to do assigment for the posstion and for
    # remaining rows with the position assigned
    row.zeros.each do |zero|
      next unless tasks[zero].nil?

      tasks[zero] = row.num

      update_assigned_taks_if_better(tasks.clone)
      # short circut if all remaing rows assign successfully
      # otherwise, means if assign the agent to current task, reaming tasks cant
      # be assign successfully, and then try to assign the agent to next avaiable
      # task
      if next_row >= rows.length || recursive_assign_row(tasks, next_row)
        return true
      end

      tasks[zero] = nil
    end

    # If current row fail to assign, try next row
    recursive_assign_row(current_tasks, next_row) if next_row < rows.length

    false
  end

  # Update assigment if tasks has more assigments.
  def update_assigned_taks_if_better(tasks)
    if tasks.compact.length > assigned_tasks.compact.length
      self.assigned_tasks = tasks
    end
  end

  # Generate the assigment info with cost.
  def assigment_detail
    assigment = []
    cost = assigned_tasks.map.with_index do |row, col|
      assigment << {
        row: row,
        col: col,
        cost: original_data[row][col]
      }
      original_data[row][col]
    end.inject(:+)

    {
      assigment: assigment,
      total_cost: cost
    }
  end

  # A col marked or a row not marked will be lined
  def draw_lines
    marked_rows_no_assignment
    new_cols = marked_cols_with_zero_in_marked_rows
    marked_assigned_rows_with_zero_in_marked_cols(new_cols)
  end

  # Mark a row(agent) if it does not assign to any col(task)
  def marked_rows_no_assignment
    rows.each do |row|
      next unless row.assinge_to.nil?
      marked_rows << row.num
    end
  end

  # Mark a col if for the column, there is 0 in any marked rows.
  def marked_cols_with_zero_in_marked_rows
    new_cols = []
    marked_rows.each do |row_num|
      rows[row_num].zeros.each do |z|
        next if marked_columns.include?(z)
        new_cols << z
      end
    end
    self.marked_columns = (marked_columns + new_cols).uniq
    new_cols
  end

  # Mark a row if its assigned to a marked col.
  def marked_assigned_rows_with_zero_in_marked_cols(new_cols)
    zero_rows = []
    new_cols.each do |col_num|
      assigned_row = assigned_tasks[col_num]
      cols[col_num].zeros.each do |z|
        zero_rows << z if assigned_row == z
      end
    end

    self.marked_rows = (marked_rows + zero_rows).uniq
  end

  # Find the min value amoung cells in marked row but not marked col.
  # Reduce those cells' value by the min.
  # Increase the cells in marked col not marked row by the min.
  # This is try to find the 2nd min cost for the remaing choices.
  def reduce_remaining_cells
    min = find_min_in_cells_with_no_line
    reduce_cells_with_no_line(min)
    increase_cells_with_two_lines(min)
  end

  # Find the min value amoung cells in marked row but not marked col.
  def find_min_in_cells_with_no_line
    min = nil

    each_cell_with_no_line do |_row, _index, val|
      min = val if min.nil? || min > val
    end

    min
  end

  def reduce_cells_with_no_line(val)
    each_cell_with_no_line do |row, index, call_val|
      row.update_data(index, call_val - val)
    end
  end

  def increase_cells_with_two_lines(val)
    rows.each do |row|
      next if rows_without_line.include?(row.num)

      row.data.each_with_index do |_val, index|
        next unless cols_with_line.include?(index)
        row.data[index] += val
      end
    end
  end

  def each_cell_with_no_line(&block)
    rows.each do |row|
      next unless rows_without_line.include?(row.num)
      row.data.each_with_index do |val, index|
        next if cols_with_line.include?(index)
        block.call(row, index, val) if block_given?
      end
    end
  end

  def reset_assigned_tasks
    self.assigned_tasks = []
  end

  def cols_num
    rows.first.data.length
  end

  # Row represent a row in the matrix
  class Row
    # zeros is an array of index with value is 0
    # assinge_to the col (task) index this row assigned to
    # num the row number in the matrix
    attr_accessor :zeros, :assinge_to, :num

    def initialize(matrix, num)
      self.matrix = matrix
      self.num = num
      self.zeros = []
      self.assinge_to = nil
    end

    # Find the min value in the row and reduce the data by the value
    def reduce_by_min
      min = data.min
      data.each_with_index { |d, i| update_data(i, d - min) }
    end

    def data
      matrix.data[num]
    end

    # Update the value for the index and update zeros if the new value is 0
    def update_data(index, val)
      return if data[index] == val
      zeros.delete(index)
      data[index] = val
      if val == 0
        zeros << index
        zeros.uniq!
      end
    end

    private

    attr_accessor :matrix
  end

  # Column represent a col in the matrix
  # Matrix represent by an array of array (row)
  # Column is a wrapper to handle data in rows with col num
  class Column
    # num is the index for the column
    # assigned is the row (agent) num assign to this col (task)
    attr_accessor :num, :assigned

    def initialize(matrix, num)
      self.matrix = matrix
      self.num = num
      self.assigned = nil
    end

    # Find the min value in the col and reduce the data by the value
    def reduce_by_min
      min = data.min
      matrix.rows.map.with_index do |row, _row_num|
        row.update_data(num, row.data[num] - min)
      end
    end

    def data
      matrix.rows.map { |row| row.data[num] }
    end

    def zeros
      matrix.rows.map.with_index do |row, row_num|
        row_num if row.data[num] == 0
      end.compact
    end

    private

    attr_accessor :matrix
  end
end

data = [
  [8, 3, 3, 9, 8, 8, 3, 3, 9, 8],
  [9, 4, 2, 6, 9, 9, 4, 2, 6, 9],
  [6, 5, 6, 7, 6, 6, 5, 6, 7, 6],
  [7, 6, 4, 7, 7, 7, 6, 4, 7, 7],
  [8, 3, 3, 9, 8, 8, 3, 3, 9, 8],
  [8, 3, 3, 9, 8, 8, 3, 3, 9, 8],
  [9, 4, 2, 6, 9, 9, 4, 2, 6, 9],
  [6, 5, 6, 7, 6, 6, 5, 6, 7, 6],
  [7, 6, 4, 7, 7, 7, 6, 4, 7, 7],
  [8, 3, 3, 9, 8, 8, 3, 3, 9, 8]
]

# data = [
#   [8, 3, 3, 9],
#   [9, 4, 2, 6],
#   [6, 5, 6, 7],
#   [7, 6, 4, 7],
# ]

ma = AssigmentMatrix.new(data)
puts ma.lowest_assignment
