with Ada.Text_IO;

package ANSI_Console
--  ---------------------------------------------------------------------------
--  High Level Text Mode Screen and Console Output.
--  Also Provide Keystroke Assignement.
--  ---------------------------------------------------------------------------
--  This package provide access to high level output to text mode screen
--  and console. It allows you to set cursor position, text color, erase
--  screen, and other useful procedures of the like. Enable to assign keystroke
--  to string : i.e. when the specified keystroke occur, the corresponding
--  string is recieved on the standard input (to be used with care).
--
--  It interfaces all ANSI escapement commands. Symbolic types defined in
--  the ANSI standard are used to document types definitions founded here.
--  Procedure names differ from command names found in the ANSI standard.
--  Generic commande string representations are used to document procedures.
--
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
--  ---------------------------------------------------------------------------

is

--  =========================================================================
--  Important notes :
--  -------------------------------------------------------------------------
--  o  Output of text (not of command) that just fit up to
--     en of line, may move the cursor to the line below. This
--     occur on many systems.
--  o  Continuating the previous note, if in the same circumstances, the
--     cursor in on the bottom line, the a screen scroll may occur on
--     many systems. Applications should care about it, or use a special
--     way to avoid this behavior.
--  o  As this package is reentrant, it is thread safe.
--  o  There is a Â« Beep Â» procedure under section of output procedures.
--  o  There is a (non-blocking) Â« Get_Key Â» procedure under the section
--     of input procedures.
--  =========================================================================
--  Organisation of this specification
--  -------------------------------------------------------------------------
--  O Screen metrics
--  o   Types for screen metrics (screen maximum sizes)
--  o   Types for screen positions
--  O Keystrokes
--  o   Type for normal keys
--  o   Type for modifier keys
--  O Text output/input and erasing of screen
--  o   Type for working on streams other than the standard output.
--  o   Simply text output procedures (provided for consistency).
--  o   Simply character output procedures (provided for consistency).
--  o   Procedure for playing a beep
--  o   Simply character input procedures (provided for consistency).
--  o   Type for keystroke input
--  o   Procedures for keystroke input
--  o   Procedures for clearing screen or part of line.
--  O Text color and attributes
--  o   Type for setting foreground and background text colors
--  o   Procedures for setting text color.
--  o   Type for setting text attributes
--  o   Procedure for setting text attributs (blinking and the like...).
--  O Cursor position and movement
--  o   Procedure fixing cursor position
--  o   Types for making cursor mouvements (deltas).
--  o   Procedures moving cursor position
--  o   Procedures for saving/restoring cursor position
--  O Screen modes (resolution) and output behaviour
--  o   Type for setting screen modes (screen resolution)
--  o   Procedures for fixing screen mode (screen resolution)
--  o   Procedures for fixing screen behaviour (line wrapping)
--  O Key assignements
--  o   Exception for invalid modifier+key
--  o   Procedure for assigning key-stroke to string
--  =========================================================================
--  Screen metrics
--  -------------------------------------------------------------------------

--  Note : screen coordinates are top to down and left to right.
--  Note : the upper left corner is (1,1).
--  Types for screen metrics (screen maximum sizes)
--  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Maximum_Screen_Height : constant Positive := 1_024;
    Maximum_Screen_Width  : constant Positive := 1_024;

    --  Types for screen positions
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    subtype Vertical_Position_Type is
       Positive -- Implements PL
    range 1 .. Maximum_Screen_Height;

    subtype Horizontal_Position_Type is
       Positive -- Implements Pc
    range 1 .. Maximum_Screen_Width;

    --  =====================================================================
    --  Keystrokes
    --  ---------------------------------------------------------------------

    --  Type for normal keys
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    type Key_Type is
       ( -- Type for functional keys (those you usualy use)
        Key_F1, Key_F2, Key_F3, Key_F4, Key_F5, Key_F6, Key_F7, Key_F8, Key_F9,
        Key_F10, Key_F11, Key_F12, Keypad_Home, Keypad_Up_Arrow,
        Keypad_Page_Up, Keypad_Left_Arrow, Keypad_Right_Arrow, Keypad_End,
        Keypad_Down_Arrow, Keypad_Page_Down, Keypad_Insert, Keypad_Delete,
        Key_Home, Key_Up_Arrow, Key_Page_Up, Key_Left_Arrow, Key_Right_Arrow,
        Key_End, Key_Down_Arrow, Key_Page_Down, Key_Insert, Key_Delete,
        Key_Print_Screen, Key_Pause_Break, Key_Escape, Key_Backspace,
        Key_Enter, Key_Tab, Key_Null, Key_A, Key_B, Key_C, Key_D, Key_E, Key_F,
        Key_G, Key_H, Key_I, Key_J, Key_K, Key_L, Key_M, Key_N, Key_O, Key_P,
        Key_Q, Key_R, Key_S, Key_T, Key_U, Key_V, Key_W, Key_X, Key_Y, Key_Z,
        Key_0, Key_1, Key_2, Key_3, Key_4, Key_5, Key_6, Key_7, Key_8, Key_9,
        Key_Minus, Key_Equal, Key_Left_Square, Key_Right_Square, Key_Space,
        Key_Semicolon, Key_Single_Quote, Key_Comma, Key_Dot, Key_Slash,
        Key_Left_Single_Quote, Keypad_Enter, Keypad_Slash, Keypad_Star,
        Keypad_Minus, Keypad_Plus,
        Keypad_Middle); -- 5, in the middle of the numeric keypad

    --  Type for modifier keys
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    type Modifier_Key_Type is
       ( -- Type for auxiliary keys (the one you
        No_Modifier_Key,         -- held down while pressing another)
        Shift_Key, Ctrl_Key, Alt_Key);

    --  =======================================================================
    --  Text output/input and erasing of screen
    --  -----------------------------------------------------------------------

    --  Type for working on streams other than the standard output.
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    subtype Stream_Type is Ada.Text_IO.File_Type;

    --  Simply text output procedures (provided for consistency).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Put (Text : String);

    procedure Put (Stream : Stream_Type; Text : String);

    procedure Put
       (Line : Vertical_Position_Type; Column : Horizontal_Position_Type;
        Text : String);

    procedure Put
       (Stream : Stream_Type; Line : Vertical_Position_Type;
        Column : Horizontal_Position_Type; Text : String);

    --  Simply character output procedures (provided for consistency).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Put (C : Character);

    procedure Put (Stream : Stream_Type; C : Character);

    procedure Put
       (Line : Vertical_Position_Type; Column : Horizontal_Position_Type;
        C    : Character);

    procedure Put
       (Stream : Stream_Type; Line : Vertical_Position_Type;
        Column : Horizontal_Position_Type; C : Character);

    --  Procedure for playing a beep
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Beep; -- Added for convenience - See note below

    procedure Beep (Stream : Stream_Type);

    --  Note : with console under some modern desktop environements, like
    --  Windows, the beep function may play the system altert sound instead of
    --  a beep with the computer speaker.

    --  Simply character input procedures (provided for consistency).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  See notes below about Get procedures

    procedure Get (C : out Character);

    procedure Get
       ( --  Non-blocking character input.
        C : out Character; Available : out Boolean);

    procedure Get (Stream : Stream_Type; C : out Character);

    procedure Get
       ( --  Non-blocking character input.
        Stream : Stream_Type; C : out Character; Available : out Boolean);

    --  Type for keystroke input
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    type Keystroke_Input_Type is record
        Key                 : Key_Type;
        Modifier_Key        : Modifier_Key_Type;
        C                   : Character;
        Key_Available       : Boolean;
        Character_Available : Boolean;
    end record;

    --  Procedures for keystroke input
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Get_Key
       ( -- Non-blocking key input - See note below
        Keystroke_Input : out Keystroke_Input_Type);

    procedure Get_Key
       (Stream : Stream_Type; Keystroke_Input : out Keystroke_Input_Type);

    --  Notes
    --  -----------------------------------------------------------------------
    --  Some keystroke only have a specific code. See the list below, of
    --  recognize keystrokes. Unfortunatly, Ctrl+PageUp has the same code
    --  as F12. So when you hit Ctrl+PageUp, it appears as F12. There is
    --  no work around. In general, Key F11 and F12 are not well supported
    --  by ANSI (multiplicity of codes or ambiguity with some other codes).
    --
    --  Get can return special character code, meaning complex keystroke,
    --  so it is suggested to use Get_Key instead of Get. Get_Key translate
    --  and convert special code automaticaly, so you don't have to worry
    --  about them. Get_Key allow you too to get character input, and prevent
    --  you from errorneously getting special code in place of character input.
    --
    --  Get_Key is provided for convenience, and may be incomaptible with Get
    --  (not all the time but in some circumstance). Some complex key, like F1,
    --  Page-up and so on, a recieved through complex code, made of two
    --  conscecutives specials character codes. So you easly guess that Get_Key
    --  is based on Get, and that a missusage of Get may disturbe Get_Key.
    --  Althought the Â« normal Â» way wit ANSI consoles is to call Get, it
    --  is strongly adviced that you only use Get_Key in your application.
    --
    --  Here is the list of recognize keystrokes ...
    --
    --  Standalones keys (A-Z and 0-1 are not reported in this list, but
    --  are recognized too).
    --
    --  Key_F1
    --  Key_F2
    --  Key_F3
    --  Key_F4
    --  Key_F5
    --  Key_F6
    --  Key_F7
    --  Key_F8
    --  Key_F9
    --  Key_F10
    --  Key_F11
    --  Key_F12
    --  Key_Home
    --  Key_Up_Arrow
    --  Key_Page_Up
    --  Key_Left_Arrow
    --  Key_Right_Arrow
    --  Key_End
    --  Key_Down_Arrow
    --  Key_Page_Down
    --  Key_Insert
    --  Key_Delete
    --  Key_Backspace
    --  Key_Tab
    --  Key_Enter
    --  Key_Escape
    --  Key_Space
    --
    --  Keypad keys (there may be not distinguisable on some system)
    --
    --  Keypad_Home
    --  Keypad_Up_Arrow
    --  Keypad_Page_Up
    --  Keypad_Left_Arrow
    --  Keypad_Right_Arrow
    --  Keypad_End
    --  Keypad_Down_Arrow
    --  Keypad_Page_Down
    --  Keypad_Insert
    --  Keypad_Delete
    --
    --  With ALT modifier
    --
    --  Alt_Key + Key_F1
    --  Alt_Key + Key_F2
    --  Alt_Key + Key_F3
    --  Alt_Key + Key_F4
    --  Alt_Key + Key_F5
    --  Alt_Key + Key_F6
    --  Alt_Key + Key_F7
    --  Alt_Key + Key_F8
    --  Alt_Key + Key_F9
    --  Alt_Key + Key_F10
    --  Alt_Key + Key_F11
    --  Alt_Key + Key_F12
    --  Alt_Key + Key_Home
    --  Alt_Key + Key_Up_Arrow
    --  Alt_Key + Key_Page_Up
    --  Alt_Key + Key_Left_Arrow
    --  Alt_Key + Key_Right_Arrow
    --  Alt_Key + Key_End
    --  Alt_Key + Key_Down_Arrow
    --  Alt_Key + Key_Page_Down
    --  Alt_Key + Key_Insert
    --  Alt_Key + Key_Delete
    --
    --  With CTRL modifier
    --
    --  Ctrl_Key + Key_F1
    --  Ctrl_Key + Key_F2
    --  Ctrl_Key + Key_F3
    --  Ctrl_Key + Key_F4
    --  Ctrl_Key + Key_F5
    --  Ctrl_Key + Key_F6
    --  Ctrl_Key + Key_F7
    --  Ctrl_Key + Key_F8
    --  Ctrl_Key + Key_F9
    --  Ctrl_Key + Key_F10
    --  Ctrl_Key + Key_F11
    --  Ctrl_Key + Key_F12
    --  Ctrl_Key + Key_Home
    --  Ctrl_Key + Key_Up_Arrow
    --  Ctrl_Key + Key_Left_Arrow
    --  Ctrl_Key + Key_Right_Arrow
    --  Ctrl_Key + Key_End
    --  Ctrl_Key + Key_Down_Arrow
    --  Ctrl_Key + Key_Page_Down
    --  Ctrl_Key + Key_Insert
    --  Ctrl_Key + Key_Delete
    --  Ctrl_Key + Keypad_Home
    --  Ctrl_Key + Keypad_Up_Arrow
    --  Ctrl_Key + Keypad_Page_Up
    --  Ctrl_Key + Keypad_Left_Arrow
    --  Ctrl_Key + Keypad_Right_Arrow
    --  Ctrl_Key + Keypad_End
    --  Ctrl_Key + Keypad_Down_Arrow
    --  Ctrl_Key + Keypad_Page_Down
    --  Ctrl_Key + Keypad_Insert
    --  Ctrl_Key + Keypad_Delete
    --  Ctrl_Key + Key_Tab
    --
    --  With SHIFT modifier
    --
    --  Shift_Key + Key_F1
    --  Shift_Key + Key_F2
    --  Shift_Key + Key_F3
    --  Shift_Key + Key_F4
    --  Shift_Key + Key_F5
    --  Shift_Key + Key_F6
    --  Shift_Key + Key_F7
    --  Shift_Key + Key_F8
    --  Shift_Key + Key_F9
    --  Shift_Key + Key_F10
    --  Shift_Key + Key_F11
    --  Shift_Key + Key_F12

    --  Procedures for clearing screen or part of line.
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  Note : erasing use the currently active background color.

    procedure Clear_Screen; -- Implements ESC[2J

    procedure Clear_Screen (Stream : Stream_Type); -- idem

    procedure Clear_From_Cursor_Up_To_End_Of_Line; -- Implements ESC[K

    procedure Clear_From_Cursor_Up_To_End_Of_Line (Stream : Stream_Type);

    --  ====================================================================
    --  Text color and attributes
    --  --------------------------------------------------------------------

    --  Type for setting foreground and background text colors
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    type Color_Type is
       ( -- Implements part of Ps
        Black, Red, Green, Yellow, Blue, Magenta, Cyan, White);

    --  Procedures for setting text color.
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Set_Text_Color
       ( -- Implements part of ESC[Ps;...;Psm
        Color : Color_Type);

    procedure Set_Text_Color
       ( -- idem
        Stream : Stream_Type; Color : Color_Type);

    procedure Set_Background_Color
       ( -- Implements part of ESC[Ps;...;Psm
        Color : Color_Type);

    procedure Set_Background_Color
       ( -- idem
        Stream : Stream_Type; Color : Color_Type);

    --  Type for setting text attributes
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    type Text_Attributes_Type is
       ( -- Implements part of Ps
        Default_Text_Attributes, -- Restore device defaults - See notes below
        Bold_Text, -- Displayed as highligthed on most device (reverse of Thin)
        Thin_Text,      -- Displayed as faint on most device (reverse of Bold)
        Standout_Text,       -- Don't know what it stand for (without joking)
        Underlined_Text,     -- Only works on monochrome displays
        Blinking_Text,       -- See notes below
        Reversed_Colors,     -- See notes below
        Hidden_Text,         -- See notes below
        Normal_Text,         -- Deactivate all attributes
        Not_Standout_Text,   -- To remove the standout attribute
        Not_Underlined_Text, -- To remove the Underlined attribute
        Not_Blinking_Text,   -- To remove the Blinking attribute
        Not_Reversed_Text);  -- To remove the Reversed attribute

    --  Notes
    --  -----------------------------------------------------------------------
    --  Note : Default_Text_Attributes is not a way of disabling currently
    --  selected text attributes (use Normal_Text to do that). Instead, it
    --  modified some text attributes on a not normalised way, while possibly
    --  preserving some others attributes.
    --
    --  Note : Blinking_Text displays the text blinking (on real console) of
    --  course, but also apply thin/faint style. So if you have, say faint
    --  blue background color, with blue hightligh text, then the text color
    --  become faint blue, and is not visible. When using blinking attribute,
    --  text color and background color must have truly different colors in
    --  order to be visible.
    --
    --  Note : Reversed_Colors is to be used with care. On a 16 colors display,
    --  it may produce invisible text, due to background color becoming the
    --  same as the text color. Color combination are to be tested before, of
    --  course.
    --
    --  Note : Hidden_Text is not really invisible, but it is a work on the
    --  background color (which generally become black).
    --  ----------------------------------------------------------------------

    --  Procedure for setting text attributs (blinking and the like...).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Set_Text_Attributes
       ( -- Implements part of ESC[Ps;...;Psm
        Text_Attributes : Text_Attributes_Type);

    procedure Set_Text_Attributes
       ( -- idem
        Stream : Stream_Type; Text_Attributes : Text_Attributes_Type);

    --  ======================================================================
    --  Cursor position and movement
    --  ----------------------------------------------------------------------

    --  Procedure fixing cursor position
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Move_Cursor_To
       ( -- Implements ESC[PL;PcH  (same as ESC[PL;Pcf)
        Line : Vertical_Position_Type; Column : Horizontal_Position_Type);

    procedure Move_Cursor_To
       ( -- idem
        Stream : Stream_Type; Line : Vertical_Position_Type;
        Column : Horizontal_Position_Type);

    --  Types for making cursor mouvements (deltas).
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    subtype Horizontal_Delta_Type is
       Natural -- Implements Pn
    range 0 .. Maximum_Screen_Height - 1;

    subtype Vertical_Delta_Type is
       Natural -- Implements Pn
    range 0 .. Maximum_Screen_Width - 1;

    --  Procedures moving cursor position
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Move_Cursor_Up
       ( -- Implements ESC[PnA
        Count : Vertical_Delta_Type);

    procedure Move_Cursor_Up
       ( -- idem
        Stream : Stream_Type; Count : Vertical_Delta_Type);

    procedure Move_Cursor_Down
       ( -- Implements ESC[PnB
        Count : Vertical_Delta_Type);

    procedure Move_Cursor_Down
       ( -- idem
        Stream : Stream_Type; Count : Vertical_Delta_Type);

    procedure Move_Cursor_Right
       ( -- Implements ESC[PnC
        Count : Horizontal_Delta_Type);

    procedure Move_Cursor_Right
       ( -- idem
        Stream : Stream_Type; Count : Horizontal_Delta_Type);

    procedure Move_Cursor_Left
       ( -- Implements ESC[PnD
        Count : Horizontal_Delta_Type);

    procedure Move_Cursor_Left
       ( -- idem
        Stream : Stream_Type; Count : Horizontal_Delta_Type);

    --  Procedures for saving/restoring cursor position
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Save_Cursor_Position; -- Implements ESC[s

    procedure Save_Cursor_Position (Stream : Stream_Type); -- idem

    procedure Restore_Cursor_Position; -- Implements ESC[u

    procedure Restore_Cursor_Position (Stream : Stream_Type); -- idem

    --  ======================================================================
    --  Screen modes (resolution) and output behaviour
    --  ----------------------------------------------------------------------

    --  Type for setting screen modes (screen resolution)
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  Note that graphic screen stand for text mode based on graphic screen.

    type Screen_Mode_Type is
       ( -- Implements part of Ps
        Monochrome_Text_Mode_40x25,      -- monochrome, text
        Color_Text_Mode_40x25,           -- color     , text
        Monochrome_Text_Mode_80x25,      -- monochrome, text
        Color_Text_Mode_80x25,           -- color     , text
        Color4_Graphic_Mode_320x200,     -- 4 colors  , graphic
        Monochrome_Graphic_Mode_320x200, -- monochrome, graphic
        Monochrome_Graphic_Mode_640x200, -- monochrome, graphic
        Color_Graphic_Mode_320x200,      -- xxx colors, graphic
        Color16_Graphic_Mode_640x200,    -- 16 colors , graphic
        Monochrome_Graphic_Mode_640x350, -- monochrome, graphics
        Color16_Graphic_Mode_640x350,    -- 16 colors , graphic
        Monochrome_Graphic_Mode_640x480, -- monochrome, graphic
        Color16_Graphic_Mode_640x480,    -- 16 colors , graphic
        Color256_Graphic_Mode_320x200);  -- 256 colors, graphic

    --  Procedures for fixing screen mode (screen resolution)
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Set_Screen_Mode
       ( -- Implements part of ESC[=Psh
        Screen_Mode : Screen_Mode_Type);

    procedure Set_Screen_Mode
       ( -- idem
        Stream : Stream_Type; Screen_Mode : Screen_Mode_Type);

    procedure Reset_Screen_Mode
       ( -- Implements ESC[=Psl
        Screen_Mode : Screen_Mode_Type);

    procedure Reset_Screen_Mode
       ( -- idem
        Stream : Stream_Type; Screen_Mode : Screen_Mode_Type);

    --  Procedures for fixing screen behaviour (line wrapping)
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    procedure Enable_Line_Wrapping; -- Implements part of ESC[=Psh

    procedure Enable_Line_Wrapping (Stream : Stream_Type); -- idem

    procedure Disable_Line_Wrapping; -- Implements part of ESC[=Psh

    procedure Disable_Line_Wrapping (Stream : Stream_Type); -- ideÃ¹

    --  =======================================================================
    --  Keystroke assignements
    --  ---------------------------------------------------------------------

    --  Exception for invalid modifier+key
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Illegal_Keystroke : exception; -- May be raised by Assign_Keystroke

    --  Procedure for assigning key-stroke to string
    --  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    --  Warning : there is no undo nor reset applying to this functionality.

    --  Be careful that some keystrokes are illegal.

    --  Be sure that application only use legal keystroke, or
    --  check it with this function (may be useful for interactive keystroke
    --  assignment from user).

    function Legal_Keystroke
       (Key : Key_Type; Modifier_Key : Modifier_Key_Type) return Boolean;

    procedure Assign_Keystroke
       ( -- Implements ESC[code;string;...p
        Key          : Key_Type; Modifier_Key : Modifier_Key_Type;
        Substitution : String);

    procedure Assign_Keystroke
       ( -- idem
        Stream : Stream_Type; Key : Key_Type; Modifier_Key : Modifier_Key_Type;
        Substitution : String);

end ANSI_Console;
