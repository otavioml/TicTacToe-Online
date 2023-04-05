with ANSI_Console;          use ANSI_Console;
with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with P_Chaine;              use P_Chaine;
with Conseil_TicTacToe;     use Conseil_TicTacToe;

procedure TicTacToe_Client is
    Socket          : Socket_Type;
    Addr            : Inet_Addr_Type := Any_Inet_Addr ("193.55.161.1");
    Serveur_Port    : Port_Type := 7777;
    move_send       : T_Chaine (500);
    player          : Character;
    other_player    : Character;
    Last            : Integer;
    conseil         : T_Conseil := ((' ', ' ', ' '),
    (' ', ' ', ' '),
    (' ', ' ', ' '));
    end_game        : Boolean := False;
    valid_move      : Boolean;
begin
    Create_Socket (Socket, Family_Inet, Socket_Stream);
    Addr.Addr := Addr;
    Addr.Port := Serveur_Port;
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
        if player = 'X' then
            other_player := 'O';
        else
            other_player := 'X';
        end if;
        Put (other_player);

    end;
    if player = 'X' then
        while end_game = False loop
            --  try two procedures: send and receive
            --  player 1 will play first. send -> receive
            --  player 2 will play after. receive -> send
            Clear_Screen;
            Log_Conseil (conseil);
            Put ("Type the position you want to play : ");
            Get_Line (move_send);
            --  Update board
            Clear_Screen;
            valid_move := Put_Piece (conseil, move_send, player);
            while valid_move = False loop
                Clear_Screen;
                Log_Conseil (conseil);
                Put ("Invalid move. Try again : ");
                Get_Line (move_send);
                valid_move := Put_Piece (conseil, move_send, player);
            end loop;
            Log_Conseil (conseil);
            --  Envoi
            Send (Socket, To_String (move_send), Last);
            end_game := Verify_Win (conseil);
            if end_game = False then
                Put ("Waiting for the other player...");
                declare
                    move_received : constant T_Chaine (500) :=
                        Init_Chaine (Recv (Socket));
                begin
                    Clear_Screen;
                    valid_move :=
                        Put_Piece (conseil, move_received, other_player);
                    Log_Conseil (conseil);

                end;
            end if;
            end_game := Verify_Win (conseil);
        end loop;
    else
        while end_game = False loop
                --  try two procedures: send and receive
                --  player 1 will play first. send -> receive
                --  player 2 will play after. receive -> send
                Clear_Screen;
                Log_Conseil (conseil);
                Put ("Waiting for the other player...");
                declare
                    move_received : constant T_Chaine (500) :=
                        Init_Chaine (Recv (Socket));
                begin
                    Clear_Screen;
                    valid_move :=
                        Put_Piece (conseil, move_received, other_player);
                    Log_Conseil (conseil);
                end;
                end_game := Verify_Win (conseil);
                if end_game = False then
                    Clear_Screen;
                    Log_Conseil (conseil);
                    Put ("Type the position you want to play : ");
                    Get_Line (move_send);
                    --  Update board
                    Clear_Screen;
                    Log_Conseil (conseil);
                    valid_move := Put_Piece (conseil, move_send, player);
                    while valid_move = False loop
                        Clear_Screen;
                        Log_Conseil (conseil);
                        Put ("Invalid move. Try again : ");
                        Get_Line (move_send);
                        valid_move := Put_Piece (conseil, move_send, player);
                    end loop;
                    --  Envoi
                    Send (Socket, To_String (move_send), Last);
                    end_game := Verify_Win (conseil);
                end if;
        end loop;
    end if;
    Put ("Game ended. ");
end TicTacToe_Client;
