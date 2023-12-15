SET SEARCH_PATH TO AD;

DROP TYPE IF EXISTS PAD001_RESULTSET CASCADE;

CREATE TYPE PAD001_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    AD001_NR_MORADOR    INTEGER
);

CREATE OR REPLACE FUNCTION PAD001 (
/*------------------------------------------------------------------
    Rotina de CRUD MORADOR
-------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)  , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)  , /* Action                   */
                                       /*   I - Insert             */
                                       /*   U - Update             */
                                       /*   D - Delete             */
    ENT_NR_MORADOR       INTEGER     , /* ID Morador               */
    ENT_VC_NOME          VARCHAR(30) , /* Nome morador             */
    ENT_VC_SOBREN        VARCHAR(50) , /* Sobrenome morador        */
    ENT_VC_CPF           VARCHAR(11) , /* CPF                      */
    ENT_VC_EMAIL         VARCHAR(150), /* Email                    */
    ENT_VC_LOGIN         VARCHAR(30) , /* Login                    */
    ENT_VC_PASSW         VARCHAR     , /* Password                 */
    ENT_DT_ENTRADA       NUMERIC(8,0), /* Data de entrada          */
    ENT_NR_TPMOR         INTEGER       /* Tipo de morador          */
)
    RETURNS SETOF PAD001_RESULTSET
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

IF ENT_VC_ACTION = 'I' THEN
    IF EXISTS (SELECT * FROM AD.AD001 WHERE AD001_VC_CPF = ENT_VC_CPF) THEN
        RAISE EXCEPTION 'CPF já cadastrado.';
    END IF;

    IF EXISTS (SELECT * FROM AD.AD001 WHERE AD001_VC_EMAIL = ENT_VC_EMAIL) THEN
        RAISE EXCEPTION 'Email já cadastrado.';
    END IF;

    IF EXISTS (SELECT * FROM AD.AD001 WHERE AD001_VC_LOGIN = ENT_VC_LOGIN) THEN
        RAISE EXCEPTION 'Login já cadastrado.';
    END IF;
END IF;

IF ENT_VC_ACTION = 'U' OR ENT_VC_ACTION = 'D' THEN
    IF ENT_NR_MORADOR IS NULL THEN
        RAISE EXCEPTION 'Operação necessita do morador identificado.';
    END IF;

    IF NOT EXISTS (SELECT * FROM AD.AD001 WHERE AD001_NR_MORADOR = ENT_NR_MORADOR) THEN
        RAISE EXCEPTION 'Morador não localizado.';
    END IF;
END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/
IF ENT_VC_ACTION = 'I' THEN

    INSERT INTO AD.AD001 (
        AD001_VC_NOME    ,
        AD001_VC_SOBREN  ,
        AD001_VC_CPF     ,
        AD001_VC_EMAIL   ,
        AD001_VC_LOGIN   ,
        AD001_VC_PASSW   ,
        AD001_DT_ENTRADA ,
        AD001_NR_TPMOR   ,
        AD001_IT_SITUAC  ,
        AD001_DT_ULTATU  ,
        AD001_DT_INCLUS
    )
    VALUES (
        ENT_VC_NOME      ,
        ENT_VC_SOBREN    ,
        ENT_VC_CPF       ,
        ENT_VC_EMAIL     ,
        ENT_VC_LOGIN     ,
        ENT_VC_PASSW     ,
        ENT_DT_ENTRADA   ,
        ENT_NR_TPMOR     ,
        1                ,
        NOW()            ,
        NOW()
    ) RETURNING AD001_NR_MORADOR INTO _NR_MORADOR;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    UPDATE
       AD.AD001
    SET
       AD001_VC_NOME    = ENT_VC_NOME   ,
       AD001_VC_SOBREN  = ENT_VC_SOBREN ,
       AD001_VC_CPF     = ENT_VC_CPF    ,
       AD001_VC_EMAIL   = ENT_VC_EMAIL  ,
       AD001_VC_LOGIN   = ENT_VC_LOGIN  ,
       AD001_VC_PASSW   = ENT_VC_PASSW  ,
       AD001_DT_ENTRADA = ENT_DT_ENTRADA,
       AD001_DT_ULTATU  = NOW()
    WHERE
       AD001_NR_MORADOR = ENT_NR_MORADOR;

    _CD_ERRO    := 0;
    _DS_ERRO    := 'OK';
    _NR_MORADOR := ENT_NR_MORADOR;

ELSIF ENT_VC_ACTION = 'D' THEN

    UPDATE
       AD.AD001
    SET
       AD001_IT_SITUAC = 0              ,
       AD001_DT_ULTATU = NOW()
    WHERE
       AD001_NR_MORADOR = ENT_NR_MORADOR;

    _CD_ERRO    := 0;
    _DS_ERRO    := 'OK';
    _NR_MORADOR := ENT_NR_MORADOR;

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
