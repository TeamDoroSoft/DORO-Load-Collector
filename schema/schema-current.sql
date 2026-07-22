-- =============================================================================
-- DORO Load - 통합 스키마 참고 파일 (schema-current)
-- MySQL 8.0 / InnoDB / utf8mb4
--
-- 이 파일은 Flyway 버전 파일이 아니다("V" 접두사가 없어 Flyway가 무시한다).
-- V1~V7을 순서대로 적용한 것과 동일한 최종 상태를 하나로 합친 참고/일괄적용용
-- 파일이다. V1~V7 개별 파일이 이 히스토리의 source of truth이며, 이 파일은
-- 그것들을 대체하지 않는다 — V1~V7이 바뀌면 이 파일도 수동으로 동기화해야 한다.
--
-- 대상: 아직 아무 마이그레이션도 적용되지 않은 새 DB(예: 새 AWS RDS 인스턴스)에
-- V1~V7을 하나하나 적용하는 대신 이 파일 하나만 실행하면 된다. 이미 V1~V4 등
-- 일부가 적용된 DB에는 사용하지 말 것(CREATE TABLE이 충돌한다) — 그런 경우는
-- 지금까지처럼 V1~V7을 순서대로 개별 적용한다.
--
-- 포함 내용: V1(기본 스키마) + V2(charger UNIQUE 키) + V3(KEV_INFO 시드) +
-- V4(UNVERIFIED operator/network 시드) + V5(connector_type/charger_connector) +
-- V6(brand/vehicle_model/vehicle_trim/vehicle_connector) + V7(station_type/
-- created_at/charger_name 컬럼) + V8(operator/charging_network UNIQUE 키) +
-- V9(station last_collected_at/is_closed 컬럼).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. 스키마 (FK 의존성 순서)
--    OPERATOR -> CHARGING_NETWORK -> STATION -> CHARGER -> CHARGER_STATUS_HISTORY
--    -> TARIFF -> DATA_SOURCE -> STATION_SOURCE_LINK
--    -> CONNECTOR_TYPE -> CHARGER_CONNECTOR
--    -> BRAND -> VEHICLE_MODEL -> VEHICLE_TRIM -> VEHICLE_CONNECTOR
-- -----------------------------------------------------------------------------

-- ERD: OPERATOR — 충전사업자(운영기관)
CREATE TABLE operator (
    operator_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    legal_name    VARCHAR(255)    NOT NULL,           -- 법인/기관 정식 명칭
    operator_code VARCHAR(50)     NOT NULL,           -- 사업자 식별 코드
    PRIMARY KEY (operator_id),
    UNIQUE (operator_code)                            -- (V8) collector upsert 경합 방지
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: CHARGING_NETWORK — 충전 네트워크(사업자 브랜드), OPERATOR 1:N
CREATE TABLE charging_network (
    network_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    operator_id  BIGINT UNSIGNED NOT NULL,
    network_name VARCHAR(255)    NOT NULL,
    PRIMARY KEY (network_id),
    UNIQUE (operator_id),                             -- (V8) 연산자당 네트워크 1개 강제
    CONSTRAINT fk_network_operator
        FOREIGN KEY (operator_id) REFERENCES operator (operator_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: STATION — 충전소, CHARGING_NETWORK 1:N (station_type/created_at은 V7 추가분)
CREATE TABLE station (
    station_id      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    network_id      BIGINT UNSIGNED NOT NULL,
    station_name    VARCHAR(255)    NOT NULL,
    address         VARCHAR(500)    NOT NULL,
    station_type    VARCHAR(50)         NULL,             -- 공공/민간 등(V7)
    is_closed       BOOLEAN         NOT NULL DEFAULT FALSE,  -- delYn='Y' 폐쇄 반영(V9)
    location        POINT           NOT NULL SRID 4326,   -- WGS84 좌표(원본 PostGIS geography 대체)
    operating_hours VARCHAR(255)        NULL,
    updated_at      DATETIME            NULL,
    last_collected_at DATETIME          NULL,             -- 마지막 수집 시각(V9)
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,  -- (V7)
    PRIMARY KEY (station_id),
    SPATIAL INDEX spx_station_location (location),
    CONSTRAINT fk_station_network
        FOREIGN KEY (network_id) REFERENCES charging_network (network_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: CHARGER — 개별 충전기, STATION 1:N (charger_name은 V7 추가분,
-- uq_charger_station_external UNIQUE 키는 V2 추가분)
CREATE TABLE charger (
    charger_id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    station_id          BIGINT UNSIGNED NOT NULL,
    external_charger_id VARCHAR(100)        NULL,       -- 소스 원본 충전기 식별자
    charger_name        VARCHAR(100)        NULL,       -- (V7)
    charger_type        VARCHAR(50)         NULL,       -- 단일 또는 복합 코드(예: DC_CHADEMO_AC3)
    max_power_kw        DECIMAL(6,2)        NULL,
    PRIMARY KEY (charger_id),
    CONSTRAINT uq_charger_station_external
        UNIQUE (station_id, external_charger_id),        -- (V2) collector upsert 경합 방지
    CONSTRAINT fk_charger_station
        FOREIGN KEY (station_id) REFERENCES station (station_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: CHARGER_STATUS_HISTORY — 충전기 상태 이력, CHARGER 1:N
CREATE TABLE charger_status_history (
    status_id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    charger_id        BIGINT UNSIGNED NOT NULL,
    status             VARCHAR(50)     NOT NULL,
    source_updated_at DATETIME            NULL,          -- 소스 보고 이벤트타임
    collected_at      DATETIME            NULL,          -- 수집 시각
    PRIMARY KEY (status_id),
    -- 이벤트 시간 기준 최신 상태 판단 지원(CLAUDE.md 도메인 규칙)
    INDEX idx_status_charger_collected (charger_id, collected_at),
    CONSTRAINT fk_status_charger
        FOREIGN KEY (charger_id) REFERENCES charger (charger_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: TARIFF — 충전 요금, CHARGING_NETWORK 1:N
CREATE TABLE tariff (
    tariff_id      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    network_id     BIGINT UNSIGNED NOT NULL,
    customer_type  VARCHAR(50)         NULL,             -- 회원/비회원 등 고객 구분
    speed_class    VARCHAR(50)         NULL,             -- 급속/완속 등 속도 구분
    price_per_kwh  DECIMAL(10,2)       NULL,
    effective_from DATE                NULL,
    effective_to   DATE                NULL,
    PRIMARY KEY (tariff_id),
    CONSTRAINT fk_tariff_network
        FOREIGN KEY (network_id) REFERENCES charging_network (network_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: DATA_SOURCE — 데이터 출처 레지스트리
CREATE TABLE data_source (
    source_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    source_name VARCHAR(255)    NOT NULL,
    source_type VARCHAR(50)         NULL,                -- individual_charger / aggregate 등
    endpoint    VARCHAR(500)        NULL,
    PRIMARY KEY (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: STATION_SOURCE_LINK — STATION <-> DATA_SOURCE 다대다 연결(복합 PK, 대리키 없음)
CREATE TABLE station_source_link (
    station_id        BIGINT UNSIGNED NOT NULL,
    source_id         BIGINT UNSIGNED NOT NULL,
    source_station_id VARCHAR(100)        NULL,          -- 해당 소스에서의 원본 충전소 ID
    match_method       VARCHAR(50)         NULL,          -- exact_id / address_similarity / coordinate_radius
    match_score        DECIMAL(5,4)        NULL,          -- 매칭 신뢰도 0~1
    PRIMARY KEY (station_id, source_id),
    CONSTRAINT fk_link_station
        FOREIGN KEY (station_id) REFERENCES station (station_id),
    CONSTRAINT fk_link_source
        FOREIGN KEY (source_id) REFERENCES data_source (source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: CONNECTOR_TYPE — 원자 커넥터 코드 lookup(V5)
CREATE TABLE connector_type (
    connector_code VARCHAR(50)  NOT NULL,
    connector_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (connector_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: CHARGER_CONNECTOR — CHARGER <-> CONNECTOR_TYPE 다대다 연결(V5, 복합 PK)
-- 환경부 chgerType 복합 코드(03/05/06/10)를 원자 커넥터 단위로 분해해 저장한다.
CREATE TABLE charger_connector (
    charger_id     BIGINT UNSIGNED NOT NULL,
    connector_code VARCHAR(50)     NOT NULL,
    PRIMARY KEY (charger_id, connector_code),
    CONSTRAINT fk_charger_connector_charger
        FOREIGN KEY (charger_id) REFERENCES charger (charger_id),
    CONSTRAINT fk_charger_connector_type
        FOREIGN KEY (connector_code) REFERENCES connector_type (connector_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: BRAND — 차량 제조사(V6, 수동 입력 — collector가 채우지 않음)
CREATE TABLE brand (
    brand_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    brand_name VARCHAR(100)    NOT NULL,
    PRIMARY KEY (brand_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: VEHICLE_MODEL — 차량 모델, BRAND 1:N(V6)
CREATE TABLE vehicle_model (
    model_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    brand_id   BIGINT UNSIGNED NOT NULL,
    model_name VARCHAR(200)    NOT NULL,
    PRIMARY KEY (model_id),
    CONSTRAINT fk_vehicle_model_brand
        FOREIGN KEY (brand_id) REFERENCES brand (brand_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: VEHICLE_TRIM — 트림(세부 스펙) 단위, VEHICLE_MODEL 1:N(V6)
CREATE TABLE vehicle_trim (
    vehicle_trim_id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    model_id         BIGINT UNSIGNED NOT NULL,
    trim_name        VARCHAR(200)    NOT NULL,
    battery_kwh      DECIMAL(6,2)        NULL,       -- 배터리 용량(kWh)
    normal_range_km  INT                 NULL,       -- 상온 주행가능거리(km)
    max_ac_kw        DECIMAL(5,2)        NULL,       -- 차량 최대 AC 충전 입력(kW)
    max_dc_kw        DECIMAL(5,2)        NULL,       -- 차량 최대 DC 충전 입력(kW)
    PRIMARY KEY (vehicle_trim_id),
    CONSTRAINT fk_vehicle_trim_model
        FOREIGN KEY (model_id) REFERENCES vehicle_model (model_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ERD: VEHICLE_CONNECTOR — VEHICLE_TRIM <-> CONNECTOR_TYPE 다대다 연결(V6, 복합 PK)
CREATE TABLE vehicle_connector (
    vehicle_trim_id BIGINT UNSIGNED NOT NULL,
    connector_code  VARCHAR(50)     NOT NULL,
    charge_mode     VARCHAR(10)         NULL,          -- AC/DC 등
    is_standard     BOOLEAN             NULL,          -- 차량 기본 탑재 커넥터 여부
    note            VARCHAR(255)        NULL,
    PRIMARY KEY (vehicle_trim_id, connector_code),
    CONSTRAINT fk_vehicle_connector_trim
        FOREIGN KEY (vehicle_trim_id) REFERENCES vehicle_trim (vehicle_trim_id),
    CONSTRAINT fk_vehicle_connector_type
        FOREIGN KEY (connector_code) REFERENCES connector_type (connector_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. 시드 데이터 (WHERE NOT EXISTS로 idempotent — 재실행해도 안전)
-- -----------------------------------------------------------------------------

-- (V3) KEV_INFO data_source 시드 — collector가 station_source_link를 채우려면 선행 필요
INSERT INTO data_source (source_name, source_type, endpoint)
SELECT
    '한국환경공단 EvCharger 충전소 정보(getChargerInfo)',
    'individual_charger',
    'http://apis.data.go.kr/B552584/EvCharger/getChargerInfo'
WHERE NOT EXISTS (
    SELECT 1 FROM data_source
    WHERE endpoint = 'http://apis.data.go.kr/B552584/EvCharger/getChargerInfo'
);

-- (V4) 미분류(UNVERIFIED) operator + charging_network 시드
-- station.network_id(NOT NULL FK) 대상이 없으므로 안정적 네트워크 매핑 전까지 사용
INSERT INTO operator (legal_name, operator_code)
SELECT '미분류(UNVERIFIED)', 'UNVERIFIED'
WHERE NOT EXISTS (
    SELECT 1 FROM operator WHERE operator_code = 'UNVERIFIED'
);

INSERT INTO charging_network (operator_id, network_name)
SELECT o.operator_id, '미분류(UNVERIFIED)'
FROM operator o
WHERE o.operator_code = 'UNVERIFIED'
  AND NOT EXISTS (
      SELECT 1 FROM charging_network cn
      WHERE cn.operator_id = o.operator_id
        AND cn.network_name = '미분류(UNVERIFIED)'
  );

-- (V5) connector_type 원자 커넥터 9종 시드(복합 코드는 charger_connector에서 N행으로 분해)
INSERT INTO connector_type (connector_code, connector_name)
SELECT 'DC_CHADEMO', 'DC 차데모'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'DC_CHADEMO');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'AC_SLOW', 'AC 완속'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'AC_SLOW');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'DC_COMBO', 'DC 콤보'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'DC_COMBO');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'AC3', 'AC 3상'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'AC3');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'DC_COMBO_SLOW', 'DC 콤보(완속)'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'DC_COMBO_SLOW');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'NACS', 'NACS(테슬라)'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'NACS');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'DC_COMBO2_BUS', 'DC 콤보2(버스전용)'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'DC_COMBO2_BUS');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'UNKNOWN', '미상'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'UNKNOWN');

INSERT INTO connector_type (connector_code, connector_name)
SELECT 'UNMAPPED', '미매핑'
WHERE NOT EXISTS (SELECT 1 FROM connector_type WHERE connector_code = 'UNMAPPED');
