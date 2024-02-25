SET SEARCH_PATH TO CC;

DROP TYPE IF EXISTS PCC007_RESULTSET CASCADE;

CREATE TYPE PCC007_RESULTSET AS (
    CC002_NR_TPCONTA     INTEGER    ,
    CC002_VC_TPCONTA     VARCHAR    ,
    CC002_IT_RECOR       NUMERIC(2,0)
);

CREATE OR REPLACE FUNCTION PCC007 (
/*-------------------------------------------------------------------
    Rotina de Listagem dos Tipos de Contas de uma moradia
--------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)   , /* Stored procedure version */
    ENT_NR_MORADOR       INTEGER      , /* ID Morador               */
    ENT_NR_MORADIA       INTEGER        /* ID Moradia               */
)
    RETURNS SETOF PCC007_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   CC.PCC007_RESULTSET%Rowtype;
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

IF ENT_NR_MORADIA IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer a moradia.';
END IF;

IF ENT_NR_MORADOR IS NULL THEN
    RAISE EXCEPTION 'É ncessário fornecer o morador.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Moradia não localizada.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não registrado nesta moradia.';
END IF;

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN 
    SELECT
       CC002_NR_TPCONTA,
       CC002_VC_TPCONTA,
       CC002_IT_RECOR
    FROM
       CC.CC002
    WHERE
        CC002_NR_MORADIA = ENT_NR_MORADIA
    AND CC002_IT_SITUAC  = 1
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