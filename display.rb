require "colorize"
require_relative "board"
require_relative "cursor"
require "byebug"

class Display
  attr_reader :board, :cursor
  def initialize(board)
    @board = board
    #@cursor = Cursor.new([0,0], board)
  end

  def render(cursor, message)
    system("clear")
    (0...board.grid.length).each_with_index do |_, index|
      render_background(index, cursor)
    end
    if message
      puts message 
    end 
  end

  def render_background(row_index, cursor)
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
      captured_str = board.captured_pieces[:white].map { |piece| " #{piece.to_s} " }
      return_string += captured_str.join
    elsif row_index == 7
      captured_str = board.captured_pieces[:black].map { |piece| " #{piece.to_s} " }
      return_string += captured_str.join
    end
    puts return_string
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
