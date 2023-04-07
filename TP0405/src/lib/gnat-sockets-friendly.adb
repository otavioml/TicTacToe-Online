with Ada.Streams;             use Ada.Streams;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Characters.Latin_1;  use Ada.Characters.Latin_1;
with Mojo;                    use Mojo;
with Ada.Text_IO;             use Ada.Text_IO;

package body GNAT.Sockets.Friendly is

    function Send
       (Socket : Socket_Type; Addr : Sock_Addr_Type; Message : String)
        return Integer
    is
        Last : Stream_Element_Offset;
    begin
        Send_Socket (Socket, To_Stream_Element_Array (Message), Last, Addr);
        return Integer (Last);
    end Send;

    procedure Send
       (Socket :     Socket_Type; Addr : Sock_Addr_Type; Message : String;
        Last   : out Integer)
    is
    --  Last : Integer;
    begin
        Last := Send (Socket, Addr, Message);
    end Send;

    procedure Send (Socket : Socket_Type; Message : String; Last : out Integer)
    is
        Fin : Stream_Element_Offset;
    begin
        Send_Socket (Socket, To_Stream_Element_Array (Message), Fin);
        Last := Integer (Fin);
    end Send;

    function Recv
       (Socket : Socket_Type; Addr : out Sock_Addr_Type) return String
    is
        Buffer : Stream_Element_Array (1 .. 1_024);
        Last   : Stream_Element_Offset;
    begin
        Receive_Socket (Socket, Buffer, Last, Addr);
        return To_String (Buffer (Buffer'First .. Last));
    end Recv;

    function Recv (Socket : Socket_Type) return String is
        Buffer : Stream_Element_Array (1 .. 1_024);
        Last   : Stream_Element_Offset;
    begin
        Receive_Socket (Socket, Buffer, Last);
        return To_String (Buffer (Buffer'First .. Last));
    end Recv;

    procedure Put_Clean (Data : String) is
        hex : constant String (1 .. 16) := "0123456789abcdef";
    begin
        Put ("'");
        for I in Data'Range loop
            if Data (I) = '\' then
                Put ("\\");
            elsif Is_Graphic (Data (I)) then
                Put (Data (I));
            elsif Data (I) = LF then
                Put ("\n");
            else
                Put ("\x");
                declare
                    Cur : constant Integer := Character'Pos (Data (I));
                begin
                    Put (hex (1 + Cur / 16));
                    Put (hex (1 + Cur mod 16));
                end;
            end if;
        end loop;
        Put ("'");
    end Put_Clean;

end GNAT.Sockets.Friendly;
