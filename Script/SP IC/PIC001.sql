SET SEARCH_PATH TO IC;

DROP TYPE IF EXISTS PIC001_RESULTSET CASCADE;

CREATE TYPE PIC001_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    NR_ITEM             INTEGER
);

CREATE OR REPLACE FUNCTION PIC001 (
/*------------------------------------------------------------------
    Rotina de CRUD Itens Coletivos
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)  , /* Action                   */
                                       /*   I - Insert             */
                                       /*   U - Update             */
                                       /*   D - Delete             */
    ENT_NR_MORADIA       INTEGER     , /* Moradia                  */
    ENT_NR_MORADOR       INTEGER     , /* Morador                  */
    ENT_NR_ITEM          INTEGER     , /* ID Item                  */
    ENT_VC_ITEM          VARCHAR(40)   /* Item                     */
)
    RETURNS SETOF PIC001_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   IC.PIC001_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _NR_ITEM             INTEGER     ;

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
    RAISE EXCEPTION 'É necessário fornecer a moradia.';
END IF;

IF ENT_NR_MORADOR IS NULL THEN
    RAISE EXCEPTION 'É ncessário fornecer o morador.';
END IF;

IF ENT_VC_ITEM IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer um item.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Moradia não localizada.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não registrado nesta moradia.';
END IF;

IF ENT_VC_ACTION = 'U' OR ENT_VC_ACTION = 'D' THEN
    IF ENT_NR_ITEM IS NULL THEN
        RAISE EXCEPTION 'É necessário fornecer o identificador do item.';
    END IF;
END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/
IF ENT_VC_ACTION = 'I' THEN

    INSERT INTO IC.IC001 (
        IC001_NR_MORADIA ,
        IC001_NR_MORADOR ,
        IC001_VC_ITEM    ,
        IC001_IT_SITUAC  ,
        IC001_DT_ULTATU  ,
        IC001_DT_INCLUS
    ) VALUES (
        ENT_NR_MORADIA   ,
        ENT_NR_MORADOR   ,
        ENT_VC_ITEM      ,
        0                ,
        NOW()            ,
        NOW()
    ) RETURNING IC001_NR_ITEM INTO _NR_ITEM;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    UPDATE
        IC.IC001
    SET
        IC001_VC_ITEM = ENT_VC_ITEM,
        IC001_DT_ULTATU = NOW()
    WHERE
        IC001_NR_ITEM = ENT_NR_ITEM;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'D' THEN

    DELETE FROM IC.IC001
    WHERE
        IC001_NR_ITEM = ENT_NR_ITEM;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSE
    RAISE EXCEPTION 'Comando não reconhecido.';
END IF;

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN
    SELECT
       _CD_ERRO,
       _DS_ERRO,
       _NR_ITEM
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