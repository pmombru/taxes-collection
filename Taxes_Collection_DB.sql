CREATE TABLE "taxpayer" (
  "taxpayer_id" varchar PRIMARY KEY,
  "type" varchar,
  "email" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "taxpayer_phone_number" (
  "rel_id" varchar PRIMARY KEY,
  "taxpayer_id" varchar,
  "phone_number_id" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "phone_type" (
  "phone_type_id" varchar PRIMARY KEY,
  "type" varchar UNIQUE,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "phone_number" (
  "phone_number_id" varchar PRIMARY KEY,
  "number" varchar UNIQUE,
  "phone_type_id" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "individual" (
  "taxpayer_id" varchar PRIMARY KEY,
  "doc_number" varchar,
  "first_name" varchar,
  "last_name" varchar,
  "date_of_birth" date,
  "home_address" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "company" (
  "taxpayer_id" varchar PRIMARY KEY,
  "cuit_number" varchar UNIQUE,
  "comencement_date" date,
  "website" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "own_rel" (
  "rel_id" varchar PRIMARY KEY,
  "individual_id" varchar,
  "company_id" varchar,
  "start_date" datetime,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "agency" (
  "agency_id" varchar PRIMARY KEY,
  "number" varchar UNIQUE,
  "address" varchar,
  "person_in_charge" varchar,
  "number_of_emp" integer,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "agency_phone_number" (
  "rel_id" varchar PRIMARY KEY,
  "agency_id" varchar,
  "phone_number_id" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "tax_payment" (
  "payment_id" varchar PRIMARY KEY,
  "agency_id" varchar,
  "taxpayer_id" varchar,
  "amount" numeric,
  "payment_date" datetime,
  "tax_type_id" varchar,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

CREATE TABLE "tax_type" (
  "tax_type_id" varchar PRIMARY KEY,
  "type" varchar UNIQUE,
  "created_at" timestamp,
  "created_by" varchar,
  "last_upd_by" varchar
);

ALTER TABLE "taxpayer_phone_number" ADD FOREIGN KEY ("taxpayer_id") REFERENCES "taxpayer" ("taxpayer_id");

ALTER TABLE "taxpayer_phone_number" ADD FOREIGN KEY ("phone_number_id") REFERENCES "phone_number" ("phone_number_id");

ALTER TABLE "phone_number" ADD FOREIGN KEY ("phone_type_id") REFERENCES "phone_type" ("phone_type_id");

ALTER TABLE "individual" ADD FOREIGN KEY ("taxpayer_id") REFERENCES "taxpayer" ("taxpayer_id");

ALTER TABLE "company" ADD FOREIGN KEY ("taxpayer_id") REFERENCES "taxpayer" ("taxpayer_id");

ALTER TABLE "own_rel" ADD FOREIGN KEY ("individual_id") REFERENCES "taxpayer" ("taxpayer_id");

ALTER TABLE "own_rel" ADD FOREIGN KEY ("company_id") REFERENCES "taxpayer" ("taxpayer_id");

ALTER TABLE "agency_phone_number" ADD FOREIGN KEY ("agency_id") REFERENCES "agency" ("agency_id");

ALTER TABLE "agency_phone_number" ADD FOREIGN KEY ("phone_number_id") REFERENCES "phone_number" ("phone_number_id");

ALTER TABLE "tax_payment" ADD FOREIGN KEY ("agency_id") REFERENCES "agency" ("agency_id");

ALTER TABLE "tax_payment" ADD FOREIGN KEY ("taxpayer_id") REFERENCES "taxpayer" ("taxpayer_id");

ALTER TABLE "tax_payment" ADD FOREIGN KEY ("tax_type_id") REFERENCES "tax_type" ("tax_type_id");

CREATE UNIQUE INDEX "taxpayer_phone_number_u_1" ON "taxpayer_phone_number" ("taxpayer_id", "phone_number_id");

CREATE UNIQUE INDEX "own_rel_u_1" ON "own_rel" ("individual_id", "company_id");

CREATE UNIQUE INDEX "taxpayer_phone_number_u_1" ON "agency_phone_number" ("agency_id", "phone_number_id");

CREATE UNIQUE INDEX "tax_payment_u_1" ON "tax_payment" ("agency_id", "taxpayer_id", "payment_date", "tax_type_id");
