package Conseil_TicTacToe is

    type T_Conseil is array (1 .. 3, 1 .. 3) of Character;

    procedure Put_Piece (conseil : in out T_Conseil;
    x : Integer; y : Integer; piece : Character);
    procedure Log_Conseil (conseil : T_Conseil);

end Conseil_TicTacToe;