with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;

procedure Serveur_Udp is
    Socket : Socket_Type;
    Addr   : Sock_Addr_Type;
begin
    --  Crée une socket UDP
    Create_Socket
       (Socket => Socket, Family => Family_Inet, Mode => Socket_Datagram);
    --  Associe la socket à un port local
    Bind_Socket
       (Socket => Socket, Address => (Family_Inet, Any_Inet_Addr, 7_777));
    Put_Line ("Ecoute du port 7777");
    loop
        declare
            --  Attend d'un datagramme entrant
            Message : constant String := Recv (Socket, Addr);
        begin
            Put_Line (Item => Message & Image (Addr));
        end;
    end loop;
end Serveur_Udp;