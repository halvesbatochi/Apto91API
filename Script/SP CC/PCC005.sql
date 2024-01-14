SET SEARCH_PATH TO CC;

DROP TYPE IF EXISTS PCC005_RESULTSET CASCADE;

CREATE TYPE PCC005_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255)
);

CREATE OR REPLACE FUNCTION PCC005 (
/*------------------------------------------------------------------
    Rotina de Pagamento de Conta - Morador
--------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)   , /* Stored procedure version */
    ENT_NR_MORADIA       INTEGER      , /* Moradia                  */
    ENT_NR_MORADOR       INTEGER      , /* Morador                  */
    ENT_NR_CONTAM        INTEGER      , /* Conta Mensal             */
    ENT_NR_ORCAM         INTEGER      , /* Orçamento Morador        */
    ENT_DT_PAGAM         NUMERIC(8,0)   /* Data de pagamento        */
)
    RETURNS SETOF PCC005_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   CC.PCC005_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _DT_PAGAM            NUMERIC(8,0);

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
    RAISE EXCEPTION 'Moradia não informada.';
END IF;

IF ENT_NR_MORADOR IS NULL THEN
    RAISE EXCEPTION 'Morador não informado.';
END IF;

IF ENT_NR_CONTAM IS NULL THEN
    RAISE EXCEPTION 'Conta mensal não informado.';
END IF;

IF ENT_NR_ORCAM IS NULL THEN
    RAISE EXCEPTION 'Orçamento pessoal não informado.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Moradia não localizada';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não registrado nesta moradia.';
END IF;

IF NOT EXISTS (SELECT * FROM CC.CC001 WHERE CC001_NR_CONTAM = ENT_NR_CONTAM AND CC001_NR_MORADIA = ENT_NR_MORADIA AND CC001_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Conta Mensal não localizada para essa moradia.';
END IF;

IF NOT EXISTS (SELECT * FROM CC.CC003 WHERE CC003_NR_ORCAM = ENT_NR_ORCAM AND CC003_NR_CONTAM = ENT_NR_CONTAM AND CC003_NR_MORADIA = ENT_NR_MORADIA AND CC003_NR_MORADOR = ENT_NR_MORADOR AND CC003_IT_SITUAC = 0) THEN
    RAISE EXCEPTION 'Orçamento pessoal não localizado';
END IF;

IF EXISTS (SELECT * FROM CC.CC003 WHERE CC003_NR_ORCAM = ENT_NR_ORCAM AND CC003_NR_CONTAM = ENT_NR_CONTAM AND CC003_NR_MORADIA = ENT_NR_MORADIA AND CC003_NR_MORADOR = ENT_NR_MORADOR AND CC003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Orçamento pessoal pago.';
END IF;

/*-------------------------------------------------------------------
    ROTINA
-------------------------------------------------------------------*/

CASE
    WHEN ENT_DT_PAGAM IS NOT NULL THEN _DT_PAGAM := ENT_DT_PAGAM;
    WHEN ENT_DT_PAGAM IS NULL THEN _DT_PAGAM := (SELECT TO_CHAR(NOW()::DATE, 'YYYYMMDD')::NUMERIC(8,0));
END CASE;

UPDATE
    CC.CC003
SET
    CC003_IT_SITUAC = 1,
    CC003_DT_PAGAM  = _DT_PAGAM,
    CC003_DT_ULTATU = NOW()
WHERE
    CC003_NR_ORCAM   = ENT_NR_ORCAM
AND CC003_NR_CONTAM  = ENT_NR_CONTAM
AND CC003_NR_MORADIA = ENT_NR_MORADIA
AND CC003_NR_MORADOR = ENT_NR_MORADOR;

_CD_ERRO := 0;
_DS_ERRO := 'OK';

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