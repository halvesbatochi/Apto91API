SET SEARCH_PATH TO IC;

DROP TYPE IF EXISTS PIC003_RESULTSET CASCADE;

CREATE TYPE PIC003_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    NR_COMPRA           INTEGER
);

CREATE OR REPLACE FUNCTION PIC003 (
/*------------------------------------------------------------------
    Rotina de OK ADM Compras
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_NR_MORADIA       INTEGER     , /* Moradia                  */
    ENT_NR_MORADOR       INTEGER     , /* Morador                  */
    ENT_NR_ITEM          INTEGER     , /* Item                     */
    ENT_NR_COMPRA        INTEGER       /* Compra                   */
)
    RETURNS SETOF PIC003_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   IC.PIC003_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _NR_COMPRA           INTEGER     ;

/*-------------------------------------------------------------------
    Function
-------------------------------------------------------------------*/
BEGIN
/*-------------------------------------------------------------------
    Validations
-------------------------------------------------------------------*/
IF NOT EXISTS (SELECT * FROM AD.AD999 WHERE AD999_IT_VRS = ENT_NR_VRS) THEN
    RAISE EXCEPTION 'Autenticação de SP negada.';
END IF;

IF ENT_NR_MORADIA IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer a moradia';
END IF;

IF ENT_NR_MORADOR IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer o morador.';
END IF;

IF ENT_NR_COMPRA IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer o identificador da compra.';
END IF;

IF ENT_NR_ITEM IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer o identificador do item.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_NR_MORADOR = ENT_NR_MORADOR AND AD001_NR_TPMOR = 1 AND AD001_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não localizado ou sem privilégio de Administrador.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Moradia não localizada.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_NR_ADMMOR = ENT_NR_MORADOR AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não é Administrador desta moradia.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não registrado nesta moradia.';
END IF;

IF NOT EXISTS (SELECT * FROM IC.IC001 WHERE IC001_NR_ITEM = ENT_NR_ITEM AND IC001_IT_SITUAC = 0) THEN
    RAISE EXCEPTION 'Item não localizado.';
END IF;

IF NOT EXISTS (SELECT * FROM IC.IC002 WHERE IC002_NR_COMPRA = ENT_NR_COMPRA AND IC002_NR_ITEM = ENT_NR_ITEM AND IC002_IT_SITUAC = 0) THEN
    RAISE EXCEPTION 'Compra não localizada.';
END IF;

/*-------------------------------------------------------------------
    ROTINA
-------------------------------------------------------------------*/

UPDATE
    IC.IC002
SET
    IC002_IT_SITUAC = 1,
    IC002_DT_ULTATU = NOW()
WHERE
    IC002_NR_COMPRA = ENT_NR_COMPRA;


UPDATE
    IC.IC001
SET
    IC001_IT_SITUAC = 1,
    IC001_DT_ULTATU = NOW()
WHERE
    IC001_NR_ITEM = ENT_NR_ITEM;

_CD_ERRO := 0;
_DS_ERRO := 'OK';

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN
    SELECT
       _CD_ERRO,
       _DS_ERRO,
       _NR_COMPRA
    LOOP
       RETURN NEXT _R;
    END LOOP;

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*::               EXCEPTION HANDLING POSTGRES                   ::*/
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
EXCEPTION WHEN OTHERS THEN
    _CD_ERRO := -1;
    _DS_ERRO := SQLERRM;

    FOR _R IN
        SELECT
           _CD_ERRO,
           _DS_ERRO
        LOOP
           RETURN NEXT _R;
        END LOOP;
    RETURN;
END
/*-----------------------------------------------------------------*/
$$ LANGUAGE PLPGSQL;