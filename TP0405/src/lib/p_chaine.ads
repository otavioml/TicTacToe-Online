package P_Chaine is

    type T_Chaine (Max : Positive) is private;

    function Init_Chaine (ch : String) return T_Chaine;
    function Get_Lg_Chaine (chaine : T_Chaine) return Natural;
    function To_String (chaine : T_Chaine) return String;
    procedure Set_Chaine (chaine : in out T_Chaine; ch : String);
    procedure Get_Line (chaine : out T_Chaine);
    procedure Put_Line (chaine : T_Chaine);

private
    type T_Chaine (Max : Positive) is record
        Ch : String (1 .. Max);
        Lg : Natural := 0;
    end record;
end P_Chaine;
