require_relative "player"
require_relative "cursor"
require_relative "board"
require_relative "display"

class Game
  attr_accessor :current_player, :board, :cursor, :display, :player1, :player2

  def initialize(player1, player2)
    @player1 = Player.new(player1, :white)
    @player2 = Player.new(player2, :black)
    @current_player = change_players
    @board = Board.new
    @cursor = Cursor.new([0,0], board)
    @display = Display.new(board)
  end 

  def change_players
    if current_player.nil?
      self.current_player = player1
    end
    if current_player == player1 
      self.current_player = player2
    else
      self.current_player = player1
    end 
  end 

  def check_move?(destination)
    start_pos = board.selected_position
    start_piece = board[start_pos]
    valid_moves = start_piece.moves
    valid_moves.include?(destination)
  end

  def handle_input(current_cursor)
    message = nil
    unless current_cursor.nil?
      if board.selected_position.nil?
        target_piece = board[current_cursor]
        unless target_piece.nil?
          board.selected_position = current_cursor if current_player.team == target_piece.color
        end 
      else
        if current_cursor == board.selected_position
          board.selected_position = nil
        else
          #if valid move, then move piece and unselect
          destination = current_cursor
          if check_move?(destination)
            board.move_piece(board.selected_position, destination)
            board.selected_position = nil
            change_players
          else
            message = "That's not a valid move"
          end
        end
      end
    end
    message 
  end 

  def play
    message = nil
    display.render(cursor)
    while true
      current_cursor = cursor.get_input
      message = handle_input(current_cursor)
      display.render(cursor)
      if message
        puts message
        message = nil
      end
    end
  end

end



if __FILE__ == $PROGRAM_NAME
  game = Game.new("zach", "zach2")
  game.play 
end



