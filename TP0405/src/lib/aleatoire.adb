with Calendar;

package body Aleatoire is
    Max : Integer := 10;
    Min : Integer := 1;

    X : Integer := 10_001;
    Y : Integer := 20_001;
    Z : Integer := 30_001;

    ---------------------------------------------------------------------------
    --                               Initialise                              --
    ---------------------------------------------------------------------------
    procedure Initialise (Minimum : Integer := 1; Maximum : Integer := 10) is
    begin
        Max := Maximum;
        if Minimum <= Max then
            Min := Minimum;
        else
            Min := Maximum;
        end if;
    end Initialise;

    function Ran return Float;
    function Ran return Float is
        W : Float;
        function Convert_To_Float (i : Integer) return Float;
        function Convert_To_Float (i : Integer) return Float is
        begin
            return Float (i);
        end Convert_To_Float;
    begin
        X := 171 * (X mod 177 - 177) - 2 * (X / 177);
        if X < 0 then
            X := X + 30_269;
        end if;
        Y := 172 * (Y mod 176 - 176) - 35 * (Y / 176);
        if Y < 0 then
            Y := Y + 30_307;
        end if;
        Z := 170 * (Z mod 178 - 178) - 63 * (Z / 178);
        if Z < 0 then
            Z := Z + 30_323;
        end if;

        W :=
           Convert_To_Float (i => X) / 30_269.0 +
           Convert_To_Float (i => Y) / 30_307.0 +
           Convert_To_Float (i => Z) / 30_323.0;
        return W - Convert_To_Float (Integer (W - 0.5));
    end Ran;

    ---------------------------------------------------------------------------
    --                                 Random                                --
    ---------------------------------------------------------------------------
    function Random return T_Valeur_Reelle_Aleatoire is
    begin
        return Ran;
    end Random;

    ---------------------------------------------------------------------------
    --                                 Random                                --
    ---------------------------------------------------------------------------
    function Random return Integer is
        Valeur : constant T_Valeur_Reelle_Aleatoire := Random;
    begin
        return Min + Integer (Valeur * Float (Max - Min + 1) - 0.499_999_99);
    end Random;
--  Corps
begin
    for i in 1 .. 20 loop
        declare
            x  : T_Valeur_Reelle_Aleatoire;
            t  : constant Calendar.Time := Calendar.Clock;
            st : constant Duration      := Calendar.Seconds (t);
            s  : constant Natural := Natural (st - 0.499_9); --  partie entiere
            d  : constant Duration      := st - Duration (s);
            m  : constant Natural       := Natural (Duration (1_000) * d);
        begin
            x := 0.0;
            for i in 0 .. m loop
                x := x + Random - x;
            end loop;
        end;
    end loop;
end Aleatoire;
