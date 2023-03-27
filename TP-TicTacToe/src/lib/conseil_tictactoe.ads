with P_Chaine;      use P_Chaine;

package Conseil_TicTacToe is

    type T_Conseil is array (1 .. 3, 1 .. 3) of Character;

    procedure Put_Piece (conseil : in out T_Conseil;
    move : T_Chaine; piece : Character);
    procedure Log_Conseil (conseil : T_Conseil);
    function Verify_Win (conseil : T_Conseil) return Boolean;

end Conseil_TicTacToe;
