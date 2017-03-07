require "io/console"

KEYMAP = {
  " " => :space,
  "h" => :left,
  "j" => :down,
  "k" => :up,
  "l" => :right,
  "w" => :up,
  "a" => :left,
  "s" => :down,
  "d" => :right,
  "\t" => :tab,
  "\r" => :return,
  "\n" => :newline,
  "\e" => :escape,
  "\e[A" => :up,
  "\e[B" => :down,
  "\e[C" => :right,
  "\e[D" => :left,
  "\177" => :backspace,
  "\004" => :delete,
  "\u0003" => :ctrl_c,
}

MOVES = {
  left: [0, -1],
  right: [0, 1],
  up: [-1, 0],
  down: [1, 0]
}

class Cursor

  attr_accessor :cursor_pos, :board

  def initialize(cursor_pos, board)
    @cursor_pos = cursor_pos
    @board = board
  end

  def get_input
    key = KEYMAP[read_char]
    handle_key(key)
  end

  private

  def read_char
    STDIN.echo = false # stops the console from printing return values

    STDIN.raw! # in raw mode data is given as is to the program--the system
                 # doesn't preprocess special characters such as control-c

    input = STDIN.getc.chr # STDIN.getc reads a one-character string as a
                             # numeric keycode. chr returns a string of the
                             # character represented by the keycode.
                             # (e.g. 65.chr => "A")

    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil # read_nonblock(maxlen) reads
                                                   # at most maxlen bytes from a
                                                   # data stream; it's nonblocking,
                                                   # meaning the method executes
                                                   # asynchronously; it raises an
                                                   # error if no data is available,
                                                   # hence the need for rescue

      input << STDIN.read_nonblock(2) rescue nil
    end

    STDIN.echo = true # the console prints return values again
    STDIN.cooked! # the opposite of raw mode :)

    return input
  end

  def handle_key(key)
    if key == :return || key == :space
      cursor_pos
    elsif key == :left || key == :right || key == :up || key == :down
      update_pos(MOVES[key])
      nil
    elsif key == :ctrl_c
      exit(0)
    end
  end
    # case key
    # when :return || :space
    #   cursor_pos
    # when :left || :right || :up || :down
    #   update_pos(MOVES[key])
    #   nil
    # when :ctrl_c
    #   exit(0)
    # end
  #end

  def update_pos(diff)
    row_diff, col_diff = diff
    row_cursor, col_cursor = cursor_pos
    if (row_cursor + row_diff).between?(0, 7) && (col_cursor + col_diff).between?(0, 7)
      row_cursor += row_diff
      col_cursor += col_diff
    # else
    #   puts "Bad input"
    end
    self.cursor_pos = [row_cursor, col_cursor]
  end
end
