with ANSI_Console;          use  ANSI_Console;

package body Ecrir_Messages is

    function CreateMessAgeArray (max : Integer) return MessageArray is
        ma : MessageArray;
    begin
        ma.Max := max;
        ma.Count := 0;
        return ma;
    end CreateMessAgeArray;

    procedure SetCount (ma : in out MessageArray; count : Integer) is
    begin
        ma.Count := count;
    end SetCount;

    function GetCount (ma : MessageArray) return Integer is
    begin
        return ma.Count;
    end GetCount;

    procedure EcrireMessage (ma : in out MessageArray; message : String) is
    begin
        Put (ma.Count + 3, 1, message);
        SetCount (ma, ma.Count + 1);
        Restore_Cursor_Position;

        if ma.Count > ma.Max then
            Move_Cursor_To (3, 1);
            Clear_From_Cursor_Up_To_End_Of_Line;
            Restore_Cursor_Position;
        end if;
    end EcrireMessage;

end Ecrir_Messages;
