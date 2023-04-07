with Ada.Text_IO; use Ada.Text_IO;

package body P_Chaine is

    function Init_Chaine (ch : String) return T_Chaine is
        chaine : T_Chaine (500);
    begin
        chaine.Lg                := ch'Last;
        chaine.Ch (1 .. ch'Last) := ch;
        return chaine;
    end Init_Chaine;

    function Get_Lg_Chaine (chaine : T_Chaine) return Natural is
    begin
        return chaine.Lg;
    end Get_Lg_Chaine;

    function To_String (chaine : T_Chaine) return String is
        ch : String (1 .. chaine.Lg);
    begin
        ch := chaine.Ch (1 .. chaine.Lg);
        return ch;
    end To_String;

    procedure Set_Chaine (chaine : in out T_Chaine; ch : String) is
    begin
        chaine.Lg                := ch'Last;
        chaine.Ch (1 .. ch'Last) := ch;
    end Set_Chaine;

    procedure Get_Line (chaine : out T_Chaine) is
        ch : String (1 .. 500);
        lg : Natural := 0;
    begin
        Get_Line (ch, lg);
        chaine := Init_Chaine (ch (1 .. lg));
    end Get_Line;

    procedure Put_Line (chaine : T_Chaine) is
    begin
        Put_Line (chaine.Ch (1 .. chaine.Lg));
    end Put_Line;
end P_Chaine;
