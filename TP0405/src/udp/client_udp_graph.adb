with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;
with GNAT.Sockets;          use GNAT.Sockets;
with Aleatoire;             use Aleatoire;

procedure Client_Udp_Graph is
    Socket : Socket_Type;
    Addr   : Sock_Addr_Type;
    Last   : Integer;
    Rand   : Integer;
begin
    --  Crée une socket UDP
    Create_Socket
       (Socket => Socket, Family => Family_Inet, Mode => Socket_Datagram);
    --  Envoie le message
    Addr.Addr := Addresses (E => Get_Host_By_Name (Name => "127.0.0.1"));
    Addr.Port := Port_Type'Value ("7777");
    Initialise (0, 20);
    loop
        Rand := Random;
        Send (Socket, Addr, Rand'Image, Last);
        Put_Line (Item => "Envoye : " & Integer'Image (Rand));
        delay (1.0);
    end loop;
end Client_Udp_Graph;
