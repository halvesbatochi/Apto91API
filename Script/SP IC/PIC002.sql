SET SEARCH_PATH TO IC;

DROP TYPE IF EXISTS PIC002_RESULTSET CASCADE;

CREATE TYPE PIC002_RESULTSET AS (
    CD_ERRO             NUMERIC(3,0),
    DS_ERRO             VARCHAR(255),
    NR_COMPRA           INTEGER
);

CREATE OR REPLACE FUNCTION PIC002 (
/*------------------------------------------------------------------
    Rotina de CRUD Compras Itens Coletivos
--------------------------------------------------------------------*/
    ENT_NR_VRS           NUMERIC(5)   , /* Stored procedure version */
    ENT_VC_ACTION        VARCHAR(1)   , /* Action                   */
                                        /*   I - Insert             */
                                        /*   U - Update             */
                                        /*   D - Delete             */
    ENT_NR_COMPRA        INTEGER      , /* Compra                   */
    ENT_NR_ITEM          INTEGER      , /* Item                     */
    ENT_NR_MORADOR       INTEGER      , /* Morador                  */
    ENT_NR_QTDE          NUMERIC(5,0) , /* Quantidade               */
    ENT_VL_VALOR         NUMERIC(10,2)  /* Valor                    */
)
    RETURNS SETOF PIC002_RESULTSET
AS $$

/*-------------------------------------------------------------------
    Local variables
-------------------------------------------------------------------*/
DECLARE
    _R                   IC.PIC002_RESULTSET%Rowtype;
    _CD_ERRO             NUMERIC(3,0);
    _DS_ERRO             VARCHAR(255);
    _NR_COMPRA           INTEGER     ;

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

IF ENT_NR_MORADOR IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer o morador.';
END IF;

IF ENT_NR_ITEM IS NULL THEN
    RAISE EXCEPTION 'É necessário fornecer o identificador do item.';
END IF;

IF ENT_NR_QTDE <= 0 THEN
    RAISE EXCEPTION 'Quantidade inválida.';
END IF;

IF ENT_VL_VALOR <= 0.0 THEN
    RAISE EXCEPTION 'Valor inválido.';
END IF;

IF NOT EXISTS (SELECT * FROM IC.IC001 WHERE IC001_NR_ITEM = ENT_NR_ITEM AND IC001_IT_SITUAC = 0) THEN
    RAISE EXCEPTION 'Item não localizado.';
END IF;

IF NOT EXISTS (SELECT
                 *
               FROM
                 IC.IC001 I INNER JOIN AD.AD004 A
                 ON (I.IC001_NR_MORADOR = A.AD004_NR_MORADOR AND I.IC001_NR_MORADIA = A.AD004_NR_MORADIA)
               WHERE
                 IC001_NR_MORADOR = ENT_NR_MORADOR
              ) THEN
    RAISE EXCEPTION 'Morador não localizado na moradia.';
END IF;

IF ENT_VC_ACTION = 'U' OR ENT_VC_ACTION = 'D' THEN
    IF ENT_NR_COMPRA IS NULL THEN
        RAISE EXCEPTION 'É necessário fornecer o identificador da compra.';
    END IF;

    IF NOT EXISTS (SELECT * FROM IC.IC002 WHERE IC002_NR_COMPRA = ENT_NR_COMPRA AND IC002_IT_SITUAC = 0) THEN
        RAISE EXCEPTION 'Compra não localizada.';
    END IF;
END IF;

/*-------------------------------------------------------------------
    CRUD
-------------------------------------------------------------------*/
IF ENT_VC_ACTION = 'I' THEN

    INSERT INTO IC.IC002 (
        IC002_NR_ITEM    ,
        IC002_NR_MORADOR ,
        IC002_NR_QTDE    ,
        IC002_VL_VALOR   ,
        IC002_IT_SITUAC  ,
        IC002_DT_ULTATU  ,
        IC002_DT_INCLUS
    ) VALUES (
        ENT_NR_ITEM      ,
        ENT_NR_MORADOR   ,
        ENT_NR_QTDE      ,
        ENT_VL_VALOR     ,
        0                ,
        NOW()            ,
        NOW()
    ) RETURNING IC002_NR_COMPRA INTO _NR_COMPRA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';

ELSIF ENT_VC_ACTION = 'U' THEN

    UPDATE
        IC.IC002
    SET
        IC002_NR_QTDE   = ENT_NR_QTDE,
        IC002_VL_VALOR  = ENT_VL_VALOR,
        IC002_DT_ULTATU = NOW()
    WHERE
        IC002_NR_COMPRA = ENT_NR_COMPRA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';
    _NR_COMPRA := ENT_NR_COMPRA;

ELSIF ENT_VC_ACTION = 'D' THEN

    DELETE FROM IC.IC002
    WHERE
        IC002_NR_COMPRA = ENT_NR_COMPRA;

    _CD_ERRO := 0;
    _DS_ERRO := 'OK';
    _NR_COMPRA := ENT_NR_COMPRA;

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
       _NR_COMPRA
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