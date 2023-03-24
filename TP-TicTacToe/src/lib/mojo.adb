with Ada.Unchecked_Conversion;

package body Mojo is

    function To_Stream_Element_Array
       (Data : String) return Stream_Element_Array
    is
        subtype str is String (Data'Range);
        subtype arr is
           Stream_Element_Array
              (Stream_Element_Offset (Data'First) ..
                     Stream_Element_Offset (Data'Last));
        function magic is new Ada.Unchecked_Conversion (str, arr);
    begin
        return magic (Data);
    end To_Stream_Element_Array;

    function To_String (Data : Stream_Element_Array) return String is
        subtype str is String (Integer (Data'First) .. Integer (Data'Last));
        subtype arr is Stream_Element_Array (Data'Range);
        function magic is new Ada.Unchecked_Conversion (arr, str);
    begin
        return magic (Data);
    end To_String;
end Mojo;
