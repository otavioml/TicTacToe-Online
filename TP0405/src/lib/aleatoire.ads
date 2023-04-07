package Aleatoire is
    subtype T_Valeur_Reelle_Aleatoire is Float range 0.0 .. 1.0;
    --  Initialise l'intervalle de tirage pour un entier
    procedure Initialise (Minimum : Integer := 1; Maximum : Integer := 10);
    --  Réalise un tirage d'une valeur réelle entre 0.0 et 1.0
    function Random return T_Valeur_Reelle_Aleatoire;
    --  Réalise un tirage d'une valeur entière entre Min et Max
    function Random return Integer;

end Aleatoire;
