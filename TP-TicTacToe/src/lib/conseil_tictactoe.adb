with Ada.Text_IO;   use Ada.Text_IO;

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

    function Put_Piece (conseil : in out T_Conseil;
    move : T_Chaine; piece : Character) return Boolean is
        move_string : constant String := To_String (move);
        pos_x       : constant Integer := Char_To_Integer (move_string (1));
        pos_y       : constant Integer := Char_To_Integer (move_string (3));
        valid_move  : Boolean := True;
    begin
        if conseil (pos_x, pos_y) = ' ' then
            conseil (pos_x, pos_y) := piece;
        else
            valid_move := False;
        end if;
        return valid_move;
    end Put_Piece;

    function Verify_Win (conseil : T_Conseil) return Boolean is
        Result      : Boolean := False;
        tie_game    : Boolean := True;
    begin
        for I in 1 .. 3 loop
            if conseil (I, 1) = conseil (I, 2) and
            conseil (I, 2) = conseil (I, 3) and
            conseil (I, 1) /= ' '
            then
                Result := True;
            elsif conseil (1, I) = conseil (2, I) and
            conseil (2, I) = conseil (3, I) and
            conseil (1, I) /= ' '
            then
                Result := True;
            end if;
        end loop;
        if conseil (1, 1) = conseil (2, 2) and
        conseil (2, 2) = conseil (3, 3) and
        conseil (1, 1) /= ' '
        then
            Result := True;
        elsif conseil (1, 3) = conseil (2, 2) and
        conseil (2, 2) = conseil (3, 1) and
        conseil (1, 3) /= ' '
        then
            Result := True;
        end if;
        for I in 1 .. 3 loop
            for J in 1 .. 3 loop
                if conseil (I, J) = ' ' then
                    tie_game := False;
                end if;
            end loop;
        end loop;
        if tie_game then
            Result := True;
        end if;
        return Result;
    end Verify_Win;

end Conseil_TicTacToe;
