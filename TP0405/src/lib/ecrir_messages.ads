package Ecrir_Messages is
    --  objet pour n'imprimer qu'un certain nombre de lignes
    type MessageArray is private;
    function CreateMessAgeArray (max : Integer) return MessageArray;
    procedure SetCount (ma : in out MessageArray; count : Integer);
    function GetCount (ma : MessageArray) return Integer;
    procedure EcrireMessage (ma : in out MessageArray; message : String);

private

    type MessageArray is record
        Max : Integer;
        Count : Integer;
    end record;

end Ecrir_Messages;
