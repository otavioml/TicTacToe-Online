with Ada.Text_IO; use Ada.Text_IO;

package body Conseil_TicTacToe is

    procedure Log_Conseil (conseil : T_Conseil) is
    begin
        Put_Line (" ___________");
        for I in 1 .. 3 loop
            Put_Line ("|   |   |   |");
            Put ("| ");
            for J in 1 .. 3 loop
                Put (conseil (I, J));
                Put (" | ");
            end loop;
                New_Line;
            Put_Line ("|___|___|___|");
        end loop;
    end Log_Conseil;

    procedure Put_Piece (conseil : in out T_Conseil;
    x : Integer; y : Integer; piece : Character) is
    begin
        conseil (x, y) := piece;
    end Put_Piece;

end Conseil_TicTacToe;