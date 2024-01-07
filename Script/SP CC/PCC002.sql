SET SEARCH_PATH TO CC;

DROP TYPE IF EXISTS PCC002_RESULTSET CASCADE;

CREATE TYPE PCC002_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    NR_TPCONTA          INTEGER
);

CREATE OR REPLACE FUNCTION PCC002 (
/*------------------------------------------------------------------
    Rotina de CRUD Tipo Contas da Moradia
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)  , /* Action                   */
                                       /*   I - Insert             */
                                       /*   U - Update             */
                                       /*   D - Delete             */
    ENT_NR_TPCONTA       INTEGER     , /* ID Tipo Conta            */
    ENT_NR_MORADOR       INTEGER     , /* Administrador            */
    ENT_NR_MORADIA       INTEGER     , /* Moradia                  */
    ENT_VC_TPCONTA       VARCHAR(20) , /* Descrição Tipo de conta  */
    ENT_IT_RECOR         NUMERIC(2,0)  /* Recorrência              */
)
    RETURNS SETOF PCC002_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   CC.PCC002_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _NR_TPCONTA          INTEGER     ;

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

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Moradia não localizada';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_NR_MORADOR = ENT_NR_MORADOR AND AD001_NR_TPMOR = 1 AND AD001_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Usuário sem privilégios de Administrador.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD004 WHERE AD004_NR_MORADOR = ENT_NR_MORADOR AND AD004_NR_MORADIA = ENT_NR_MORADIA AND AD004_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não registrado nesta moradia.';
END IF;

IF NOT EXISTS (SELECT * FROM AD.AD003 WHERE AD003_NR_MORADIA = ENT_NR_MORADIA AND AD003_NR_ADMMOR = ENT_NR_MORADOR AND AD003_IT_SITUAC = 1) THEN
    RAISE EXCEPTION 'Morador não é Administrador desta moradia';
END IF;

IF ENT_VC_ACTION = 'U' OR ENT_VC_ACTION = 'D' THEN

    IF ENT_NR_TPCONTA IS NULL THEN
        RAISE EXCEPTION 'Identificador Tipo de conta necessário';
    END IF;

    IF NOT EXISTS (SELECT * FROM CC.CC02 WHERE CC002_NR_TPCONTA = ENT_NR_TPCONTA AND CC002_IT_SITUAC = 1) THEN
        RAISE EXCEPTION 'Conta não localizada.';
    END IF;

END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/
IF ENT_VC_ACTION = 'I' THEN

    INSERT INTO CC.CC002 (
        CC002_VC_TPCONTA   ,
        CC002_NR_MORADIA   ,
        CC002_IT_RECOR     ,
        CC002_IT_SITUAC    ,
        CC002_DT_ULTATU    ,
        CC002_DT_INCLUS   
    ) VALUES (
        ENT_VC_TPCONTA     ,
        ENT_NR_MORADIA     ,
        ENT_IT_RECOR       ,
        1                  ,
        NOW()              ,
        NOW()
    ) RETURNING CC002_NR_TPCONTA INTO _NR_TPCONTA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    UPDATE 
       CC.CC002
    SET
       CC002_VC_TPCONTA = ENT_VC_TPCONTA,
       CC002_IT_RECOR   = ENT_IT_RECOR  ,
       CC002_DT_ULTATU  = NOW()
    WHERE
        CC002_NR_TPCONTA = ENT_NR_TPCONTA;
    
    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'D' THEN

    UPDATE 
       CC.CC002
    SET
       CC002_IT_SITUAC = 0   ,
       CC002_DT_ULTATU = NOW()
    WHERE
        CC002_NR_TPCONTA = ENT_NR_TPCONTA;
    
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
       _NR_TPCONTA
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