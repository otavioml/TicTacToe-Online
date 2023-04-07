package body P_Bal is

    protected body P_T_Bal is
        entry Deposer (Donnee : T_Message) when not EstPleine is
        begin
            Message := Donnee;
            EstPleine := True;
        end Deposer;

        entry Consommer (Donnee : out T_Message) when EstPleine is
        begin
                Donnee := Message;
                EstPleine := False;
        end Consommer;

    end P_T_Bal;

end P_Bal;