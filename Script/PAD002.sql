SET SEARCH_PATH TO AD;

DROP TYPE IF EXISTS PAD002_RESULTSET CASCADE;

CREATE TYPE PAD002_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    AD001_NR_MORADOR    INTEGER
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
    _NR_MORADOR          INTEGER     ;

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


_CD_ERRO := 0;
_DS_ERRO := 'OK';
_NR_MORADOR := (SELECT
                   AD001_NR_MORADOR
                FROM
                   AD.AD001
                WHERE
                    AD001_VC_LOGIN = ENT_VC_LOGIN
                AND AD001_VC_PASSW = ENT_VC_PASSW);

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN
    SELECT
       _CD_ERRO,
       _DS_ERRO,
       _NR_MORADOR
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