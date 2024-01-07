SET SEARCH_PATH TO CC;

DROP TYPE IF EXISTS PCC003_RESULTSET CASCADE;

CREATE TYPE PCC003_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255)
);

CREATE OR REPLACE FUNCTION PCC003 (
/*------------------------------------------------------------------
    Rotina de CRUD Orçamento Morador
--------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)   , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)   , /* Action                   */
                                        /*   I - Insert             */
                                        /*   U - Update             */
                                        /*   D - Delete             */
    ENT_NR_MORADIA       INTEGER      , /* Moradia                  */
    ENT_NR_CONTAM        INTEGER      , /* Conta Mensal             */
    ENT_VL_VALOR         NUMERIC(10,2)  /* Valor                    */
)
    RETURNS SETOF PCC003_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   CC.PCC003_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0) ;
    _DS_ERRO             VARCHAR(255) ;
    _NR_QTDMORADOR       INTEGER      ;
    _VL_INDVALOR         NUMERIC(10,2);

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

IF NOT EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Não existe moradores ativos para essa moradia.';
END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/
IF ENT_VC_ACTION = 'I' THEN

    _NR_QTDMORADOR := (SELECT COUNT(*) FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_IT_SITUAC = 1);
    _VL_INDVALOR := (SELECT ROUND(ENT_VL_VALOR / _NR_QTDMORADOR, 2));

    INSERT INTO CC.CC003 (
        CC003_NR_CONTAM  ,
        CC003_NR_MORADIA ,
        CC003_NR_MORADOR ,
        CC003_VL_VALORM  ,
        CC003_IT_SITUAC  ,
        CC003_IT_OKADM   ,
        CC003_DT_ULTATU  ,
        CC003_DT_INCLUS  )
    SELECT
        ENT_NR_CONTAM    ,
        AD004_NR_MORADIA ,
        AD004_NR_MORADOR ,
        _VL_INDVALOR     ,
        0                ,
        0                ,
        NOW()            ,
        NOW()
    FROM
        AD.AD004
    WHERE
        AD004_NR_MORADIA = ENT_NR_MORADIA
    AND AD004_IT_SITUAC  = 1;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    _NR_QTDMORADOR := (SELECT COUNT(*) FROM AD.AD004 WHERE AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_IT_SITUAC = 1);
    _VL_INDVALOR := (SELECT ROUND(ENT_VL_VALOR / _NR_QTDMORADOR, 2));

    raise notice '%', _VL_INDVALOR;
    raise notice '%', ENT_NR_CONTAM;
    raise notice '%', ENT_NR_MORADIA;

    UPDATE
        CC.CC003
    SET
        CC003_VL_VALORM = _VL_INDVALOR ,
        CC003_DT_ULTATU = NOW()
    WHERE
        CC003_NR_CONTAM  = ENT_NR_CONTAM
    AND CC003_NR_MORADIA = ENT_NR_MORADIA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'D' THEN

    DELETE FROM
        CC.CC003
    WHERE
        CC003_NR_MORADIA = ENT_NR_MORADIA
    AND CC003_NR_CONTAM  = ENT_NR_CONTAM;

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