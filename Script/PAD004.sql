SET SEARCH_PATH TO AD;

DROP TYPE IF EXISTS PAD004_RESULTSET CASCADE;

CREATE TYPE PAD004_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255)
);

CREATE OR REPLACE FUNCTION PAD004 (
/*------------------------------------------------------------------
    Rotina de CRUD MORADIA X MORADOR
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)  , /* Action                   */
                                       /*   I - Insert             */
                                       /*   U - Update             */
                                       /*   D - Delete             */
    ENT_NR_MORADIA       INTEGER     , /* ID Moradia               */
    ENT_NR_MORADOR       INTEGER       /* ID Morador               */
)
    RETURNS SETOF PAD004_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   AD.PAD004_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);

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

IF ENT_NR_MORADIA IS NULL OR ENT_NR_MORADOR IS NULL THEN
    RAISE EXCEPTION 'Dados insuficiente para processar solicitação.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Moradia não localizada.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_NR_MORADOR = ENT_NR_MORADOR AND AD001_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não localizado.';
END IF;

IF EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_IT_SITUAC= 1) THEN
    RAISE EXCEPTION 'Morador já possui registro nessa moradia';
END IF;

IF EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador possui registro ativo em outra moradia.';
END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/

IF ENT_VC_ACTION = 'I' THEN

    INSERT INTO AD.AD004 (
        AD004_NR_MORADIA ,
        AD004_NR_MORADOR ,
        AD004_IT_SITUAC  ,
        AD004_DT_ULTATU  ,
        AD004_DT_INCLUS
    ) VALUES (
        ENT_NR_MORADIA   ,
        ENT_NR_MORADOR   ,
        1                ,
        NOW()            ,
        NOW()
    );

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    RAISE EXCEPTION 'Comando não permitido.';

ELSIF ENT_VC_ACTION = 'D' THEN

    UPDATE
      AD.AD004
    SET
      AD004_IT_SITUAC = 0     ,
      AD004_DT_ULTATU = NOW()
    WHERE
        AD004_NR_MORADIA = ENT_NR_MORADIA
    AND AD004_NR_MORADOR = ENT_NR_MORADOR;

    _CD_ERRO  := 0;
    _DS_ERRO  := 'OK';

ELSE
    RAISE EXCEPTION 'Comando não reconhecido.';
END IF;

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN
    SELECT
       _CD_ERRO,
       _DS_ERRO
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