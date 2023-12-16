SET SEARCH_PATH TO AD;

DROP TYPE IF EXISTS PAD003_RESULTSET CASCADE;

CREATE TYPE PAD003_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    AD003_NR_MORADIA    INTEGER
);

CREATE OR REPLACE FUNCTION PAD003 (
/*------------------------------------------------------------------
    Rotina de CRUD MORADIA
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)  , /* Action                   */
                                       /*   I - Insert             */
                                       /*   U - Update             */
                                       /*   D - Delete             */
    ENT_NR_MORADIA       INTEGER     , /* ID Moradia               */
    ENT_NR_MORADOR       INTEGER     , /* ID Morador ADM           */
    ENT_VC_MORADIA       VARCHAR(15) , /* Nome Moradia             */
    ENT_DT_DDVENC        NUMERIC(2,0)  /* Dia de Venc. Padrão      */
)
    RETURNS SETOF PAD003_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   AD.PAD003_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _VC_TOKEN            VARCHAR(6)  ;
    _NR_MORADIA          INTEGER     ;

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

IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_NR_MORADOR = ENT_NR_MORADOR AND AD001_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não localizado.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_NR_MORADOR = ENT_NR_MORADOR AND AD001_NR_TPMOR = 1 AND AD001_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'O morador não possui privilégios de Administrador para criar Moradias.';
END IF;

IF ENT_VC_ACTION = 'U' OR ENT_VC_ACTION = 'D' THEN
    IF ENT_NR_MORADIA IS NULL THEN
        RAISE EXCEPTION 'Operação necessita da moradia identificada.';
    END IF;

    IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA) THEN
        RAISE EXCEPTION 'Moradia não localizada';
    END IF;
END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/
IF ENT_VC_ACTION = 'I' THEN

    _VC_TOKEN := (SELECT UPPER(SUBSTR(MD5(RANDOM()::TEXT), 0, 7)));

    WHILE (EXISTS (SELECT * FROM AD.AD003 WHERE AD003_VC_TOKEN = _VC_TOKEN)) LOOP
        _VC_TOKEN := (SELECT UPPER(SUBSTR(MD5(RANDOM()::TEXT), 0, 7)));
    END LOOP;

    INSERT INTO AD.AD003 (
        AD003_VC_MORADIA ,
        AD003_NR_ADMMOR  ,
        AD003_DT_DDVENC  ,
        AD003_VC_TOKEN   ,
        AD003_IT_SITUAC  ,
        AD003_DT_ULTATU  ,
        AD003_DT_INCLUS
    )
    VALUES (
        ENT_VC_MORADIA   ,
        ENT_NR_MORADOR   ,
        ENT_DT_DDVENC    ,
        _VC_TOKEN        ,
        1                ,
        NOW()            ,
        NOW()
    ) RETURNING AD003_NR_MORADIA INTO _NR_MORADIA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    UPDATE
      AD.AD003
    SET
      AD003_VC_MORADIA = ENT_VC_MORADIA ,
      AD003_NR_ADMMOR  = ENT_NR_MORADOR ,
      AD003_DT_DDVENC  = ENT_DT_DDVENC  ,
      AD003_DT_ULTATU  = NOW()
    WHERE
      AD003_NR_MORADIA = ENT_NR_MORADIA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';
    _NR_MORADIA := ENT_NR_MORADIA;

ELSEIF ENT_VC_ACTION = 'D' THEN

    UPDATE
      AD.AD003
    SET
      AD003_IT_SITUAC = 0               ,
      AD003_DT_ULTATU = NOW()
    WHERE
      AD003_NR_MORADIA = ENT_NR_MORADIA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';
    _NR_MORADIA := ENT_NR_MORADIA;

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
       _NR_MORADIA
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