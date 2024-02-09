SET SEARCH_PATH TO AD;

DROP TYPE IF EXISTS PAD002_RESULTSET CASCADE;

CREATE TYPE PAD002_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    AD001_NR_MORADOR    INTEGER     ,
    AD001_VC_NOME       VARCHAR(30) ,
    AD001_VC_SOBREN     VARCHAR(50) ,
    AD001_DT_ENTRADA    NUMERIC(8,0)
);

CREATE OR REPLACE FUNCTION PAD002 (
/*------------------------------------------------------------------
    Rotina de Login
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_VC_LOGIN         VARCHAR(30) , /* Email do morador         */
    ENT_VC_PASSW         VARCHAR       /* Password do morador      */
)
    RETURNS SETOF PAD002_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   AD.PAD002_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _DATA_MORADOR        RECORD      ;

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

IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_VC_LOGIN = ENT_VC_LOGIN) THEN
    RAISE EXCEPTION 'Usuário não localizado';
END IF;

IF NOT EXISTS (SELECT
                  *
               FROM
                  AD.AD001
               WHERE
                   AD001_VC_LOGIN = ENT_VC_LOGIN
               AND AD001_VC_PASSW = ENT_VC_PASSW) THEN
    RAISE EXCEPTION 'Usuário não localizado';
 END IF;

SELECT
  AD001_NR_MORADOR,
  AD001_VC_NOME   ,
  AD001_VC_SOBREN ,
  AD001_DT_ENTRADA
INTO
  _DATA_MORADOR
FROM
  AD.AD001
WHERE
    AD001_VC_LOGIN = ENT_VC_LOGIN
AND AD001_VC_PASSW = ENT_VC_PASSW;

_CD_ERRO := 0;
_DS_ERRO := 'OK';

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN
    SELECT
       _CD_ERRO,
       _DS_ERRO,
       _DATA_MORADOR.AD001_NR_MORADOR,
       _DATA_MORADOR.AD001_VC_NOME   ,
       _DATA_MORADOR.AD001_VC_SOBREN ,
       _DATA_MORADOR.AD001_DT_ENTRADA
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