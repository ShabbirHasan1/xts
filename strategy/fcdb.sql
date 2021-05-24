CREATE SEQUENCE "public".broker_id_seq START WITH 1;

CREATE SEQUENCE "public".customer_id_seq START WITH 123456;

CREATE SEQUENCE "public".strategy_id_seq START WITH 501;

CREATE SEQUENCE "public".strategy_params_id_seq START WITH 1;

CREATE SEQUENCE "public".subscribers_id_seq START WITH 54321;

CREATE SEQUENCE "public".strategy_position_id_seq START WITH 21011000000100;

CREATE SEQUENCE "public".position_id_seq START WITH 1000000100;


--CREATE SEQUENCE "public".user_id_seq START WITH 10000;

CREATE  TABLE "public".broker (
    id                   integer DEFAULT nextval('broker_id_seq'::regclass) NOT NULL ,
    name                 varchar(100)  NOT NULL ,
    CONSTRAINT pk_broker_id PRIMARY KEY ( id )
 );

CREATE  TABLE "public".customer (
    id                   integer DEFAULT nextval('customer_id_seq'::regclass) NOT NULL ,
    first_name           varchar(100)   ,
    last_name            varchar(100)   ,
    mobile               bigint   ,
    mail                 varchar(50)   ,
    address              varchar(200)   ,
    active               boolean   ,
    telegram_id          integer   ,
    created_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    updated_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    CONSTRAINT pk_customer_id PRIMARY KEY ( id )
 );

CREATE  TABLE "public".strategy (
    id                   integer  DEFAULT nextval('strategy_id_seq'::regclass) NOT NULL ,
    name                 varchar(100)  NOT NULL ,
    min_multiplier       integer DEFAULT 1 NOT NULL ,
    capital_required     numeric(12,2)   ,
    price_per_month      numeric(10,2) DEFAULT 0 NOT NULL ,
    description          text DEFAULT 'FirstChoice Strategy'::text  ,
    created_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    updated_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    CONSTRAINT pk_strategy_id PRIMARY KEY ( id )
 );

CREATE  TABLE "public".strategy_params (
    id                   integer DEFAULT nextval('strategy_params_id_seq'::regclass) NOT NULL ,
    name                 varchar(100)  NOT NULL ,
    strategy_id          integer   ,
    script_name          varchar(100)   ,
    start_time           text   ,
    repair_time          time   ,
    end_time             time DEFAULT '15:05:00'::time without time zone  ,
    target               numeric(7,2)   ,
    stop_loss            numeric(7,2)   ,
    created_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    updated_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    CONSTRAINT pk_strategy_params_id PRIMARY KEY ( id ),
    CONSTRAINT fk_strategy_params_strategy FOREIGN KEY ( strategy_id ) REFERENCES "public".strategy( id )
 );

CREATE  TABLE "public".subscribers (
    id                   integer DEFAULT nextval('subscribers_id_seq'::regclass) NOT NULL ,
    customer_id          integer  NOT NULL ,
    strategy_id          integer  NOT NULL ,
    broker_id            integer   ,
    run_counter          integer DEFAULT 0 NOT NULL ,
    is_active            char(1)  NOT NULL ,
    start_date           date   ,
    end_date             date   ,
    created_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    updated_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
    CONSTRAINT pk_subscribers_id PRIMARY KEY ( id ),
    CONSTRAINT fk_subscribers_customer FOREIGN KEY ( customer_id ) REFERENCES "public".customer( id )   ,
    CONSTRAINT fk_subscribers_strategy FOREIGN KEY ( strategy_id ) REFERENCES "public".strategy( id )   ,
    CONSTRAINT fk_subscribers_broker FOREIGN KEY ( broker_id ) REFERENCES "public".broker( id )
 );

CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$function$
;

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.customer FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.strategy_params FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.strategy FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.subscribers FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp();


INSERT INTO "public".broker( id, name ) VALUES ( 1, 'IIFL');
INSERT INTO "public".broker( id, name ) VALUES ( 2, 'Alice Blue');
INSERT INTO "public".customer( first_name, last_name, mobile, mail, address, active,telegram_id ) VALUES (
							  'Linges', 'M', 6382860148, 'nerus.q8@gmail.com', 'Chennai', 'Y', 1647735620);
INSERT INTO "public".customer( first_name, last_name, mobile, mail, address, active, telegram_id ) VALUES ( 
								'Raja', 'YOGI', 9884411611, 'acumeraja@yahoo.co.in', 'Cbe', 'Y', 1089456737);
INSERT INTO "public".strategy(name, min_multiplier, capital_required, price_per_month, description ) VALUES (
								'Option Scalper', 1, 50000, 500, 'BUY 1 lot CE and PE at the same time.');
INSERT INTO "public".strategy(name, min_multiplier, capital_required, price_per_month, description ) VALUES ( 
								'NFO Panther', 1, 150000, 1000, 'BUY 2 lots and SELL 1 lot at SL, Same cont for every 1 hour');
INSERT INTO "public".strategy_params(name, strategy_id, script_name, start_time, repair_time, end_time, target, stop_loss ) VALUES ( 
									 'os_params', 501, 'Option_Scalper_Live', '09:45:00', '14:40:00', '15:05:00', 3000, -1500);
INSERT INTO "public".strategy_params(  name, strategy_id, script_name, start_time, repair_time, end_time, target, stop_loss ) VALUES ( 
										'nfo_params', 502, 'NFO_Panther_Live', '09:30:00','14:40:00', '15:05:00', 24000, -12000);
INSERT INTO "public".subscribers( customer_id, strategy_id, broker_id, is_active ) VALUES (
								  123456, 501, 1, 'Y');


CREATE  TABLE "public".run_counter ( 
	counter              integer   ,
	subscriber_id        integer   ,
	pnl                  numeric(7,2) DEFAULT 0.00  ,
	created_at           timestamp(0) DEFAULT CURRENT_TIMESTAMP  ,
	CONSTRAINT fk_run_counter_subscribers FOREIGN KEY ( subscriber_id ) REFERENCES "public".subscribers( id )   
 );


CREATE  TABLE "public".order_book ( 
	id                   bigint DEFAULT nextval('strategy_position_id_seq'::regclass) NOT NULL ,
	subscriber_id        integer   ,
	order_id             integer   ,
	broker_id            integer   ,
	broker_order_id      integer   ,
	exchange             char(6)   ,
	instrument           char(40)   ,
	quantity             integer   ,
	trade_price          decimal(7,2)   ,
	status               char(15)   ,
	order_date           timestamp(0) ,
	CONSTRAINT pk_order_book_id PRIMARY KEY ( id )
 );



CREATE  TABLE "public".positions ( 
	id                   integer  DEFAULT nextval('position_id_seq'::regclass) NOT NULL  ,
	strategy_id          integer   ,
	broker_id            integer   ,
	order_id             integer   ,
	exchange             char(7)   ,
	instrument           char(50)   ,
	underlying           char(20)   ,
	expiry               char(10)   ,
	instrument_type      char(10)   ,
	strike               integer   ,
	option_type          char(2)   ,
	txn_type             char(1)   ,
	condition_type       char(20)   ,
	entry_date           timestamp   ,
	quantity             integer   ,
	traded_price         decimal(10,2)   ,
	amount               decimal(10,1)   ,
	run_counter          integer   ,
	product_type         char(7)   ,
	deployment_type      char(10)   ,
	created_at           timestamp(0) DEFAULT current_timestamp  
 );

ALTER TABLE "public".positions ADD CONSTRAINT fk_positions_strategy FOREIGN KEY ( strategy_id ) REFERENCES "public".strategy( id );

ALTER TABLE "public".positions ADD CONSTRAINT fk_positions_broker FOREIGN KEY ( broker_id ) REFERENCES "public".broker( id );

ALTER TABLE "public".positions ADD CONSTRAINT fk_positions_order_book FOREIGN KEY ( order_id ) REFERENCES "public".order_book( order_id );


CREATE  TABLE "public".api ( 
	customer_id          integer   ,
	api_key              char(30)   ,
	api_secret           char(30)   ,
	token                char(50)   ,
	broker_id            integer   ,
	login_id             integer   ,
	login_password       char(50)   
 );

ALTER TABLE "public".api ADD CONSTRAINT fk_api_customer FOREIGN KEY ( customer_id ) REFERENCES "public".customer( id );

ALTER TABLE "public".api ADD CONSTRAINT fk_api_broker FOREIGN KEY ( broker_id ) REFERENCES "public".broker( id );


