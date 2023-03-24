with ANSI_Console;          use ANSI_Console;
with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with P_Chaine;              use P_Chaine;
with Conseil_TicTacToe;     use Conseil_TicTacToe;

procedure TicTacToe_Client is
    Socket : Socket_Type;
    Addr   : Sock_Addr_Type;
    nom    : T_Chaine (500);
    msg    : T_Chaine (500);
    Last   : Integer;
    conseil : T_Conseil := ((' ', ' ', ' '),
    (' ', ' ', ' '),
    (' ', ' ', ' '));
begin
    Put_Piece (conseil, 1, 1, 'X');
    Log_Conseil (conseil);
    delay (1.0);
    Clear_Screen;
    Put_Piece (conseil, 2, 1, 'O');
    Log_Conseil (conseil);
    Create_Socket (Socket, Family_Inet, Socket_Stream);
    Addr.Addr := Addresses (Get_Host_By_Name ("127.0.0.1"), 1);
    Addr.Port := Port_Type'Value ("7777");
    --  connexion Tcp
    Connect_Socket (Socket, Addr);
    --  Envoi du pseudo
    Put ("Donner votre nom : ");
    Get_Line (nom);
    Send (Socket, To_String (nom) & ASCII.LF, Last);
    delay 1.0;
    loop
        Put ("Donner votre message : ");
        Get_Line (msg);
        --  Envoi
        Send (Socket, To_String (msg), Last);
        declare
            msg_rec : constant T_Chaine (500) := Init_Chaine (Recv (Socket));
        begin
            Put_Line (msg_rec);
        end;
    end loop;
end TicTacToe_Client;