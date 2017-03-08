require "byebug"
require_relative "board"

module Slideable
  def moves
    case self.symbol
    when :Q
      move_dirs([:diagonal, :horizontal, :vertical])
    when :B
      move_dirs([:diagonal])
    when :R
      move_dirs([:vertical, :horizontal])
    end
  end

  private
  SLIDEABLE_CHANGES = {:diagonal => [[1,1], [1,-1], [-1, 1], [-1, -1]],
    :horizontal => [[0,1], [0,-1]],
    :vertical => [[1,0], [-1,0]] }

  def move_dirs(direction_symbols)
    all_moves = []
    direction_symbols.each do |direction_sym|
      all_moves += get_moves(direction_sym)
    end
    all_moves
  end

  def get_moves(dir_symbol)
    moves_in_dir = []
    SLIDEABLE_CHANGES[dir_symbol].each do |change|
      dx, dy = change
      moves_in_dirs = grow_unblocked_moves_in_dirs(dx, dy)
      unless moves_in_dirs.nil?
        moves_in_dir.concat(moves_in_dirs)
      end
    end
    moves_in_dir
  end

  def grow_unblocked_moves_in_dirs(dx, dy)
    moves = []
    current_row, current_column = current_position
    # debugger
    # while is_valid?([current_row, current_column]) && empty?([current_row, current_column])
    current_row += dx
    current_column += dy
    while is_legal?([current_row, current_column])
      moves << [current_row, current_column]
      unless empty?([current_row, current_column])
        if is_enemy?([current_row, current_column])
          moves << [current_row, current_column]
          break
        else
          break
        end
      end
      current_row += dx
      current_column += dy
    end
    # moves << [current_row, current_column] if is_legal?([current_row, current_column])
    moves

  end
end

module Stepable
  def moves
    case self.symbol
    when :N
      move_dirs(:knight)
    when :K
      move_dirs(:king)
    end
  end

  private
  STEPABLE_CHANGES = {
    :knight => [[-2, -1], [-2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2], [2, -1], [2, 1]],
    :king => [[1, 1], [1, -1], [-1, 1], [-1, -1], [0, 1], [0, -1], [1, 0], [-1, 0]],
    :pawn => [[1,0], [1,1], [1,-1], [2,0]]
  }

  def move_dirs(piece_type)
    current_row, current_column = current_position
    possible = STEPABLE_CHANGES[piece_type].map do |change|
      [(current_row + change[0]), (current_column + change[1])]
    end
    valid = possible.select { |move| is_legal?(move) }
  end
end

class Piece
  attr_accessor :current_position, :color, :board

  COLOR_TO_DIR = {white: -1, black: 1}

  SYM_TO_UNICODE = {
    white: { K: "\u2654", Q: "\u2655", B: "\u2657", R: "\u2656", N: "\u2658", P: "\u2659"},
    black: { K: "\u265A", Q: "\u265B", B: "\u265D", R: "\u265C", N: "\u265E", P: "\u265F"}
  }

  def initialize(current_position, color, board)
    @current_position = current_position
    @color = color
    @board = board
    board[current_position] = self
  end

  def to_s
    SYM_TO_UNICODE[self.color][self.symbol]
  end

  def is_legal?(pos)
    is_valid?(pos) && (empty?(pos) || is_enemy?(pos))
  end

  def empty?(pos)
    # self.class == NullPiece
    board[pos].nil?
  end

  def is_enemy?(pos)
    return false if empty?(pos)
    other_piece = board[pos]
    other_piece.color != self.color
  end

  # def valid_moves(end_pos)
  #   current_row, current_column = current_position
  #   end_row, end_column = end_pos
  #   DIFFERENCES.include?([current_row - end_row, current_column - end_column])
  # end

  def update_position(new_position)
    self.current_position = new_position
  end

  def move_into_check(to_pos)

  end

  def is_valid?(pos)
    return true if pos[0].between?(0, 7) && pos[1].between?(0, 7)
    false
  end
end

class King < Piece
  include Stepable
  def symbol
    :K
  end

  # def move_diffs
  #
  # end
end

class Knight < Piece
  include Stepable
  def symbol
    :N
  end
end

class Bishop < Piece
  include Slideable
  def symbol
    :B
  end
end

class Rook < Piece
  include Slideable
  def symbol
    :R
  end
end

class Queen < Piece
 include Slideable
  def symbol
    :Q
  end
end

class Pawn < Piece
  # PAWN_MOVES = [[1,0], [1,1], [1,-1], [2,0]]

  def symbol
    :P
  end

  def at_start_row?
    if forward_dir == -1 && current_position[0] == 6
      true
    elsif forward_dir == 1 && current_position[0] == 1
      true
    else
      false
    end
  end
 
  def update_position(new_position)
    self.current_position = new_position
    if at_opposite_side?
      self.queen
    end
  end

  def at_opposite_side?
    if forward_dir == -1 && current_position[0] == 0
      debugger
      true 
    elsif forward_dir == 1 && current_position[0] == 7
      true 
    else
      false
    end
  end

  def moves
    forward_steps + side_attacks
  end

  def forward_dir
    COLOR_TO_DIR[color]
  end

  def forward_steps
    steps = []
    current_row, current_column = current_position
    if at_start_row?
      if empty?([(current_row + forward_dir), current_column]) && empty?([(current_row + (forward_dir * 2)), current_column])
        steps << [(current_row + forward_dir), current_column] << [(current_row + (forward_dir * 2)), current_column]
      elsif empty?([(current_row + forward_dir), current_column])
        steps << [(current_row + forward_dir), current_column]
      end
    else
      if is_valid?([current_row + forward_dir, current_column])
        if empty?([(current_row + forward_dir), current_column])
          steps << [(current_row + forward_dir), current_column]
        end
      end
    end
    steps
  end

  def queen
    if forward_dir == -1 && current_position[0] == 0
      new_queen = Queen.new(current_position, color, board)
      board[current_position] = new_queen 
    elsif forward_dir == 1 && current_position[0] == 7
      new_queen = Queen.new(current_position, color, board)
      board[current_position] = new_queen 
    end
  end


  def side_attacks
    steps = []
    current_row, current_column = current_position
    if is_valid?([(current_row + forward_dir), current_column + 1])
      if is_enemy?([(current_row + forward_dir), current_column + 1])
        steps << [(current_row + forward_dir), current_column + 1]
      end
    end

    if is_valid?([(current_row + forward_dir), current_column - 1])
      if is_enemy?([(current_row + forward_dir), current_column - 1])
        steps << [(current_row + forward_dir), current_column - 1]
      end
    end
    steps
  end
end


if __FILE__ == $PROGRAM_NAME
  board = Board.new
  black_king = King.new([1,1], :black, board)
  puts black_king.to_s
end
