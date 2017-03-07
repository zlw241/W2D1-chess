require "colorize"
require_relative "board"
require_relative "cursor"
require "byebug"

class Display
  attr_reader :board, :cursor
  def initialize(board)
    @board = board
    @cursor = Cursor.new([0,0], board)
  end

  def render
    system("clear")
    (0...board.grid.length).each_with_index do |_,index|
      render_background(index)
    end

  end

  def render_background(row_index)
    return_string = ""
    board.grid[row_index].each_with_index do |space,index|
      piece = board[[row_index, index]]
      if piece.nil?
        piece = "   "
      else
        piece = " #{piece.to_s} "
      end

      if [row_index, index] == cursor.cursor_pos
        return_string << piece.colorize({ :background => :red })
      elsif [row_index, index] == board.selected_position
        return_string << piece.colorize({ :background => :blue })
      elsif row_index.even?
        if index.even?
          return_string << piece.colorize({:background => :white})
        else
          return_string << piece.colorize({:background => :grey})
        end
      else
        if index.even?
          return_string << piece.colorize({:background => :grey})
        else
          return_string << piece.colorize({:background => :white})
        end
      end
    end
    if row_index == 0
      captured_str = board.captured_pieces[:white].map { |piece| piece.to_s }
      return_string += captured_str.join
    elsif row_index == 7
      captured_str = board.captured_pieces[:black].map { |piece| piece.to_s }
      return_string += captured_str.join
    end
    puts return_string
  end

  def check_move?(destination)
    start_pos = board.selected_position
    start_piece = board[start_pos]
    valid_moves = start_piece.moves
    valid_moves.include?(destination)
  end

  def play
    message = nil
    render
    while true
      current_cursor = cursor.get_input
      unless current_cursor.nil?
        if board.selected_position.nil?
          board.selected_position = current_cursor unless board[current_cursor].nil?
        else
          if current_cursor == board.selected_position
            board.selected_position = nil
          else
            #if valid move, then move piece and unselect
            destination = current_cursor
            if check_move?(destination)
              board.move_piece(board.selected_position, destination)
              board.selected_position = nil
            else
              message = "That's not a valid move"
            end
          end
        end
      end
      render
      if message
        puts message
        message = nil
      end
    end
  end

end


if __FILE__ == $PROGRAM_NAME
  board = Board.new
  display = Display.new(board)
  display.play
end
#   sleep(1)
#   display.cursor.cursor_pos = [1,0]
#   display.render
#   sleep(1)
#   display.cursor.cursor_pos = [3,0]
#   display.render
# end
