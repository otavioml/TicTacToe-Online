with Ada.Streams; use Ada.Streams;

package Mojo is
    function To_Stream_Element_Array
       (Data : String) return Stream_Element_Array;
    function To_String (Data : Stream_Element_Array) return String;
end Mojo;
