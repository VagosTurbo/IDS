-- Autoopravna DATABASE
-- Authors: xseman06, xsucha18
DROP TABLE MATERIAL;
DROP TABLE CINNOST;
DROP TABLE ZAKAZKA;
DROP TABLE FAKTURA;
DROP TABLE AUTO;
DROP TABLE ZAKAZNIK;
DROP TABLE AUTOMECHANIK;
DROP TABLE OSOBA;

DROP PROCEDURE calculate_invoice_total;

DROP MATERIALIZED VIEW mv_zakazka_full;

DROP VIEW AUTOMECHANIK_FULL;
DROP VIEW ZAKAZNIK_FULL;


CREATE TABLE Osoba (
    Osoba_Id        NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Jmeno           VARCHAR2(50),
    Tel_cislo       VARCHAR2(15) NULL,
    Email           VARCHAR2(100) NULL,
    CONSTRAINT Contact_Check CHECK (Tel_cislo is not null or Email is not null)
);

CREATE TABLE Automechanik (
    Mechanik_Id     NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Specializace    VARCHAR2(100),
    Osoba           NUMBER,
    CONSTRAINT Osoba_FK FOREIGN KEY (Osoba) REFERENCES OSOBA(Osoba_Id)
    ON DELETE CASCADE
);

CREATE TABLE Zakaznik (
    Zakaznik_Id     NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Adresa          VARCHAR2(100) NULL,
    ICO             VARCHAR2(10) NULL,
    Osoba           NUMBER,
    CONSTRAINT ICO_Check CHECK (LENGTH(ICO) = 8 or ICO is null),
    CONSTRAINT Osoba2_FK FOREIGN KEY (Osoba) REFERENCES OSOBA(Osoba_Id)
    ON DELETE CASCADE
);

CREATE TABLE Auto (
    VIN             VARCHAR2(17) PRIMARY KEY,
    SPZ             VARCHAR2(7),
    Znacka          VARCHAR2(20),
    Model           VARCHAR2(30),
    Rok_vyroby      VARCHAR2(4),
    Palivo          VARCHAR2(10),
    Historie_oprav  VARCHAR2(100) NULL
);

CREATE TABLE Faktura (
    Cislo_faktury       NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Celkova_cena        DECIMAL(10, 2),
    Datum_vyastaveni    DATE,
    Datum_splatnosti    DATE,
    Zpusob_platby       VARCHAR2(8),
    Zaplaceno           VARCHAR2(5),
    CONSTRAINT Zaplaceno check (Zaplaceno IN ('TRUE', 'FALSE')),
    CONSTRAINT Zpusob_check check (Zpusob_platby IN ('KARTA', 'HOTOVOST'))
);

CREATE TABLE Zakazka (
    Zakazka_Id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Popis           VARCHAR2(255) NULL,
    Datum_vytvoreni DATE,
    Cas_upraveni    TIMESTAMP,
    Termin          DATE,
    Stav            VARCHAR2(50),
    Auto            VARCHAR2(17),
    Cislo_faktury   NUMBER,
    Zakaznik        NUMBER,
    CONSTRAINT Auto_FK FOREIGN KEY (Auto) REFERENCES AUTO(VIN),
    CONSTRAINT Faktura_FK FOREIGN KEY (Cislo_faktury) REFERENCES FAKTURA(Cislo_faktury),
    CONSTRAINT Zakaznik_FK FOREIGN KEY (Zakaznik) REFERENCES Zakaznik(Zakaznik_Id),
    CONSTRAINT Stav2_check CHECK (Stav IN ('Pripraveno k vyzdvihnuti', 'Ceka na dodani dilu', 'Servisovano'))
);

CREATE TABLE Cinnost (
    Cinnost_Id      NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Nazev           VARCHAR2(100),
    Cena            DECIMAL(10,2),
    Termin          DATE,
    Stav            VARCHAR2(25),
    Cas_prace       INTEGER,
    Mechanik        NUMBER,
    Cislo_zakazky   NUMBER,
    CONSTRAINT Cas_prace_check CHECK (Cas_prace >= 0),
    CONSTRAINT Mechanik_FK FOREIGN KEY (Mechanik) REFERENCES Automechanik(Mechanik_Id),
--     CONSTRAINT Stav_check CHECK (Stav IN ('Pripraveno k vyzdvihnuti', 'Ceka na dodani dilu', 'Servisovano')),
    CONSTRAINT Zakazka_fk FOREIGN KEY (Cislo_zakazky) REFERENCES Zakazka(Zakazka_Id)
);

CREATE TABLE Material (
    Material_Id         NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    Nazev               VARCHAR2(100),
    Cena                DECIMAL(10, 2),
    Mnozstvi_skladem    INTEGER,
    Pouzite             VARCHAR2(5),
    CONSTRAINT Mnozstvi_check CHECK (Mnozstvi_skladem >= 0),
    CONSTRAINT Pouzite_check CHECK (Pouzite IN ('TRUE', 'FALSE'))
);

CREATE OR REPLACE VIEW Automechanik_full AS
SELECT A.Mechanik_Id, A.Specializace, O.Jmeno, O.Tel_cislo, O.Email
FROM AUTOMECHANIK A
JOIN OSOBA O ON A.Osoba = O.Osoba_Id;

CREATE OR REPLACE VIEW Zakaznik_full AS
SELECT Z.Zakaznik_Id, Z.Adresa, Z.ICO, O.Jmeno, O.Tel_cislo, O.Email
FROM ZAKAZNIK Z
JOIN OSOBA O ON Z.Osoba = O.Osoba_Id;

-- Vlozenie ukazkovych dat
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Anna Nováková', '+420111222333', 'anna.novakova@email.cz');
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Michal Marek', '+420999888777', 'michal.marek@email.cz');
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Eva Doležalová', '+420777666555', 'eva.dolezalova@email.cz');
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Jan Novák', '+420111222333', 'jan.novak@email.cz');
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Petra Svobodová', '+420777888999', 'petra.svobodova@email.cz');
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Josef Nový', '+420777666444', 'josef.novy@email.cz');
INSERT INTO Osoba (Jmeno, Tel_cislo, Email) VALUES ('Karolína Nová', '+420777555333', 'karolina.nova@email.cz');

INSERT INTO Automechanik (Specializace, Osoba) VALUES ('Karosář', 1); -- Anna Nováková
INSERT INTO Automechanik (Specializace, Osoba) VALUES ('Lakování', 2); -- Michal Marek
INSERT INTO Automechanik (Specializace, Osoba) VALUES ('Mechanik', 4); -- Jan Novák
INSERT INTO Automechanik (Specializace, Osoba) VALUES ('Elektrikář', 5); -- Petra Svobodová
INSERT INTO Automechanik (Specializace, Osoba) VALUES ('Elektrikář', 6); -- Josef Nový
INSERT INTO Automechanik (Specializace, Osoba) VALUES ('Karosář', 7); -- Karolína Nová

INSERT INTO Zakaznik (Adresa, ICO, Osoba) VALUES ('Ulice 1, Brno', '87654321', 3); -- Eva Doležalová
INSERT INTO Zakaznik (Adresa, ICO, Osoba) VALUES ('Ulice 5, Olomouc', '34567890', 6); -- Josef Nový
INSERT INTO Zakaznik (Adresa, ICO, Osoba) VALUES ('Ulice 6, Liberec', '45678901', 7); -- Karolína Nová
INSERT INTO Zakaznik (Adresa, ICO, Osoba) VALUES ('Ulice 3, Ostrava', '12345678', 4); -- Jan Novák
INSERT INTO Zakaznik (Adresa, ICO, Osoba) VALUES ('Ulice 4, Plzeň', '23456789', 5); -- Petra Svobodová

INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('WAUZZZ4G8EN140987', 'ABC1234', 'Audi', 'A4', '2014', 'Benzín', 'Žádná');
INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('WDB12345678901234', 'DEF5678', 'Mercedes', 'C-Class', '2016', 'Nafta', 'Pravidelná údržba');
INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('YS2R4X20005399401', 'GHI9012', 'Scania', 'R420', '2012', 'Nafta', 'Výměna brzdových destiček');
INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('YS2R4X20005399402', 'JKL3456', 'Scania', 'R470', '2015', 'Nafta', 'Výměna brzdových kotoučů');
INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('YS2R4X20005399403', 'MNO7890', 'Scania', 'P420', '2017', 'Nafta', 'Pravidelná údržba');
INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('WAUZZZ4G8EN140988', 'DEF5678', 'Audi', 'A3', '2016', 'Benzín', 'Žádná');
INSERT INTO Auto (VIN, SPZ, Znacka, Model, Rok_vyroby, Palivo, Historie_oprav) VALUES ('WDB12345678901235', 'GHI9012', 'Mercedes', 'E-Class', '2018', 'Nafta', 'Pravidelná údržba');

INSERT INTO Faktura (Celkova_cena, Datum_vyastaveni, Datum_splatnosti, Zpusob_platby, Zaplaceno) VALUES (50.00, TO_DATE('2024-03-24', 'YYYY-MM-DD'), TO_DATE('2024-04-08', 'YYYY-MM-DD'), 'KARTA', 'FALSE');
INSERT INTO Faktura (Celkova_cena, Datum_vyastaveni, Datum_splatnosti, Zpusob_platby, Zaplaceno) VALUES (100.00, TO_DATE('2024-03-23', 'YYYY-MM-DD'), TO_DATE('2024-04-07', 'YYYY-MM-DD'), 'HOTOVOST', 'FALSE');
INSERT INTO Faktura (Celkova_cena, Datum_vyastaveni, Datum_splatnosti, Zpusob_platby, Zaplaceno) VALUES (150.00, TO_DATE('2024-03-24', 'YYYY-MM-DD'), TO_DATE('2024-04-08', 'YYYY-MM-DD'), 'KARTA', 'FALSE');
INSERT INTO Faktura (Celkova_cena, Datum_vyastaveni, Datum_splatnosti, Zpusob_platby, Zaplaceno) VALUES (200.00, TO_DATE('2024-03-23', 'YYYY-MM-DD'), TO_DATE('2024-04-07', 'YYYY-MM-DD'), 'HOTOVOST', 'FALSE');
INSERT INTO Faktura (Celkova_cena, Datum_vyastaveni, Datum_splatnosti, Zpusob_platby, Zaplaceno) VALUES (80.00, TO_DATE('2024-03-26', 'YYYY-MM-DD'), TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'KARTA', 'FALSE');
INSERT INTO Faktura (Celkova_cena, Datum_vyastaveni, Datum_splatnosti, Zpusob_platby, Zaplaceno) VALUES (120.00, TO_DATE('2024-03-25', 'YYYY-MM-DD'), TO_DATE('2024-04-09', 'YYYY-MM-DD'), 'HOTOVOST', 'FALSE');

INSERT INTO Zakazka (Popis, Datum_vytvoreni, Cas_upraveni, Termin, Stav, Auto, Cislo_faktury, Zakaznik) VALUES ('Výměna oleje', TO_DATE('2024-03-24', 'YYYY-MM-DD'), CURRENT_TIMESTAMP, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Servisovano', 'WAUZZZ4G8EN140987', 1, 1);
INSERT INTO Zakazka (Popis, Datum_vytvoreni, Cas_upraveni, Termin, Stav, Auto, Cislo_faktury, Zakaznik) VALUES ('Výměna brzdových destiček', TO_DATE('2024-03-23', 'YYYY-MM-DD'), CURRENT_TIMESTAMP, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Pripraveno k vyzdvihnuti', 'YS2R4X20005399401', 2, 1);
INSERT INTO Zakazka (Popis, Datum_vytvoreni, Cas_upraveni, Termin, Stav, Auto, Cislo_faktury, Zakaznik) VALUES ('Výměna spojek', TO_DATE('2024-03-26', 'YYYY-MM-DD'), CURRENT_TIMESTAMP, TO_DATE('2024-03-27', 'YYYY-MM-DD'), 'Pripraveno k vyzdvihnuti', 'YS2R4X20005399402', 5, 5);
INSERT INTO Zakazka (Popis, Datum_vytvoreni, Cas_upraveni, Termin, Stav, Auto, Cislo_faktury, Zakaznik) VALUES ('Výměna brzdových kotoučů', TO_DATE('2024-03-25', 'YYYY-MM-DD'), CURRENT_TIMESTAMP, TO_DATE('2024-03-27', 'YYYY-MM-DD'), 'Servisovano', 'YS2R4X20005399403', 6, 5);
INSERT INTO Zakazka (Popis, Datum_vytvoreni, Cas_upraveni, Termin, Stav, Auto, Cislo_faktury, Zakaznik) VALUES ('Výměna brzdových kotoučů', TO_DATE('2024-03-24', 'YYYY-MM-DD'), CURRENT_TIMESTAMP, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Servisovano', 'WAUZZZ4G8EN140988', 3, 3);

INSERT INTO Cinnost (Nazev, Cena, Termin, Stav, Cas_prace, Mechanik, Cislo_zakazky) VALUES ('Výměna oleje', 50.00, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Servisovano', 2, 1, 1);
INSERT INTO Cinnost (Nazev, Cena, Termin, Stav, Cas_prace, Mechanik, Cislo_zakazky) VALUES ('Výměna brzdových destiček', 100.00, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Pripraveno k vyzdvihnuti', 3, 2, 1);
INSERT INTO Cinnost (Nazev, Cena, Termin, Stav, Cas_prace, Mechanik, Cislo_zakazky) VALUES ('Výměna spojek', 120.00, TO_DATE('2024-03-27', 'YYYY-MM-DD'), 'Pripraveno k vyzdvihnuti', 2, 6, 5);
INSERT INTO Cinnost (Nazev, Cena, Termin, Stav, Cas_prace, Mechanik, Cislo_zakazky) VALUES ('Výměna brzdových kotoučů', 100.00, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Servisovano', 3, 4, 3);

INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Motorový olej 5W-30', 15.99, 0, 'TRUE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Brzdové destičky', 50.00, 50, 'TRUE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Filtr oleje', 10.00, 80, 'FALSE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Brzdové kotouče', 80.00, 20, 'TRUE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Spojky', 150.00, 10, 'TRUE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Motorový olej 5W-30', 15.99, 50, 'FALSE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Brzdové kotouče', 80.00, 20, 'TRUE');
INSERT INTO Material (Nazev, Cena, Mnozstvi_skladem, Pouzite) VALUES ('Spojky', 150.00, 10, 'TRUE');


-- Dotaz 1: Seznam automechaniků a jejich specializací
SELECT am.Mechanik_Id, o.Jmeno AS Mechanik, am.Specializace
FROM Automechanik am
JOIN Osoba o ON am.Osoba = o.Osoba_Id;

-- Dotaz 2: Celkový počet zakázek podle stavu
SELECT Stav, COUNT(*) AS Pocet_zakazek
FROM Zakazka
GROUP BY Stav;

-- Dotaz 3: Průměrná cena faktury podle způsobu platby
SELECT Zpusob_platby, AVG(Celkova_cena) AS Prumer_ceny_faktury
FROM Faktura
GROUP BY Zpusob_platby;

-- Dotaz 4: Seznam nezaplacených zakázek s datem splatnosti a kontaktem na zákazníka
SELECT z.Zakazka_Id, z.Popis, f.Cislo_faktury, f.Datum_splatnosti, o.Jmeno AS Zakaznik, o.Tel_cislo, O.Email
FROM Zakazka z
LEFT JOIN Faktura f ON z.Cislo_faktury = f.Cislo_faktury
JOIN Zakaznik zk ON z.Zakaznik = zk.Zakaznik_Id
JOIN Osoba o ON zk.Osoba = o.Osoba_Id
WHERE f.Cislo_faktury IS NULL OR f.Zaplaceno = 'FALSE';

-- Dotaz 5: Seznam zaneprazdnenych automechanikov
SELECT A.Mechanik_Id, A.Specializace
FROM Automechanik A
WHERE EXISTS (
    SELECT 1
    FROM Cinnost C
    WHERE C.Stav = 'Servisovano'
    AND C.Mechanik = A.Mechanik_Id
);


-- Dotaz 6: Seznam vsech zakazniku z Brna
SELECT *
FROM Zakazka
WHERE Zakaznik IN (
    SELECT Zakaznik_Id
    FROM Zakaznik
    WHERE Adresa LIKE '%Brno%'
);

-- Dotaz 7: Seznam vsech exterierovych automechanikov
SELECT *
FROM Automechanik
WHERE Specializace IN (
    SELECT Specializace
    FROM Automechanik
    WHERE Specializace = 'Karosář' OR Specializace = 'Lakování'
);


-- Dotaz 8: Seznam vsech aut zakaznika Eva Dolezalova
SELECT DISTINCT A.VIN, A.Znacka, A.Model
FROM Auto A
JOIN Zakazka Z ON A.VIN = Z.Auto
JOIN Zakaznik ZK ON Z.Zakaznik = ZK.Zakaznik_Id
JOIN Osoba O ON ZK.Osoba = O.Osoba_Id
WHERE O.Jmeno = 'Eva Doležalová';

-- Definice a vytvoření databázových triggerů

-- Trigger pro kontrolu stavu při vytváření nové zakázky
CREATE OR REPLACE TRIGGER check_order_status
BEFORE INSERT ON Zakazka
FOR EACH ROW
BEGIN
    IF :NEW.Stav NOT IN ('Pripraveno k vyzdvihnuti', 'Ceka na dodani dilu', 'Servisovano') THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nespravny stav zakazky! (Pripraveno k vyzdvihnuti, Ceka na dodani dilu, Servisovano)');
    END IF;
END;


-- Trigger pro aktualizaci stavu faktury po zaplacení
CREATE OR REPLACE TRIGGER update_invoice_status
AFTER UPDATE OF Zaplaceno ON Faktura
FOR EACH ROW
BEGIN
    IF :NEW.Zaplaceno = 'TRUE' THEN
        UPDATE Zakazka
        SET Stav = 'Pripraveno k vyzdvihnuti'
        WHERE Cislo_faktury = :NEW.Cislo_faktury;
    END IF;
END;

-- Uložená procedura pro výpočet celkové ceny faktury
create PROCEDURE calculate_invoice_total(invoice_id IN NUMBER)
AS
    total DECIMAL(10, 2);
BEGIN
    SELECT SUM(c.Cena) INTO total
    FROM Zakazka zk JOIN CINNOST c ON zk.ZAKAZKA_ID = c.CISLO_ZAKAZKY
    WHERE zk.Cislo_faktury = invoice_id;

    UPDATE Faktura
    SET Celkova_cena = total
    WHERE Cislo_faktury = invoice_id;
END;


-------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdatePersonEmail (
    -- parametry funkce
    p_Osoba_Id  IN  Osoba.Osoba_Id%TYPE,
    p_NewEmail  IN  Osoba.Email%TYPE
)
AS
    v_Osoba Osoba%ROWTYPE;
BEGIN
    SELECT * INTO v_Osoba
    FROM Osoba
    WHERE Osoba_Id = p_Osoba_Id;

    -- Check if person exists
    IF v_Osoba.Osoba_Id IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Error: Person with ID ' || p_Osoba_Id || ' not found.');
    ELSE
        -- Update email
        UPDATE Osoba
        SET Email = p_NewEmail
        WHERE Osoba_Id = p_Osoba_Id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Email updated successfully.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Person with ID ' || p_Osoba_Id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/
SELECT *
    FROM Osoba
    WHERE Osoba_Id = 1;
BEGIN
    UpdatePersonEmail(1, 'updated.email@example.com');
END;
SELECT *
    FROM Osoba
    WHERE Osoba_Id = 1;
-----------------------------------------------------------------------------------------

-- Vytvoření indexu pro zrychlení vyhledávání aut podle SPZ
CREATE INDEX idx_auto_spz ON Auto(SPZ);

-- Demonstrace použití EXPLAIN PLAN pro optimalizaci dotazu
-- Dotaz před optimalizací
EXPLAIN PLAN FOR
SELECT *
FROM Zakazka z
JOIN Zakaznik zk ON z.Zakaznik = zk.Zakaznik_Id
WHERE zk.Adresa LIKE '%Brno%';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvoření indexu pro zrychlení dotazu
CREATE INDEX idx_zakaznik_adresa ON Zakaznik(Adresa);

-- Dotaz po optimalizaci
EXPLAIN PLAN FOR
SELECT *
FROM Zakazka z
JOIN Zakaznik zk ON z.Zakaznik = zk.Zakaznik_Id
WHERE zk.Adresa LIKE '%Brno%';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Vytvoření materializovaného pohledu
CREATE MATERIALIZED VIEW mv_zakazka_full
BUILD IMMEDIATE
REFRESH COMPLETE
AS
SELECT z.*, zk.*, a.*
FROM Zakazka z
JOIN Zakaznik zk ON z.Zakaznik = zk.Zakaznik_Id
JOIN Auto a ON z.Auto = a.VIN;

-- Demonstrace použití materializovaného pohledu
SELECT * FROM mv_zakazka_full;

-- SELECT využívající klauzuli WITH a operátor CASE
WITH vystup AS (
    SELECT CASE
               WHEN Celkova_cena < 50 THEN 'Levne'
               WHEN Celkova_cena >= 50 AND Celkova_cena < 100 THEN 'Stredne drahe'
               ELSE 'Drahe'
           END AS Cena_kategorie
    FROM Faktura
)
SELECT * FROM vystup;


-- ---- pristupova prava ---- pro druheho clena tymu
-- prava k tabulkam
GRANT ALL ON MATERIAL TO xsucha18;
GRANT ALL ON CINNOST TO xsucha18;
GRANT ALL ON ZAKAZKA TO xsucha18;
GRANT ALL ON FAKTURA TO xsucha18;
GRANT ALL ON AUTO TO xsucha18;
GRANT ALL ON ZAKAZNIK TO xsucha18;
GRANT ALL ON AUTOMECHANIK TO xsucha18;
GRANT ALL ON OSOBA TO xsucha18;

-- prava k proceduram
GRANT EXECUTE ON calculate_invoice_total to xsucha18;

-- prava k materialized view
GRANT ALL ON mv_zakazka_full to xsucha18;

BEGIN calculate_invoice_total(1); END ;
