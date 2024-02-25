SET SEARCH_PATH TO CC;

DROP TYPE IF EXISTS PCC008_RESULTSET CASCADE;

CREATE TYPE PCC008_RESULTSET AS (
    CD_ERRO           INTEGER      ,
    DS_ERRO           VARCHAR(255) ,
    CC003_NR_ORCAM    INTEGER      ,
    CC003_NR_CONTAM   INTEGER      ,
    CC003_VL_VALORM   NUMERIC(10,2),
    CC003_IT_SITUAC   NUMERIC(2,0) ,
    CC003_IT_OKADM    NUMERIC(2,0) ,
    CC001_NR_TPCONTA  INTEGER      ,
    CC002_VC_TPCONTA  VARCHAR(20)  ,
    CC001_DT_DDVENC   NUMERIC(2,0) ,
    CC001_DT_AMVENC   NUMERIC(6,0) ,
    CC001_VL_VALOR    NUMERIC(10,2),
    CC001_IT_SITUAC   NUMERIC(2,0)
);

CREATE OR REPLACE FUNCTION PCC008 (
/*-------------------------------------------------------------------
    Rotina de Listagem dos Tipos de Contas de uma moradia
--------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)   , /* Stored procedure version */
    ENT_NR_MORADOR       INTEGER      , /* ID Morador               */
    ENT_NR_MORADIA       INTEGER      , /* ID Moradia               */
    ENT_DT_INI           NUMERIC(6,0) , /* Data Inicio              */
    ENT_DT_FIM           NUMERIC(6,0)   /* Data Fim                 */
)
    RETURNS SETOF PCC008_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   CC.PCC008_RESULTSET%Rowtype;
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

IF ENT_DT_INI IS NULL THEN
    ENT_DT_INI := 000000;
END IF;

IF ENT_DT_FIM IS NULL THEN
    ENT_DT_FIM := 999999;
END IF;

/*=================================================================*/
/*= RESULT SET                                                    =*/
/*=================================================================*/
FOR _R IN
    SELECT
       0                 ,
       NULL              ,
       CC003_NR_ORCAM    ,
       CC003_NR_CONTAM   ,
       CC003_VL_VALORM   ,
       CC003_IT_SITUAC   ,
       CC003_IT_OKADM    ,
       CC001_NR_TPCONTA  ,
       CC002_VC_TPCONTA  ,
       CC001_DT_DDVENC   ,
       CC001_DT_AMVENC   ,
       CC001_VL_VALOR    ,
       CC001_IT_SITUAC
    FROM
       CC.CC003
    INNER JOIN CC.CC001 ON (CC003_NR_CONTAM = CC001_NR_CONTAM AND
                            CC003_NR_MORADIA = CC001_NR_MORADIA)
    INNER JOIN CC.CC002 ON (CC001_NR_TPCONTA = CC002_NR_TPCONTA AND
                            CC001_NR_MORADIA = CC002_NR_MORADIA)
    WHERE
        CC003_NR_MORADIA = ENT_NR_MORADIA
    AND CC003_NR_MORADOR = ENT_NR_MORADOR
    AND CC001_DT_AMVENC BETWEEN ENT_DT_INI AND ENT_DT_FIM
    ORDER BY
       CC001_NR_TPCONTA,
       CC001_DT_AMVENC
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