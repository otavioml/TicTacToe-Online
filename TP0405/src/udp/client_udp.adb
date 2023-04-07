with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with GNAT.Sockets;          use GNAT.Sockets;

procedure Client_Udp is
    Socket : Socket_Type;
    Addr   : Sock_Addr_Type;
    Last   : Integer;
begin
    --  Crée une socket UDP
    Create_Socket
       (Socket => Socket, Family => Family_Inet, Mode => Socket_Datagram);
    --  Envoie le message
    Addr.Addr := Addresses (E => Get_Host_By_Name (Name => "127.0.0.1"));
    Addr.Port := Port_Type'Value ("7777");
    loop
        Send (Socket, Addr, "Hello le serveur !! depuis ", Last);
        Put_Line (Item => "Envoyé : " & Integer'Image (Last));
        delay (1.0);
    end loop;
end Client_Udp;
