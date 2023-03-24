with ANSI_Console;          use ANSI_Console;
with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with P_Chaine;              use P_Chaine;
with Conseil_TicTacToe;     use Conseil_TicTacToe;

procedure TicTacToe_Client is
    Socket : Socket_Type;
    Addr   : Sock_Addr_Type;
    msg    : T_Chaine (500);
    move   : String := "x y";
    pos_x  : Integer;
    pos_y  : Integer;
    player : Character;
    Last   : Integer;
    conseil : T_Conseil := ((' ', ' ', ' '),
    (' ', ' ', ' '),
    (' ', ' ', ' '));
begin
    --  Put_Piece (conseil, 1, 1, 'X');
    --  Log_Conseil (conseil);
    --  delay (1.0);
    --  Clear_Screen;
    --  Put_Piece (conseil, 2, 1, 'O');
    --  Log_Conseil (conseil);
    Create_Socket (Socket, Family_Inet, Socket_Stream);
    Addr.Addr := Addresses (Get_Host_By_Name ("127.0.0.1"), 1);
    Addr.Port := Port_Type'Value ("7777");
    --  connexion Tcp
    Connect_Socket (Socket, Addr);
    --  Envoi du pseudo
    declare
        initial_message : constant T_Chaine (500) :=
            Init_Chaine (Recv (Socket));
    begin
        Put ("You will be player ");
        Put_Line (initial_message);
        player := To_String (initial_message) (1);
    end;
    loop
        -- try two procedures: send and receive
        -- player 1 will play first. send -> receive
        -- player 2 will play after. receive -> send
        Log_Conseil (conseil);
        Put ("Type the position you want to play : ");
        Get_Line (msg);
        --  Update board
        move := To_String (msg);
        pos_x := Char_To_Integer (move (1));
        pos_y := Char_To_Integer (move (3));
        Clear_Screen;
        Put_Piece (conseil, pos_x, pos_y, player);
        --  Envoi
        Send (Socket, To_String (msg), Last);
        Put ("Waiting for the other player...");
        declare
            msg_rec : constant T_Chaine (500) := Init_Chaine (Recv (Socket));
        begin
            Put_Line (msg_rec);
        end;
    end loop;
end TicTacToe_Client;
