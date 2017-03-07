require_relative "piece"

class Board
  attr_accessor :grid, :selected_position, :captured_pieces
  def initialize
    @grid = Array.new(8) {Array.new(8)}
    @selected_position = nil
    @captured_pieces = {white: [], black: []}
    populate
  end

  def populate
    populate_pawn(:white)
    populate_side(:white)
    populate_pawn(:black)
    populate_side(:black)
  end

  def populate_pawn(color)
    color_and_pos = {black: 1, white: 6}
    row = color_and_pos[color]
    grid[row].each_with_index do |square, index|
      Pawn.new([row, index], color, self)
    end
  end

  def populate_side(color)
    side_to_row = {black: 0, white: 7}
    row = side_to_row[color]
    Rook.new([row, 0], color, self)
    Rook.new([row, 7], color, self)
    Knight.new([row, 1], color, self)
    Knight.new([row, 6], color, self)
    Bishop.new([row, 2], color, self)
    Bishop.new([row, 5], color, self)
    Queen.new([row, 3], color, self)
    King.new([row, 4], color, self)
  end

  def is_valid?(pos)
    return true if pos[0].between?(0, 7) && pos[1].between?(0, 7)
    false
  end

  def [](position)
    row,column = position
    grid[row][column]
  end

  def []=(position, value)
    row,column = position
    self.grid[row][column] = value
  end

  def move_piece(start_pos, end_pos)
    piece = self[start_pos]
    unless self[end_pos].nil?
      captured_pieces[self[end_pos].color] << self[end_pos]
    end
    self[end_pos] = piece
    self[start_pos] = nil
    piece.update_position(end_pos)
    #add error handling to this from phase 1
  end

  def render
    row_length = 3 * grid[0].length - 3
    puts "-" * row_length
    grid.each do |el|
      display_row = el.join(" | ")
      puts display_row
      puts "-" * display_row.length
    end
  end

  def in_check?(color)
    #color of the king that is being checked to see if in checkment
    king_position = find_king(color)
    all_other_pieces_moves = all_moves_but_king(color)
    all_other_pieces_moves.include?(king_position)
  end

  # def checkmate?(color)
  #
  # end
  #
  # def find_king(color)
  #   board.each_with_index do |row, index1|
  #     row.each_with_index do |space, index2|
  #       king_position = [row, index] if (space.is_a?(King) && space.color == color)
  #     end
  #   end
  #   king_position
  # end
  #
  # def all_moves_but_king(color)
  #   return_array = []
  #   board.each_with_index do |row, index|
  #     row.each_with_index do |space, index|
  #       return_array << [row, index] unless space.is_a?(King) && unless space.color == color
  #     end
  #   end
  #   return_array
  # end


  def in_check?(color)
  end

end

# if __FILE__ == $PROGRAM_NAME
#   board = Board.new
#   board.populate
#   board.render
#   board.move_piece([1,1], [3,1])
#   board.render
# end
