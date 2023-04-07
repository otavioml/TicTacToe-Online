--  with Ada.Text_IO;

package body ANSI_Console
--  -------------------------------------------------------------------------
--  High Level Text Mode Screen and Console Output.
--  Also Provide Keystroke Assignement.
--
--  Please : be sure your have read the specification before you read
--  the implementation.
--
--  Saturday, November 25 - 2006 - france (somewhere in europe ...)
--  -------------------------------------------------------------------------
--  Contact : les-ziboux@rasama.org
--
--  To learn further more about this package, you may read the following page :
--  http://www.les-ziboux.rasama.org/ada-commandes-echappement-ansi.html
--  Use free of charge as long as the latter link is kept in this file and
--  given in application credits.
--
--  Modified versions are allowed for personal use only and not for distributed
--  softwares (free of charge or not). Please : send me feed-back for any
--  request, included suspected bug, request for functionality, suspect wrong
--  behaviour, and any thing else, and do not distribut modified version.
--
--  Saturday, November 25 - 2006 - france (somewhere in europe ...)
--  -------------------------------------------------------------------------

is

    --  ======================================================================
    --  Important notes :
    --  ----------------------------------------------------------------------
    --  o    This implementation depends on values of
    --      Maximum_Screen_Height and Maximum_Screen_Width. From those value,
    --      is deduced the maximum string length represented the corresponding
    --      value in decimal. Actualy, with this implementation, maximum length
    --      of both is 4. And maximum length for other decimal strings is 2. So
    --      the longest is 4.
    --  o    Output is first prepared in a small buffer, before being sent to
    --      the output stream. Buffers are local to procedures, so tis way
    --      the package is reentrant.

    --  ======================================================================
    --  Organisation of this implementation
    --  ----------------------------------------------------------------------
    --  O Command buffer
    --  o        Type and constantes for buffer size
    --  o        Type for buffer content
    --  o        Buffer
    --  o        Buffer initialisation and appending
    --  o        Procedures to send the buffer content to the output stream
    --  O Text output and erasing of screen
    --  o        Simply text output procedures (provided for consistency).
    --  o        Simply character output procedures (provided for consistency).
    --  o        Simply character input procedures (provided for consistency).
    --  o        Procedures for clearing screen or part of line.
    --  O Text color and attributes
    --  o        Procedures for setting text color.
    --  o        Procedure for setting text attributs (blinking and the like).
    --  O Cursor position and movement
    --  o        Procedure fixing cursor position
    --  o        Procedures moving cursor position
    --  o        Procedures for saving/restoring cursor position
    --  O Screen modes (resolution) and output behaviour
    --  o        Procedures for fixing screen mode (screen resolution)
    --  o        Procedures for fixing screen behaviour (line wrapping)
    --  O Keystroke assignements
    --  o        Function for keystroke string code
    --  o        Procedure for assigning key-stroke to string

    --  ======================================================================
    --  Command buffer
    --  ----------------------------------------------------------------------

    --  Type and constantes for buffer size
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  Maximum buffered string length is 12 (see length details in each
    --  procedure).
    Maximum_Buffered_Length : constant Positive := 12;

    subtype Buffer_Count_Type is Natural range 0 .. Maximum_Buffered_Length;

    subtype Buffer_Index_Type is
       Buffer_Count_Type range 1 .. Buffer_Count_Type'Last;

    --  Type for buffer content
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    subtype Buffer_Content_Type is String (Buffer_Index_Type);

    --  Buffer
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    type Buffer_Type is record
        Count   : Buffer_Count_Type := 0; -- Always initialy empty.
        Content : Buffer_Content_Type;
    end record;

    --  Buffer initialisation and appending
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Start (Buffer : out Buffer_Type);
    procedure Start (Buffer : out Buffer_Type) is
    begin
        Buffer.Count       := 2;
        Buffer.Content (1) := Character'Val (27);
        Buffer.Content (2) := '[';
    end Start;

    procedure Append (Buffer : in out Buffer_Type; C : Character);
    procedure Append (Buffer : in out Buffer_Type; C : Character) is
    begin
        Buffer.Count                  := Buffer.Count + 1;
        Buffer.Content (Buffer.Count) := C;
    end Append;

    procedure Append (Buffer : in out Buffer_Type; S : String);
    procedure Append (Buffer : in out Buffer_Type; S : String) is
        i : Buffer_Index_Type;
        j : Buffer_Index_Type;
    begin
        i                       := Buffer.Count + 1;
        j := Buffer.Count + S'Length; -- i.e. same as (i - 1) + S'Length
        Buffer.Content (i .. j) := S;
        Buffer.Count            := Buffer.Count + S'Length;
    end Append;

    procedure Append (Buffer : in out Buffer_Type; N : Natural);
    procedure Append (Buffer : in out Buffer_Type; N : Natural) is
        E : Natural; -- Expression - to work on a copy of N.
    begin
        --  The fastest code ...
        --  48 is the ASCII code for the character '0' (zero).
        if N <= 9 then
            Buffer.Count                  := Buffer.Count + 1;
            Buffer.Content (Buffer.Count) := Character'Val (48 + N);
        elsif N <= 99 then
            Buffer.Content (Buffer.Count + 1) := Character'Val (48 + N / 10);
            Buffer.Content (Buffer.Count + 2) := Character'Val (48 + N rem 10);
            Buffer.Count                      := Buffer.Count + 2;
        elsif N <= 999 then
            E                                 := N;
            Buffer.Content (Buffer.Count + 3) := Character'Val (48 + E rem 10);
            E                                 := E / 10;
            Buffer.Content (Buffer.Count + 2) := Character'Val (48 + E rem 10);
            Buffer.Content (Buffer.Count + 1) := Character'Val (48 + E / 10);
            Buffer.Count                      := Buffer.Count + 3;
        else
            E                                 := N;
            Buffer.Content (Buffer.Count + 4) := Character'Val (48 + E rem 10);
            E                                 := E / 10;
            Buffer.Content (Buffer.Count + 3) := Character'Val (48 + E rem 10);
            E                                 := E / 10;
            Buffer.Content (Buffer.Count + 2) := Character'Val (48 + E rem 10);
            Buffer.Content (Buffer.Count + 1) := Character'Val (48 + E / 10);
            Buffer.Count                      := Buffer.Count + 4;
        end if;
    end Append;

    --  Procedures to send the buffer content to the output stream
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  Constant command strings are sent directly using Put_Command_String,
    --  bypassing Put via Buffer.

    procedure Put_Command_String (S : String) renames Ada.Text_IO.Put;

    procedure Put_Command_String (Stream : Stream_Type; S : String) renames
       Ada.Text_IO.Put;

    procedure Put (Buffer : Buffer_Type);
    procedure Put (Buffer : Buffer_Type) is
    begin
        Put_Command_String
           (Buffer.Content (Buffer.Content'First .. Buffer.Count));
    end Put;

    procedure Put (Stream : Stream_Type; Buffer : Buffer_Type);
    procedure Put (Stream : Stream_Type; Buffer : Buffer_Type) is
    begin
        Put_Command_String
           (Stream, Buffer.Content (Buffer.Content'First .. Buffer.Count));
    end Put;

    --  ======================================================================
    --  Text output and erasing of screen
    --  ----------------------------------------------------------------------

    --  Simply text output procedures (provided for consistency).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Put (Text : String) renames Ada.Text_IO.Put;

    procedure Put (Stream : Stream_Type; Text : String) renames
       Ada.Text_IO.Put;

    procedure Put
       (Line : Vertical_Position_Type; Column : Horizontal_Position_Type;
        Text : String)
    is
    begin
        Move_Cursor_To (Line, Column);
        Ada.Text_IO.Put (Text);
    end Put;

    procedure Put
       (Stream : Stream_Type; Line : Vertical_Position_Type;
        Column : Horizontal_Position_Type; Text : String)
    is
    begin
        Move_Cursor_To (Line, Column);
        Ada.Text_IO.Put (Stream, Text);
    end Put;

    --  Simply character output procedures (provided for consistency).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Put (C : Character) renames Ada.Text_IO.Put;

    procedure Put (Stream : Stream_Type; C : Character) renames
       Ada.Text_IO.Put;

    procedure Put
       (Line : Vertical_Position_Type; Column : Horizontal_Position_Type;
        C    : Character)
    is
    begin
        Move_Cursor_To (Line, Column);
        Ada.Text_IO.Put (C);
    end Put;

    procedure Put
       (Stream : Stream_Type; Line : Vertical_Position_Type;
        Column : Horizontal_Position_Type; C : Character)
    is
    begin
        Move_Cursor_To (Line, Column);
        Ada.Text_IO.Put (Stream, C);
    end Put;

    procedure Beep is
    begin
        Put (Character'Val (7));
    end Beep;

    procedure Beep (Stream : Stream_Type) is
    begin
        Put (Stream, Character'Val (7));
    end Beep;

    --  Simply character input procedures (provided for consistency).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    procedure Get (C : out Character) renames Ada.Text_IO.Get;

    procedure Get (Stream : Stream_Type; C : out Character) renames
       Ada.Text_IO.Get;

    procedure Get
       ( -- Non-blocking character input.
        C : out Character; Available : out Boolean) renames
       Ada.Text_IO.Get_Immediate;

    procedure Get
       ( -- Non-blocking character input.
        Stream    :     Stream_Type; C : out Character;
        Available : out Boolean) renames
       Ada.Text_IO.Get_Immediate;

    procedure Decode_Key_With_Prefix_0
       (Input        :     Character; Key : out Key_Type;
        Modifier_Key : out Modifier_Key_Type; Ok : out Boolean);
    procedure Decode_Key_With_Prefix_0
       (Input        :     Character; Key : out Key_Type;
        Modifier_Key : out Modifier_Key_Type; Ok : out Boolean)
    is
    begin
        --  This line factorised here
        Ok := True;
        --  Start of job
        case Character'Pos (Input) is
            --  Codes indicating no modifier key
            when 59 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F1;
            when 60 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F2;
            when 61 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F3;
            when 62 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F4;
            when 63 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F5;
            when 64 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F6;
            when 65 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F7;
            when 66 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F8;
            when 67 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F9;
            when 68 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F10;
            when 71 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Home;
            when 72 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Up_Arrow;
            when 73 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Page_Up;
            when 75 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Left_Arrow;
            when 77 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Right_Arrow;
            when 79 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_End;
            when 80 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Down_Arrow;
            when 81 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Page_Down;
            when 82 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Insert;
            when 83 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Keypad_Delete;
                --  This two ones normally start with prefix 224,
                --  but may start with prefix 0 on some systems.
            when 133 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F11;
            when 134 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F12;
                --  Codes indicating ALT
            when 104 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F1;
            when 105 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F2;
            when 106 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F3;
            when 107 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F4;
            when 108 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F5;
            when 109 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F6;
            when 110 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F7;
            when 111 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F8;
            when 112 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F9;
            when 113 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F10;
            when 151 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Home;
            when 152 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Up_Arrow;
            when 153 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Page_Up;
            when 155 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Left_Arrow;
            when 157 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Right_Arrow;
            when 159 =>
                Modifier_Key := Alt_Key;
                Key          := Key_End;
            when 160 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Down_Arrow;
            when 161 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Page_Down;
            when 162 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Insert;
            when 163 =>
                Modifier_Key := Alt_Key;
                Key          := Key_Delete;
                --  Codes indicating CTRL
            when 94 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F1;
            when 95 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F2;
            when 96 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F3;
            when 97 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F4;
            when 98 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F5;
            when 99 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F6;
            when 100 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F7;
            when 101 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F8;
            when 102 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F9;
            when 103 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F10;
            when 119 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Home;
            when 141 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Up_Arrow;
            when 132 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Page_Up;
            when 115 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Left_Arrow;
            when 116 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Right_Arrow;
            when 117 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_End;
            when 145 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Down_Arrow;
            when 118 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Page_Down;
            when 146 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Insert;
            when 147 =>
                Modifier_Key := Ctrl_Key;
                Key          := Keypad_Delete;
            when 148 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Tab;
                --  Codes indicating SHIFT
            when 84 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F1;
            when 85 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F2;
            when 86 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F3;
            when 87 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F4;
            when 88 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F5;
            when 89 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F6;
            when 90 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F7;
            when 91 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F8;
            when 92 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F9;
            when 93 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F10;
                --  Nothing
            when others =>
                Ok := False;
        end case;
    end Decode_Key_With_Prefix_0;

    procedure Decode_Key_With_Prefix_224
       (Input        :     Character; Key : out Key_Type;
        Modifier_Key : out Modifier_Key_Type; Ok : out Boolean);
    procedure Decode_Key_With_Prefix_224
       (Input        :     Character; Key : out Key_Type;
        Modifier_Key : out Modifier_Key_Type; Ok : out Boolean)
    is
    begin
        --  This line factorised here
        Ok := True;
        --  Start of job
        case Character'Pos (Input) is
            --  Codes indicating no modifier key
            when 133 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F11;
            when 134 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_F12;
            when 71 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Home;
            when 72 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Up_Arrow;
            when 73 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Page_Up;
            when 75 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Left_Arrow;
            when 77 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Right_Arrow;
            when 79 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_End;
            when 80 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Down_Arrow;
            when 81 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Page_Down;
            when 82 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Insert;
            when 83 =>
                Modifier_Key := No_Modifier_Key;
                Key          := Key_Delete;
                --  Codes indicating ALT
            when 139 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F11;
            when 140 =>
                Modifier_Key := Alt_Key;
                Key          := Key_F12;
                --  Codes indicating CTRL
            when 137 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F11;
            when 138 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_F12;
            when 119 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Home;
            when 141 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Up_Arrow;
                --  Same code as F12
                --  when 134 =>
                --  Modifier_Key := Ctrl_Key;
                --  Key := Key_Page_Up;
            when 115 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Left_Arrow;
            when 116 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Right_Arrow;
            when 117 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_End;
            when 145 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Down_Arrow;
            when 118 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Page_Down;
            when 146 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Insert;
            when 147 =>
                Modifier_Key := Ctrl_Key;
                Key          := Key_Delete;
                --  Codes indicating SHIFT
            when 135 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F11;
            when 136 =>
                Modifier_Key := Shift_Key;
                Key          := Key_F12;
                --  Nothing
            when others =>
                Ok := False;
        end case;
    end Decode_Key_With_Prefix_224;

    procedure Decode_Key_With_No_Prefix
       (Input        :     Character; Key : out Key_Type;
        Modifier_Key : out Modifier_Key_Type; Ok : out Boolean);
    procedure Decode_Key_With_No_Prefix
       (Input        :     Character; Key : out Key_Type;
        Modifier_Key : out Modifier_Key_Type; Ok : out Boolean)
    is
    begin
        --  This line is factorised here
        Ok           := True;
        Modifier_Key := No_Modifier_Key;
        --  Start of job
        case Character'Pos (Input) is
            when 8 =>
                Key := Key_Backspace;
            when 9 =>
                Key := Key_Tab;
            when 13 =>
                Key := Key_Enter;
            when 27 =>
                Key := Key_Escape;
            when 32 =>
                Key := Key_Space;
            when 48 =>
                Key := Key_0;
            when 49 =>
                Key := Key_1;
            when 50 =>
                Key := Key_2;
            when 51 =>
                Key := Key_3;
            when 52 =>
                Key := Key_4;
            when 53 =>
                Key := Key_5;
            when 54 =>
                Key := Key_6;
            when 55 =>
                Key := Key_7;
            when 56 =>
                Key := Key_8;
            when 57 =>
                Key := Key_9;
            when 65 =>
                Key := Key_A;
            when 66 =>
                Key := Key_B;
            when 67 =>
                Key := Key_C;
            when 68 =>
                Key := Key_D;
            when 69 =>
                Key := Key_E;
            when 70 =>
                Key := Key_F;
            when 71 =>
                Key := Key_G;
            when 72 =>
                Key := Key_H;
            when 73 =>
                Key := Key_I;
            when 74 =>
                Key := Key_J;
            when 75 =>
                Key := Key_K;
            when 76 =>
                Key := Key_L;
            when 77 =>
                Key := Key_M;
            when 78 =>
                Key := Key_N;
            when 79 =>
                Key := Key_O;
            when 80 =>
                Key := Key_P;
            when 81 =>
                Key := Key_Q;
            when 82 =>
                Key := Key_R;
            when 83 =>
                Key := Key_S;
            when 84 =>
                Key := Key_T;
            when 85 =>
                Key := Key_U;
            when 86 =>
                Key := Key_V;
            when 87 =>
                Key := Key_W;
            when 88 =>
                Key := Key_X;
            when 89 =>
                Key := Key_Y;
            when 90 =>
                Key := Key_Z;
            when 97 =>
                Key := Key_A;
            when 98 =>
                Key := Key_B;
            when 99 =>
                Key := Key_C;
            when 100 =>
                Key := Key_D;
            when 101 =>
                Key := Key_E;
            when 102 =>
                Key := Key_F;
            when 103 =>
                Key := Key_G;
            when 104 =>
                Key := Key_H;
            when 105 =>
                Key := Key_I;
            when 106 =>
                Key := Key_J;
            when 107 =>
                Key := Key_K;
            when 108 =>
                Key := Key_L;
            when 109 =>
                Key := Key_M;
            when 110 =>
                Key := Key_N;
            when 111 =>
                Key := Key_O;
            when 112 =>
                Key := Key_P;
            when 113 =>
                Key := Key_Q;
            when 114 =>
                Key := Key_R;
            when 115 =>
                Key := Key_S;
            when 116 =>
                Key := Key_T;
            when 117 =>
                Key := Key_U;
            when 118 =>
                Key := Key_V;
            when 119 =>
                Key := Key_W;
            when 120 =>
                Key := Key_X;
            when 121 =>
                Key := Key_Y;
            when 122 =>
                Key := Key_Z;
            when others =>
                Ok := False;
        end case;
    end Decode_Key_With_No_Prefix;

    procedure Get_Key
       ( -- Non-blocking key input - See note below
        Keystroke_Input : out Keystroke_Input_Type) is
        Input     : Character;
        Available : Boolean;
    begin
        --  This two lines are factorised here.
        Keystroke_Input.Key_Available       := False;
        Keystroke_Input.Character_Available := False;
        --  Start of job
        Get (Input, Available);
        if not Available then
            return;
        end if;
        case Character'Pos (Input) is
            when 0 =>
                Get (Input, Available);
                if not Available then -- Should we notify an error ?.
                    return;
                end if;
                --  Should we notify an error when no key was decoded ?
                Decode_Key_With_Prefix_0
                   (Input, Keystroke_Input.Key, Keystroke_Input.Modifier_Key,
                    Keystroke_Input.Key_Available);
            when 224 =>
                Get (Input, Available);
                if not Available then -- Should we notify an error ?.
                    return;
                end if;
                --  Should we notify an error when no key was decoded ?
                Decode_Key_With_Prefix_224
                   (Input, Keystroke_Input.Key, Keystroke_Input.Modifier_Key,
                    Keystroke_Input.Key_Available);
            when 240 =>
                --  This a special case, the only one of this kind.
                --  Cannot be interpreted... seems to be an error code
                --  or a placeholder.
                return;
            when others =>
                Keystroke_Input.C                   := Input;
                Keystroke_Input.Character_Available := True;
                Decode_Key_With_No_Prefix
                   (Input, Keystroke_Input.Key, Keystroke_Input.Modifier_Key,
                    Keystroke_Input.Key_Available);
        end case;
    end Get_Key;

    procedure Get_Key
       (Stream : Stream_Type; Keystroke_Input : out Keystroke_Input_Type)
    is
        Input     : Character;
        Available : Boolean;
    begin
        --  This two lines are factorised here.
        Keystroke_Input.Key_Available       := False;
        Keystroke_Input.Character_Available := False;
        --  Start of job
        Get (Stream, Input, Available);
        if not Available then
            return;
        end if;
        case Character'Pos (Input) is
            when 0 =>
                Get (Stream, Input, Available);
                if not Available then -- Should we notify an error ?.
                    return;
                end if;
                --  Should we notify an error when no key was decoded ?
                Decode_Key_With_Prefix_0
                   (Input, Keystroke_Input.Key, Keystroke_Input.Modifier_Key,
                    Keystroke_Input.Key_Available);
            when 224 =>
                Get (Stream, Input, Available);
                if not Available then -- Should we notify an error ?.
                    return;
                end if;
                --  Should we notify an error when no key was decoded ?
                Decode_Key_With_Prefix_224
                   (Input, Keystroke_Input.Key, Keystroke_Input.Modifier_Key,
                    Keystroke_Input.Key_Available);
            when 240 =>
                --  This a special case, the only one of this kind.
                --  Cannot be interpreted... seems to be an error code
                --  or a placeholder.
                return;
            when others =>
                Keystroke_Input.C                   := Input;
                Keystroke_Input.Character_Available := True;
                Decode_Key_With_No_Prefix
                   (Input, Keystroke_Input.Key, Keystroke_Input.Modifier_Key,
                    Keystroke_Input.Key_Available);
        end case;
    end Get_Key;

    --  Procedures for clearing screen or part of line.
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Clear_Screen -- Implements ESC[2J
    is
        S : constant String := Character'Val (27) & "[2J";
    begin
        --  Maximum string length : 1 + 1 + 1 + 1 = 4
        Put_Command_String (S);
    end Clear_Screen;

    procedure Clear_Screen (Stream : Stream_Type) is
        S : constant String := Character'Val (27) & "[2J";
    begin
        Put_Command_String (Stream, S);
    end Clear_Screen;

    procedure Clear_From_Cursor_Up_To_End_Of_Line -- Implements ESC[K
    is
        S : constant String := Character'Val (27) & "[K";
    begin
        --  Maximum string length : 1 + 1 + 1 = 3
        Put_Command_String (S);
    end Clear_From_Cursor_Up_To_End_Of_Line;

    procedure Clear_From_Cursor_Up_To_End_Of_Line (Stream : Stream_Type) is
        S : constant String := Character'Val (27) & "[K";
    begin
        Put_Command_String (Stream, S);
    end Clear_From_Cursor_Up_To_End_Of_Line;

    --  ======================================================================
    --  Text color and attributes
    --  ----------------------------------------------------------------------

    --  Procedures for setting text color.
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Text_Color_Code : constant array (Color_Type) of Natural :=
       (Black   => 30, Red => 31, Green => 32, Yellow => 33, Blue => 34,
        Magenta => 35, Cyan => 36, White => 37);

    procedure Set_Text_Color
       ( -- Implements part of ESC[Ps;...;Psm
        Color : Color_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 2 + 1 = 5
        Start (B);
        Append (B, Text_Color_Code (Color));
        Append (B, 'm');
        Put (B);
    end Set_Text_Color;

    procedure Set_Text_Color (Stream : Stream_Type; Color : Color_Type) is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Text_Color_Code (Color));
        Append (B, 'm');
        Put (Stream, B);
    end Set_Text_Color;

    Background_Color_Code : constant array (Color_Type) of Natural :=
       (Black   => 40, Red => 41, Green => 42, Yellow => 43, Blue => 44,
        Magenta => 45, Cyan => 46, White => 47);

    procedure Set_Background_Color
       ( -- Implements part of ESC[Ps;...;Psm
        Color : Color_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 2 + 1 = 5
        Start (B);
        Append (B, Background_Color_Code (Color));
        Append (B, 'm');
        Put (B);
    end Set_Background_Color;

    procedure Set_Background_Color (Stream : Stream_Type; Color : Color_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Background_Color_Code (Color));
        Append (B, 'm');
        Put (Stream, B);
    end Set_Background_Color;

    --  Procedure for setting text attributs (blinking and the like...).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Text_Attributes_Code : constant array (Text_Attributes_Type) of Natural :=
       (Default_Text_Attributes => 0, Bold_Text => 1, Thin_Text => 2,
        Standout_Text           => 3, Underlined_Text => 4, Blinking_Text => 5,
        Reversed_Colors         => 7, Hidden_Text => 8, Normal_Text => 22,
        Not_Standout_Text       => 23, Not_Underlined_Text => 24,
        Not_Blinking_Text       => 25, Not_Reversed_Text => 27);

    procedure Set_Text_Attributes
       ( -- Implements part of ESC[Ps;...;Psm
        Text_Attributes : Text_Attributes_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 2 + 1 = 5
        Start (B);
        Append (B, Text_Attributes_Code (Text_Attributes));
        Append (B, 'm');
        Put (B);
    end Set_Text_Attributes;

    procedure Set_Text_Attributes
       (Stream : Stream_Type; Text_Attributes : Text_Attributes_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Text_Attributes_Code (Text_Attributes));
        Append (B, 'm');
        Put (Stream, B);
    end Set_Text_Attributes;

    --  ======================================================================
    --  Cursor position and movement
    --  ----------------------------------------------------------------------

    --  Procedure fixing cursor position
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Move_Cursor_To
       ( -- Implements ESC[PL;PcH  (same as ESC[PL;Pcf)
        Line : Vertical_Position_Type; Column : Horizontal_Position_Type)
    is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 4 + 1 + 4 + 1 = 12
        Start (B);
        Append (B, Line);
        Append (B, ';');
        Append (B, Column);
        Append (B, 'H');
        Put (B);
    end Move_Cursor_To;

    procedure Move_Cursor_To
       (Stream : Stream_Type; Line : Vertical_Position_Type;
        Column : Horizontal_Position_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Line);
        Append (B, ';');
        Append (B, Column);
        Append (B, 'H');
        Put (Stream, B);
    end Move_Cursor_To;

    --  Procedures moving cursor position
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Move_Cursor_Up
       ( -- Implements ESC[PnA
        Count : Vertical_Delta_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 4 + 1 = 7
        Start (B);
        Append (B, Count);
        Append (B, 'A');
        Put (B);
    end Move_Cursor_Up;

    procedure Move_Cursor_Up
       (Stream : Stream_Type; Count : Vertical_Delta_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Count);
        Append (B, 'A');
        Put (Stream, B);
    end Move_Cursor_Up;

    procedure Move_Cursor_Down
       ( -- Implements ESC[PnB
        Count : Vertical_Delta_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 4 + 1 = 7
        Start (B);
        Append (B, Count);
        Append (B, 'B');
        Put (B);
    end Move_Cursor_Down;

    procedure Move_Cursor_Down
       (Stream : Stream_Type; Count : Vertical_Delta_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Count);
        Append (B, 'B');
        Put (Stream, B);
    end Move_Cursor_Down;

    procedure Move_Cursor_Right
       ( -- Implements ESC[PnC
        Count : Horizontal_Delta_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 4 + 1 = 7
        Start (B);
        Append (B, Count);
        Append (B, 'C');
        Put (B);
    end Move_Cursor_Right;

    procedure Move_Cursor_Right
       (Stream : Stream_Type; Count : Horizontal_Delta_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Count);
        Append (B, 'C');
        Put (Stream, B);
    end Move_Cursor_Right;

    procedure Move_Cursor_Left
       ( -- Implements ESC[PnD
        Count : Horizontal_Delta_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 4 + 1 = 7
        Start (B);
        Append (B, Count);
        Append (B, 'D');
        Put (B);
    end Move_Cursor_Left;

    procedure Move_Cursor_Left
       (Stream : Stream_Type; Count : Horizontal_Delta_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Count);
        Append (B, 'D');
        Put (Stream, B);
    end Move_Cursor_Left;

    --  Procedures for saving/restoring cursor position
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Save_Cursor_Position -- Implements ESC[s
    is
        S : constant String := Character'Val (27) & "[s";
    begin
        --  Maximum string length : 1 + 1 + 1 = 3
        Put_Command_String (S);
    end Save_Cursor_Position;

    procedure Save_Cursor_Position (Stream : Stream_Type) is
        S : constant String := Character'Val (27) & "[s";
    begin
        Put_Command_String (Stream, S);
    end Save_Cursor_Position;

    procedure Restore_Cursor_Position -- Implements ESC[u
    is
        S : constant String := Character'Val (27) & "[u";
    begin
        --  Maximum string length : 1 + 1 + 1 = 3
        Put_Command_String (S);
    end Restore_Cursor_Position;

    procedure Restore_Cursor_Position (Stream : Stream_Type) is
        S : constant String := Character'Val (27) & "[u";
    begin
        Put_Command_String (Stream, S);
    end Restore_Cursor_Position;

    --  =====================================================================
    --  Screen modes (resolution) and output behaviour
    --  ----------------------------------------------------------------------

    --  Procedures for fixing screen mode (screen resolution)
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Screen_Mode_Code : constant array (Screen_Mode_Type) of Natural :=
       (Monochrome_Text_Mode_40x25      => 0, Color_Text_Mode_40x25 => 1,
        Monochrome_Text_Mode_80x25      => 2, Color_Text_Mode_80x25 => 3,
        Color4_Graphic_Mode_320x200 => 4, Monochrome_Graphic_Mode_320x200 => 5,
        Monochrome_Graphic_Mode_640x200 => 6, Color_Graphic_Mode_320x200 => 13,
        Color16_Graphic_Mode_640x200    => 14,
        Monochrome_Graphic_Mode_640x350 => 15,
        Color16_Graphic_Mode_640x350    => 16,
        Monochrome_Graphic_Mode_640x480 => 17,
        Color16_Graphic_Mode_640x480    => 18,
        Color256_Graphic_Mode_320x200   => 19);

    procedure Set_Screen_Mode
       ( -- Implements part of ESC[=Psh
        Screen_Mode : Screen_Mode_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 1 + 2 + 1 = 6
        Start (B);
        Append (B, '=');
        Append (B, Screen_Mode_Code (Screen_Mode));
        Append (B, 'h');
        Put (B);
    end Set_Screen_Mode;

    procedure Set_Screen_Mode
       (Stream : Stream_Type; Screen_Mode : Screen_Mode_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, '=');
        Append (B, Screen_Mode_Code (Screen_Mode));
        Append (B, 'h');
        Put (Stream, B);
    end Set_Screen_Mode;

    procedure Reset_Screen_Mode
       ( -- Implements ESC[=Psl
        Screen_Mode : Screen_Mode_Type) is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + 1 + 2 + 1 = 6
        Start (B);
        Append (B, '=');
        Append (B, Screen_Mode_Code (Screen_Mode));
        Append (B, 's');
        Put (B);
    end Reset_Screen_Mode;

    procedure Reset_Screen_Mode
       (Stream : Stream_Type; Screen_Mode : Screen_Mode_Type)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, '=');
        Append (B, Screen_Mode_Code (Screen_Mode));
        Append (B, 's');
        Put (Stream, B);
    end Reset_Screen_Mode;

    --  Procedures for fixing screen behaviour (line wrapping)
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Enable_Line_Wrapping -- Implements part of ESC[=Psh
    is
        S : constant String := Character'Val (27) & "[=7h";
    begin
        --  Maximum string length : 1 + 1 + 1 + 1 + 1 = 5
        Put_Command_String (S);
    end Enable_Line_Wrapping;

    procedure Enable_Line_Wrapping (Stream : Stream_Type) is
        S : constant String := Character'Val (27) & "[=7h";
    begin
        Put_Command_String (Stream, S);
    end Enable_Line_Wrapping;

    procedure Disable_Line_Wrapping -- Implements part of ESC[=Psl
    is
        S : constant String := Character'Val (27) & "[=7l";
    begin
        --  Maximum string length : 1 + 1 + 1 + 1 + 1 = 5
        Put_Command_String (S);
    end Disable_Line_Wrapping;

    procedure Disable_Line_Wrapping (Stream : Stream_Type) is
        S : constant String := Character'Val (27) & "[=7l";
    begin
        Put_Command_String (Stream, S);
    end Disable_Line_Wrapping;

    --  ======================================================================
    --  Keystroke assignements
    --  ---------------------------------------------------------------------

    --  Function for keystroke string code
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  As string lengths vary, an associative array cannot be used,
    --  so it is implemented as a function built on a case statement.
    --  The second good raison for using a function in place of an
    --  associative array, is that an array cannot raise an exception :P
    --  ... and we may need to raise Illegal_Keystroke in case of an
    --  illegal modifier+key combination.

    function Key_String_Code_Whith_No_Modifier_Key
       (Key : Key_Type) return String;
    function Key_String_Code_Whith_No_Modifier_Key
       (Key : Key_Type) return String
    is
    begin
        case Key is
            when Key_F1 =>
                return "0;59";
            when Key_F2 =>
                return "0;60";
            when Key_F3 =>
                return "0;61";
            when Key_F4 =>
                return "0;62";
            when Key_F5 =>
                return "0;63";
            when Key_F6 =>
                return "0;64";
            when Key_F7 =>
                return "0;65";
            when Key_F8 =>
                return "0;66";
            when Key_F9 =>
                return "0;67";
            when Key_F10 =>
                return "0;68";
            when Key_F11 =>
                return "0;133";
            when Key_F12 =>
                return "0;134";
            when Keypad_Home =>
                return "0;71";
            when Keypad_Up_Arrow =>
                return "0;72";
            when Keypad_Page_Up =>
                return "0;73";
            when Keypad_Left_Arrow =>
                return "0;75";
            when Keypad_Right_Arrow =>
                return "0;77";
            when Keypad_End =>
                return "0;79";
            when Keypad_Down_Arrow =>
                return "0;80";
            when Keypad_Page_Down =>
                return "0;81";
            when Keypad_Insert =>
                return "0;82";
            when Keypad_Delete =>
                return "0;83";
            when Key_Home =>
                return "(224;71)";
            when Key_Up_Arrow =>
                return "(224;72)";
            when Key_Page_Up =>
                return "(224;73)";
            when Key_Left_Arrow =>
                return "(224;75)";
            when Key_Right_Arrow =>
                return "(224;77)";
            when Key_End =>
                return "(224;79)";
            when Key_Down_Arrow =>
                return "(224;80)";
            when Key_Page_Down =>
                return "(224;81)";
            when Key_Insert =>
                return "(224;82)";
            when Key_Delete =>
                return "(224;83)";
            when Key_Print_Screen =>
                raise Illegal_Keystroke;
            when Key_Pause_Break =>
                raise Illegal_Keystroke;
            when Key_Escape =>
                raise Illegal_Keystroke;
            when Key_Backspace =>
                return "8";
            when Key_Enter =>
                return "13";
            when Key_Tab =>
                return "9";
            when Key_Null =>
                return "0;3";
            when Key_A =>
                return "97";
            when Key_B =>
                return "98";
            when Key_C =>
                return "99";
            when Key_D =>
                return "100";
            when Key_E =>
                return "101";
            when Key_F =>
                return "102";
            when Key_G =>
                return "103";
            when Key_H =>
                return "104";
            when Key_I =>
                return "105";
            when Key_J =>
                return "106";
            when Key_K =>
                return "107";
            when Key_L =>
                return "108";
            when Key_M =>
                return "109";
            when Key_N =>
                return "110";
            when Key_O =>
                return "111";
            when Key_P =>
                return "112";
            when Key_Q =>
                return "113";
            when Key_R =>
                return "114";
            when Key_S =>
                return "115";
            when Key_T =>
                return "116";
            when Key_U =>
                return "117";
            when Key_V =>
                return "118";
            when Key_W =>
                return "119";
            when Key_X =>
                return "120";
            when Key_Y =>
                return "121";
            when Key_Z =>
                return "122";
            when Key_1 =>
                return "49";
            when Key_2 =>
                return "50";
            when Key_3 =>
                return "51";
            when Key_4 =>
                return "52";
            when Key_5 =>
                return "53";
            when Key_6 =>
                return "54";
            when Key_7 =>
                return "55";
            when Key_8 =>
                return "56";
            when Key_9 =>
                return "57";
            when Key_0 =>
                return "48";
            when Key_Minus =>
                return "45";
            when Key_Equal =>
                return "61";
            when Key_Left_Square =>
                return "91";
            when Key_Right_Square =>
                return "93";
            when Key_Space =>
                return "92";
            when Key_Semicolon =>
                return "59";
            when Key_Single_Quote =>
                return "39";
            when Key_Comma =>
                return "44";
            when Key_Dot =>
                return "46";
            when Key_Slash =>
                return "47";
            when Key_Left_Single_Quote =>
                return "96";
            when Keypad_Enter =>
                return "13";
            when Keypad_Slash =>
                return "47";
            when Keypad_Star =>
                return "42";
            when Keypad_Minus =>
                return "45";
            when Keypad_Plus =>
                return "43";
            when Keypad_Middle =>
                return "(0;76)";
        end case;
    end Key_String_Code_Whith_No_Modifier_Key;

    function Key_String_Code_Whith_Shift_Key (Key : Key_Type) return String;
    function Key_String_Code_Whith_Shift_Key (Key : Key_Type) return String is
    begin
        case Key is
            when Key_F1 =>
                return "0;84";
            when Key_F2 =>
                return "0;85";
            when Key_F3 =>
                return "0;86";
            when Key_F4 =>
                return "0;87";
            when Key_F5 =>
                return "0;88";
            when Key_F6 =>
                return "0;89";
            when Key_F7 =>
                return "0;90";
            when Key_F8 =>
                return "0;91";
            when Key_F9 =>
                return "0;92";
            when Key_F10 =>
                return "0;93";
            when Key_F11 =>
                return "0;135";
            when Key_F12 =>
                return "0;136";
            when Keypad_Home =>
                return "55";
            when Keypad_Up_Arrow =>
                return "56";
            when Keypad_Page_Up =>
                return "57";
            when Keypad_Left_Arrow =>
                return "52";
            when Keypad_Right_Arrow =>
                return "54";
            when Keypad_End =>
                return "49";
            when Keypad_Down_Arrow =>
                return "50";
            when Keypad_Page_Down =>
                return "51";
            when Keypad_Insert =>
                return "48";
            when Keypad_Delete =>
                return "46";
            when Key_Home =>
                return "(224;71)";
            when Key_Up_Arrow =>
                return "(224;72)";
            when Key_Page_Up =>
                return "(224;73)";
            when Key_Left_Arrow =>
                return "(224;75)";
            when Key_Right_Arrow =>
                return "(224;77)";
            when Key_End =>
                return "(224;79)";
            when Key_Down_Arrow =>
                return "(224;80)";
            when Key_Page_Down =>
                return "(224;81)";
            when Key_Insert =>
                return "(224;82)";
            when Key_Delete =>
                return "(224;83)";
            when Key_Print_Screen =>
                raise Illegal_Keystroke;
            when Key_Pause_Break =>
                raise Illegal_Keystroke;
            when Key_Escape =>
                raise Illegal_Keystroke;
            when Key_Backspace =>
                return "8";
            when Key_Enter =>
                raise Illegal_Keystroke;
            when Key_Tab =>
                return "0;15";
            when Key_Null =>
                raise Illegal_Keystroke;
            when Key_A =>
                return "65";
            when Key_B =>
                return "66";
            when Key_C =>
                return "66";
            when Key_D =>
                return "68";
            when Key_E =>
                return "69";
            when Key_F =>
                return "70";
            when Key_G =>
                return "71";
            when Key_H =>
                return "72";
            when Key_I =>
                return "73";
            when Key_J =>
                return "74";
            when Key_K =>
                return "75";
            when Key_L =>
                return "76";
            when Key_M =>
                return "77";
            when Key_N =>
                return "78";
            when Key_O =>
                return "79";
            when Key_P =>
                return "80";
            when Key_Q =>
                return "81";
            when Key_R =>
                return "82";
            when Key_S =>
                return "83";
            when Key_T =>
                return "84";
            when Key_U =>
                return "85";
            when Key_V =>
                return "86";
            when Key_W =>
                return "87";
            when Key_X =>
                return "88";
            when Key_Y =>
                return "89";
            when Key_Z =>
                return "90";
            when Key_1 =>
                return "33";
            when Key_2 =>
                return "64";
            when Key_3 =>
                return "35";
            when Key_4 =>
                return "36";
            when Key_5 =>
                return "37";
            when Key_6 =>
                return "94";
            when Key_7 =>
                return "38";
            when Key_8 =>
                return "42";
            when Key_9 =>
                return "40";
            when Key_0 =>
                return "41";
            when Key_Minus =>
                return "95";
            when Key_Equal =>
                return "43";
            when Key_Left_Square =>
                return "123";
            when Key_Right_Square =>
                return "125";
            when Key_Space =>
                return "124";
            when Key_Semicolon =>
                return "58";
            when Key_Single_Quote =>
                return "34";
            when Key_Comma =>
                return "60";
            when Key_Dot =>
                return "62";
            when Key_Slash =>
                return "63";
            when Key_Left_Single_Quote =>
                return "126";
            when Keypad_Enter =>
                raise Illegal_Keystroke;
            when Keypad_Slash =>
                return "47";
            when Keypad_Star =>
                return "(0;144)";
            when Keypad_Minus =>
                return "45";
            when Keypad_Plus =>
                return "43";
            when Keypad_Middle =>
                return "53";
        end case;
    end Key_String_Code_Whith_Shift_Key;

    function Key_String_Code_Whith_Ctrl_Key (Key : Key_Type) return String;
    function Key_String_Code_Whith_Ctrl_Key (Key : Key_Type) return String is
    begin
        case Key is
            when Key_F1 =>
                return "0;94";
            when Key_F2 =>
                return "0;95";
            when Key_F3 =>
                return "0;96";
            when Key_F4 =>
                return "0;97";
            when Key_F5 =>
                return "0;98";
            when Key_F6 =>
                return "0;99";
            when Key_F7 =>
                return "0;100";
            when Key_F8 =>
                return "0;101";
            when Key_F9 =>
                return "0;102";
            when Key_F10 =>
                return "0;103";
            when Key_F11 =>
                return "0;137";
            when Key_F12 =>
                return "0;138";
            when Keypad_Home =>
                return "0;119";
            when Keypad_Up_Arrow =>
                return "(0;141)";
            when Keypad_Page_Up =>
                return "0;132";
            when Keypad_Left_Arrow =>
                return "0;115";
            when Keypad_Right_Arrow =>
                return "0;116";
            when Keypad_End =>
                return "0;117";
            when Keypad_Down_Arrow =>
                return "(0;145)";
            when Keypad_Page_Down =>
                return "0;118";
            when Keypad_Insert =>
                return "(0;146)";
            when Keypad_Delete =>
                return "(0;147)";
            when Key_Home =>
                return "(224;119)";
            when Key_Up_Arrow =>
                return "(224;141)";
            when Key_Page_Up =>
                return "(224;132)";
            when Key_Left_Arrow =>
                return "(224;115)";
            when Key_Right_Arrow =>
                return "(224;116)";
            when Key_End =>
                return "(224;117)";
            when Key_Down_Arrow =>
                return "(224;145)";
            when Key_Page_Down =>
                return "(224;118)";
            when Key_Insert =>
                return "(224;146)";
            when Key_Delete =>
                return "(224;147)";
            when Key_Print_Screen =>
                return "0;114";
            when Key_Pause_Break =>
                return "0;0";
            when Key_Escape =>
                raise Illegal_Keystroke;
            when Key_Backspace =>
                return "127";
            when Key_Enter =>
                return "10";
            when Key_Tab =>
                return "(0;148)";
            when Key_Null =>
                raise Illegal_Keystroke;
            when Key_A =>
                return "1";
            when Key_B =>
                return "2";
            when Key_C =>
                return "3";
            when Key_D =>
                return "4";
            when Key_E =>
                return "5";
            when Key_F =>
                return "6";
            when Key_G =>
                return "7";
            when Key_H =>
                return "8";
            when Key_I =>
                return "9";
            when Key_J =>
                return "10";
            when Key_K =>
                return "11";
            when Key_L =>
                return "12";
            when Key_M =>
                return "13";
            when Key_N =>
                return "14";
            when Key_O =>
                return "15";
            when Key_P =>
                return "16";
            when Key_Q =>
                return "17";
            when Key_R =>
                return "18";
            when Key_S =>
                return "19";
            when Key_T =>
                return "20";
            when Key_U =>
                return "21";
            when Key_V =>
                return "22";
            when Key_W =>
                return "23";
            when Key_X =>
                return "24";
            when Key_Y =>
                return "25";
            when Key_Z =>
                return "26";
            when Key_1 =>
                raise Illegal_Keystroke;
            when Key_2 =>
                return "0";
            when Key_3 =>
                raise Illegal_Keystroke;
            when Key_4 =>
                raise Illegal_Keystroke;
            when Key_5 =>
                raise Illegal_Keystroke;
            when Key_6 =>
                return "30";
            when Key_7 =>
                raise Illegal_Keystroke;
            when Key_8 =>
                raise Illegal_Keystroke;
            when Key_9 =>
                raise Illegal_Keystroke;
            when Key_0 =>
                raise Illegal_Keystroke;
            when Key_Minus =>
                return "31";
            when Key_Equal =>
                raise Illegal_Keystroke;
            when Key_Left_Square =>
                return "27";
            when Key_Right_Square =>
                return "29";
            when Key_Space =>
                return "28";
            when Key_Semicolon =>
                raise Illegal_Keystroke;
            when Key_Single_Quote =>
                raise Illegal_Keystroke;
            when Key_Comma =>
                raise Illegal_Keystroke;
            when Key_Dot =>
                raise Illegal_Keystroke;
            when Key_Slash =>
                raise Illegal_Keystroke;
            when Key_Left_Single_Quote =>
                raise Illegal_Keystroke;
            when Keypad_Enter =>
                return "10";
            when Keypad_Slash =>
                return "(0;142)";
            when Keypad_Star =>
                return "(0;78)";
            when Keypad_Minus =>
                return "(0;149)";
            when Keypad_Plus =>
                return "(0;150)";
            when Keypad_Middle =>
                return "(0;143)";
        end case;
    end Key_String_Code_Whith_Ctrl_Key;

    function Key_String_Code_Whith_Alt_Key (Key : Key_Type) return String;
    function Key_String_Code_Whith_Alt_Key (Key : Key_Type) return String is
    begin
        case Key is
            when Key_F1 =>
                return "0;104";
            when Key_F2 =>
                return "0;105";
            when Key_F3 =>
                return "0;106";
            when Key_F4 =>
                return "0;107";
            when Key_F5 =>
                return "0;108";
            when Key_F6 =>
                return "0;109";
            when Key_F7 =>
                return "0;110";
            when Key_F8 =>
                return "0;111";
            when Key_F9 =>
                return "0;112";
            when Key_F10 =>
                return "0;113";
            when Key_F11 =>
                return "0;139";
            when Key_F12 =>
                return "0;140";
            when Keypad_Home =>
                raise Illegal_Keystroke;
            when Keypad_Up_Arrow =>
                raise Illegal_Keystroke;
            when Keypad_Page_Up =>
                raise Illegal_Keystroke;
            when Keypad_Left_Arrow =>
                raise Illegal_Keystroke;
            when Keypad_Right_Arrow =>
                raise Illegal_Keystroke;
            when Keypad_End =>
                raise Illegal_Keystroke;
            when Keypad_Down_Arrow =>
                raise Illegal_Keystroke;
            when Keypad_Page_Down =>
                raise Illegal_Keystroke;
            when Keypad_Insert =>
                raise Illegal_Keystroke;
            when Keypad_Delete =>
                raise Illegal_Keystroke;
            when Key_Home =>
                return "(224;151)";
            when Key_Up_Arrow =>
                return "(224;152)";
            when Key_Page_Up =>
                return "(224;153)";
            when Key_Left_Arrow =>
                return "(224;155)";
            when Key_Right_Arrow =>
                return "(224;157)";
            when Key_End =>
                return "(224;159)";
            when Key_Down_Arrow =>
                return "(224;154)";
            when Key_Page_Down =>
                return "(224;161)";
            when Key_Insert =>
                return "(224;162)";
            when Key_Delete =>
                return "(224;163)";
            when Key_Print_Screen =>
                raise Illegal_Keystroke;
            when Key_Pause_Break =>
                raise Illegal_Keystroke;
            when Key_Escape =>
                raise Illegal_Keystroke;
            when Key_Backspace =>
                return "(0)";
            when Key_Enter =>
                return "(0";
            when Key_Tab =>
                return "(0;165)";
            when Key_Null =>
                raise Illegal_Keystroke;
            when Key_A =>
                return "0;30";
            when Key_B =>
                return "0;48";
            when Key_C =>
                return "0;46";
            when Key_D =>
                return "0;32";
            when Key_E =>
                return "0;18";
            when Key_F =>
                return "0;33";
            when Key_G =>
                return "0;34";
            when Key_H =>
                return "0;35";
            when Key_I =>
                return "0;23";
            when Key_J =>
                return "0;36";
            when Key_K =>
                return "0;37";
            when Key_L =>
                return "0;38";
            when Key_M =>
                return "0;50";
            when Key_N =>
                return "0;49";
            when Key_O =>
                return "0;24";
            when Key_P =>
                return "0;25";
            when Key_Q =>
                return "0;16";
            when Key_R =>
                return "0;19";
            when Key_S =>
                return "0;31";
            when Key_T =>
                return "0;20";
            when Key_U =>
                return "0;22";
            when Key_V =>
                return "0;47";
            when Key_W =>
                return "0;17";
            when Key_X =>
                return "0;45";
            when Key_Y =>
                return "0;21";
            when Key_Z =>
                return "0;44";
            when Key_1 =>
                return "0;120";
            when Key_2 =>
                return "0;121";
            when Key_3 =>
                return "0;122";
            when Key_4 =>
                return "0;123";
            when Key_5 =>
                return "0;124";
            when Key_6 =>
                return "0;125";
            when Key_7 =>
                return "0;126";
            when Key_8 =>
                return "0;126";
            when Key_9 =>
                return "0;127";
            when Key_0 =>
                return "0;129";
            when Key_Minus =>
                return "0;130";
            when Key_Equal =>
                return "0;131";
            when Key_Left_Square =>
                return "0;26";
            when Key_Right_Square =>
                return "0;27";
            when Key_Space =>
                return "0;43";
            when Key_Semicolon =>
                return "0;39";
            when Key_Single_Quote =>
                return "0;40";
            when Key_Comma =>
                return "0;51";
            when Key_Dot =>
                return "0;52";
            when Key_Slash =>
                return "0;53";
            when Key_Left_Single_Quote =>
                return "(0;41)";
            when Keypad_Enter =>
                return "(0;166)";
            when Keypad_Slash =>
                return "(0;74)";
            when Keypad_Star =>
                raise Illegal_Keystroke;
            when Keypad_Minus =>
                return "(0;164)";
            when Keypad_Plus =>
                return "(0;55)";
            when Keypad_Middle =>
                raise Illegal_Keystroke;
        end case;
    end Key_String_Code_Whith_Alt_Key;

    function Keystroke_String_Code
       (Key : Key_Type; Modifier_Key : Modifier_Key_Type) return String;
    function Keystroke_String_Code
       (Key : Key_Type; Modifier_Key : Modifier_Key_Type) return String
    is
    begin
        case Modifier_Key is
            when No_Modifier_Key =>
                return Key_String_Code_Whith_No_Modifier_Key (Key);
            when Shift_Key =>
                return Key_String_Code_Whith_Shift_Key (Key);
            when Ctrl_Key =>
                return Key_String_Code_Whith_Ctrl_Key (Key);
            when Alt_Key =>
                return Key_String_Code_Whith_Alt_Key (Key);
        end case;
    end Keystroke_String_Code;

    --  Procedure for assigning key-stroke to string
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function Legal_Keystroke
       (Key : Key_Type; Modifier_Key : Modifier_Key_Type) return Boolean
    is
    begin
        case Modifier_Key is
            when No_Modifier_Key =>
                case Key is
                    when Key_Print_Screen =>
                        return False;
                    when Key_Pause_Break =>
                        return False;
                    when others =>
                        return True;
                end case;
            when Shift_Key =>
                case Key is
                    when Key_Print_Screen =>
                        return False;
                    when Key_Pause_Break =>
                        return False;
                    when Key_Enter =>
                        return False;
                    when Key_Null =>
                        return False;
                    when Keypad_Enter =>
                        return False;
                    when others =>
                        return True;
                end case;
            when Ctrl_Key =>
                case Key is
                    when Key_Null =>
                        return False;
                    when Key_1 =>
                        return False;
                    when Key_2 =>
                        return False;
                    when Key_3 =>
                        return False;
                    when Key_4 =>
                        return False;
                    when Key_5 =>
                        return False;
                    when Key_6 =>
                        return False;
                    when Key_7 =>
                        return False;
                    when Key_8 =>
                        return False;
                    when Key_9 =>
                        return False;
                    when Key_0 =>
                        return False;
                    when Key_Equal =>
                        return False;
                    when Key_Semicolon =>
                        return False;
                    when Key_Single_Quote =>
                        return False;
                    when Key_Slash =>
                        return False;
                    when Key_Left_Single_Quote =>
                        return False;
                    when others =>
                        return True;
                end case;
            when Alt_Key =>
                case Key is
                    when Keypad_Home =>
                        return False;
                    when Keypad_Up_Arrow =>
                        return False;
                    when Keypad_Page_Up =>
                        return False;
                    when Keypad_Left_Arrow =>
                        return False;
                    when Keypad_Right_Arrow =>
                        return False;
                    when Keypad_End =>
                        return False;
                    when Keypad_Down_Arrow =>
                        return False;
                    when Keypad_Page_Down =>
                        return False;
                    when Keypad_Insert =>
                        return False;
                    when Keypad_Delete =>
                        return False;
                    when Key_Print_Screen =>
                        return False;
                    when Key_Pause_Break =>
                        return False;
                    when Key_Null =>
                        return False;
                    when Keypad_Star =>
                        return False;
                    when Keypad_Middle =>
                        return False;
                    when others =>
                        return True;
                end case;
        end case;
    end Legal_Keystroke;

    procedure Assign_Keystroke
       ( -- Implements ESC[code;string;...p
        Key          : Key_Type; Modifier_Key : Modifier_Key_Type;
        Substitution : String)
    is
        B : Buffer_Type;
    begin
        --  Maximum string length : 1 + 1 + maximum-code-length + 1 =
        --  1 + 1 + 9 + 1 = 12
        Start (B);
        Append (B, Keystroke_String_Code (Key, Modifier_Key));
        Append (B, ';');
        Put (B);
        Put_Command_String (Substitution);
        Put_Command_String ("p");
    end Assign_Keystroke;

    procedure Assign_Keystroke
       (Stream : Stream_Type; Key : Key_Type; Modifier_Key : Modifier_Key_Type;
        Substitution : String)
    is
        B : Buffer_Type;
    begin
        Start (B);
        Append (B, Keystroke_String_Code (Key, Modifier_Key));
        Append (B, ';');
        Put (Stream, B);
        Put_Command_String (Stream, Substitution);
        Put_Command_String (Stream, "p");
    end Assign_Keystroke;

end ANSI_Console;
