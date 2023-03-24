package GNAT.Sockets.Friendly is

    function Send
       (Socket : Socket_Type; Addr : Sock_Addr_Type; Message : String)
        return Integer;
    procedure Send
       (Socket :     Socket_Type; Addr : Sock_Addr_Type; Message : String;
        Last   : out Integer);
    procedure Send
       (Socket : Socket_Type; Message : String; Last : out Integer);
    function Recv
       (Socket : Socket_Type; Addr : out Sock_Addr_Type) return String;
    function Recv (Socket : Socket_Type) return String;
    procedure Put_Clean (Data : String);

end GNAT.Sockets.Friendly;
