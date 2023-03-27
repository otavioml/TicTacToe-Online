with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Sockets;          use GNAT.Sockets;
with GNAT.Sockets.Friendly; use GNAT.Sockets.Friendly;

procedure TicTacToe_Serveur is
    type idcli is range 1 .. 100;
    type user (Connected : Boolean := False) is record
        case Connected is
            when False =>
                null;
            when True =>
                login  : access String;
                socket : Socket_Type;
        end case;
    end record;
    Client     : array (idcli) of user := (others => (Connected => False));
    socket     : Socket_Type;
    addr       : Sock_Addr_Type;
    selector   : Selector_Type;
    status     : Selector_Status;
    RSet, WSet : Socket_Set_Type;
    Last       : Integer;
begin
    Create_Socket (socket);
    addr.Addr := Any_Inet_Addr;
    addr.Port := 7_777;
    Bind_Socket (socket, addr);
    Put_Line ("Ecoute sur le port" & Port_Type'Image (addr.Port));
    Listen_Socket (socket);
    Create_Selector (selector);
    Empty (WSet);
    loop
        Empty (RSet);
        Set (RSet, socket);
        for I in idcli loop
            if Client (I).Connected then
                Set (RSet, Client (I).socket);
            end if;
        end loop;
        Check_Selector (selector, RSet, WSet, status);
        case status is
            when Completed =>
                if Is_Set (RSet, socket) then
                    declare
                        pos     : idcli := 1;
                        clisock : Socket_Type;
                        addr    : Sock_Addr_Type;
                    begin
                        while Client (pos).Connected loop
                            pos := pos + 1;
                        end loop;
                        Put ("Connexion" & idcli'Image (pos) & ". ");
                        Flush;
                        if pos < 3 then
                            Accept_Socket (socket, clisock, addr);
                        end if;
                        declare
                            login : String := "x";
                        begin
                            if pos = 1 then
                                login := "X";
                            else
                                login := "O";
                            end if;
                            Put_Line
                                ("You will be player " & login);
                            Client (pos) := (True,
                                new String'(login (1 .. login'Last - 1)),
                                clisock);
                            Send (Client (pos).socket, login, Last);
                        end;
                    end;
                end if;
                for I in idcli loop
                    if Client (I).Connected
                       and then Is_Set (RSet, Client (I).socket)
                    then
                        Put ("Client" & idcli'Image (I) & " veut parler. ");
                        Flush;
                        declare
                            msg : constant String := Recv (Client (I).socket);
                        begin
                            if msg'Length = 0 then
                                Put_Line ("Bye" & idcli'Image (I) & "!");
                                for J in idcli loop
                                    if I /= J and then Client (J).Connected
                                    then
                                        Put ("Envoi vers" & idcli'Image (J) &
                                            ". ");
                                        Flush;
                                        Send
                                           (Client (J).socket,
                                            "** " & Client (I).login.all &
                                            " est parti..." & ASCII.LF,
                                            Last);
                                    end if;
                                end loop;
                                Client (I) := (Connected => False);
                            else
                                Put_Line
                                   ("Received" & Integer'Image (msg'Length) &
                                    " bytes.");
                                for J in idcli loop
                                    --  if I /= J and then Client (J).Connected
                                    if Client (J).Connected and J /= I then
                                        Put ("Sending to" & idcli'Image (J) &
                                            ". ");
                                        Flush;
                                        Send
                                           (Client (J).socket, msg,
                                            Last);
                                    end if;
                                end loop;
                            end if;
                        end;
                    end if;
                end loop;
            when others =>
                Put_Line ("Selector " & Selector_Status'Image (status));
        end case;
    end loop;
end TicTacToe_Serveur;
