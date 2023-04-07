with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with ANSI_Console;          use  ANSI_Console;
with P_Chaine;              use P_Chaine;
with Ecrir_Messages;        use Ecrir_Messages;
with P_Bal;

procedure Tchat_Client_Tsk is

    subtype T_Chaine_500 is T_Chaine (500);
    package Package_Bal is new P_Bal (T_Chaine_500);
    Bal_Socket : Package_Bal.P_T_Bal;
    Bal_Console : Package_Bal.P_T_Bal;

    Socket : Socket_Type;
    Addr   : Sock_Addr_Type;
    nom    : T_Chaine (500);
    Last   : Integer;
    message : T_Chaine_500;
    messArr : MessageArray;

begin
    Create_Socket (Socket, Family_Inet, Socket_Stream); -- for the server
    Addr.Addr := Addresses (Get_Host_By_Name ("127.0.0.1"), 1);
    Addr.Port := Port_Type'Value ("7777");
    --  connexion Tcp
    Connect_Socket (Socket, Addr); -- for the client
    --  Envoi du pseudo
    Put ("Donner votre nom : ");
    Get_Line (nom);
    Send (Socket, To_String (nom) & ASCII.LF, Last);
    delay 1.0;
    Clear_Screen;
    declare
        task Tsk_Lire_Console;
        task body Tsk_Lire_Console is
            msg : T_Chaine (500);
        begin
            Move_Cursor_To (1, 1);
            Save_Cursor_Position;
            loop
                Get_Line (msg);
                Restore_Cursor_Position;
                Clear_From_Cursor_Up_To_End_Of_Line;
                Bal_Console.Deposer (msg);
            end loop;
        end Tsk_Lire_Console;

        task Tsk_Ecoute_Socket;
        task body Tsk_Ecoute_Socket is
        begin
            loop
                declare
                    msg_rec : constant T_Chaine (500) :=
                    Init_Chaine (Recv (Socket));
                begin
                    Bal_Socket.Deposer (msg_rec);
                end;
            end loop;
        end Tsk_Ecoute_Socket;
    begin
        --  loop boucle pour envoyer des messages ou imprimer sur le terminal
        Put (2, 1, "==================");
        Restore_Cursor_Position;
        messArr := CreateMessAgeArray (10);
        loop
            select
                Bal_Console.Consommer (message);
                Send (Socket, To_String (message), Last);
            or
                delay 0.5;
            end select;
            select
                Bal_Socket.Consommer (message);
                EcrireMessage (messArr, To_String (message));
            or
                delay 0.5;
            end select;
        end loop;
    end;
end Tchat_Client_Tsk;
