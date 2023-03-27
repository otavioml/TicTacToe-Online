with ANSI_Console;          use ANSI_Console;
with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with P_Chaine;              use P_Chaine;
with Conseil_TicTacToe;     use Conseil_TicTacToe;

procedure TicTacToe_Client is
    Socket          : Socket_Type;
    Addr            : Sock_Addr_Type;
    move_send       : T_Chaine (500);
    player          : Character;
    other_player    : Character;
    Last            : Integer;
    conseil         : T_Conseil := ((' ', ' ', ' '),
    (' ', ' ', ' '),
    (' ', ' ', ' '));
    end_game        : Boolean := False;
begin
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
            Put_Piece (conseil, move_send, player);
            Log_Conseil (conseil);
            --  Envoi
            Send (Socket, To_String (move_send), Last);
            Put ("Waiting for the other player...");
            declare
                move_received : constant T_Chaine (500) :=
                    Init_Chaine (Recv (Socket));
            begin
                Clear_Screen;
                Put_Piece (conseil, move_received, other_player);
                Log_Conseil (conseil);

            end;
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
                    Put_Piece (conseil, move_received, other_player);
                    Log_Conseil (conseil);
                end;
                Clear_Screen;
                Log_Conseil (conseil);
                Put ("Type the position you want to play : ");
                Get_Line (move_send);
                --  Update board
                Clear_Screen;
                Put_Piece (conseil, move_send, player);
                Log_Conseil (conseil);
                --  Envoi
                Send (Socket, To_String (move_send), Last);
                end_game := Verify_Win (conseil);
        end loop;
    end if;
    Put ("Game ended. ");
end TicTacToe_Client;
