generic
    type T_Message is private;

package P_Bal is

    protected type P_T_Bal is
        entry Deposer (Donnee : T_Message);
        entry Consommer (Donnee : out T_Message);
    private
        Message : T_Message;
        EstPleine : Boolean := False;
    end P_T_Bal;

end P_Bal;