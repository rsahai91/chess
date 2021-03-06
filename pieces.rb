require 'colorize'
require 'debugger'

class Piece
  attr_accessor :position, :board, :color, :moved

  ORTHOGONAL = [
    [[-1, 0]],
    [[0, 1]],
    [[1, 0]],
    [[0, -1]]
  ]
  DIAGONAL = [
    [[-1, -1]],
    [[-1, 1]],
    [[1, -1]],
    [[1, 1]]
    ]

  def initialize(position, board = nil, color = nil)
    @position = position
    @board = board
    @color = color
    @moved = false
  end

  def valid_moves(modifiers)
    moves = []
    modifiers.each do |direction|
      direction.each do |modifier|
        new_x = modifier.first + @position.first
        new_y = modifier.last + @position.last
        new_move =  [new_x, new_y]

        break if board.off_board?(new_move) || board.my_piece?(new_move, @color)

        moves << new_move
        break if board[new_move] #will return nil if no piece
      end
    end
    moves
  end

  def moves
    raise "Stop being an asshole, make a real piece"
  end

  def dup(board)
    self.class.new(@position.dup, board, @color)
  end

  def to_show
    raise "Don't call me from piece, dude"
  end

end

class SlidingPiece < Piece

  def move_dirs(directions)
    move_mods = []
    directions.each do |modifiers|
      move_mods << generate_mods(*modifiers)
    end
    move_mods
  end

  def generate_mods(modifier)
    coord_mods = []
    1.upto(7) do |multiplier|
      new_x = modifier.first * multiplier
      new_y = modifier.last * multiplier
      coord_mods << [new_x, new_y]
    end
    coord_mods
  end
end

class King < Piece
  DISPLAY = {:white => "\u265a".light_white, :black => "\u265a".black}
  def moves
    valid_moves
  end

  def valid_moves
    super(Piece::ORTHOGONAL + Piece::DIAGONAL)
  end

  def to_show
    DISPLAY[@color]
  end
end

class Knight < Piece
  DISPLAY = {:white => "\u265e".light_white, :black => "\u265e".black}
  KNIGHT_MOVES = [
    [[1, 2]],
    [[2, 1]],
    [[1, -2]],
    [[2, -1]],
    [[-1, 2]],
    [[-2, 1]],
    [[-1, -2]],
    [[-2, -1]]
  ]

  def moves
    valid_moves
  end

  def valid_moves
    super(KNIGHT_MOVES)
  end

  def to_show
    DISPLAY[@color]
  end
end

class Bishop < SlidingPiece
  DISPLAY = {:white => "\u265d".light_white, :black => "\u265d".black}
  def moves
    valid_moves
  end

  def valid_moves
    super(move_dirs(Piece::DIAGONAL))
  end

  def to_show
    DISPLAY[@color]
  end
end

class Rook < SlidingPiece
  DISPLAY = {:white => "\u265c".light_white, :black => "\u265c".black}
  def moves
    valid_moves
  end

  def valid_moves
    super(move_dirs(Piece::ORTHOGONAL))
  end

  def to_show
    DISPLAY[@color]
  end
end

class Queen < SlidingPiece
  DISPLAY = {:white => "\u265b".light_white, :black => "\u265b".black}
  def moves
    valid_moves
  end

  def valid_moves
    super(move_dirs(Piece::ORTHOGONAL + Piece::DIAGONAL))
  end

  def to_show
    DISPLAY[@color]
  end
end

class Pawn < Piece
  DISPLAY = {:white => "\u265f".light_white, :black => "\u265f".black}
  PAWN_MOVES =
  {
    :white =>
    [
      [[0, -1], [0, -2]],
      [[-1, -1]],
      [[+1, -1]]
    ],
    :black =>
    [
      [[0, 1], [0, 2]],
      [[1, 1]],
      [[-1, 1]]

    ]
  }

  def moves
    valid_moves
  end

  def valid_moves
    moves = []
    PAWN_MOVES[@color].each do |direction|
      direction.each do |modifier|
        new_x = modifier.first + self.position.first
        new_y = modifier.last + self.position.last
        new_move = [new_x, new_y]

        if modifier.first == 0
          break if board.off_board?(new_move)
          break if board[new_move]
        else
          break if board.off_board?(new_move)
          break if !board[new_move]
          break if board.my_piece?(new_move, @color)
        end

        moves << new_move

        break if @color == :black && @position.last != 1
        break if @color == :white && @position.last != 6
      end
    end
    moves
  end

  def to_show
    DISPLAY[@color]
  end
end
